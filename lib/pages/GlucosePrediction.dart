import 'package:flutter/material.dart';
import 'dart:async';
import 'package:glucotrack_app/services/SendDataToEsp32/esp32_service.dart';
import 'package:glucotrack_app/models/GlucoseData.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';

class GlucosePrediction extends StatefulWidget {
  // Back to simple constructor
  const GlucosePrediction({Key? key}) : super(key: key);

  @override
  _GlucosepredictionState createState() => _GlucosepredictionState();
}

class _GlucosepredictionState extends State<GlucosePrediction> {
  final SupabaseService _supabaseService = SupabaseService();

  String status = 'idle'; // idle, measuring, success, error
  GlucoseData? glucoseData;
  String errorMessage = '';
  
  // Hardcoded User_Test to match ESP32 firmware
  String userId = 'User_Test'; 
  
  @override
  void initState() {
    super.initState();
  }
  
  // Status-based communication variables
  String? commandId;
  String esp32Status = '';
  String statusMessage = '';
  int progress = 0;

  Future<void> startMeasurement() async {
    setState(() {
      status = 'measuring';
      glucoseData = null;
      errorMessage = '';
      esp32Status = 'triggered';
      statusMessage = 'Sending trigger to ESP32...';
      progress = 0;
    });

    // 0. Capture start time for strict validation
    final DateTime startTime = DateTime.now().toUtc(); // Use UTC for DB comparison

    // 1. Capture current latest measurement ID BEFORE triggering
    String? initialMeasurementId;
    try {
      final latestData = await _supabaseService.getLatestMeasurement(userId);
      initialMeasurementId = latestData?['id'];
      print('📸 Captured initial measurement ID: $initialMeasurementId');
    } catch (e) {
      print('⚠️ Failed to capture initial measurement ID: $e');
    }

    // Kirim trigger dan dapatkan command ID
    final response = await _supabaseService.sendMeasurementTrigger(userId);

    if (response == null) {
      setState(() {
        status = 'error';
        errorMessage = AppLocalizations.of(context)!.failedTriggerEsp32;
      });
      return;
    }

    commandId = response['id'];
    
    // CAPTURE SERVER TIMESTAMP of the Command
    // We use this to filter out "Ghost Data" (results from previous timed-out attempts).
    // A valid measurement MUST be created AFTER this command.
    final commandCreatedAtStr = response['created_at'];
    final DateTime commandCreatedAt = commandCreatedAtStr != null 
        ? DateTime.parse(commandCreatedAtStr) 
        : DateTime.now().toUtc(); // Fallback to local if missing (should not happen)
        
    print('✅ Trigger sent! Command ID: $commandId at $commandCreatedAt');
    
    // Update status to indicate trigger is sent and we are now waiting
    setState(() {
      statusMessage = 'Trigger received. Waiting for sensor...';
    });

    // Stream status ESP32 secara realtime
    bool dataFound = false;
    
    // Helper untuk check data
    Future<void> checkForNewData() async {
      if (dataFound) return;
      try {
        final currentLatest = await _supabaseService.getLatestMeasurement(userId);
        if (currentLatest == null) return;

        final currentId = currentLatest['id'];
        final createdAtStr = currentLatest['created_at'] as String?;
        final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : null;
        
        // SERVER-SYNC VALIDATION:
        // 1. ID Check
        // 2. TIME Check (CRITICAL): Measurement time MUST be > Command Time
        // 3. MINIMUM DURATION Check: Ignore data found too quickly (< 5 seconds)
        //    This filters out "Ghost Data" from previous attempts that arrive late.
        
        final executionDuration = DateTime.now().difference(commandCreatedAt);
        if (executionDuration.inSeconds < 5) {
           print('⏳ Found new data but too early (${executionDuration.inSeconds}s). Ignoring potential ghost data.');
           return;
        }
        
        if (createdAt != null && createdAt.isAfter(commandCreatedAt)) {
           print('✅ Valid new measurement found! ID: $currentId Time: $createdAt');
           dataFound = true;
           setState(() {
              status = 'success';
              glucoseData = GlucoseData.fromJson(currentLatest);
           });
        } else {
           print('⚠️ Ignoring stale/ghost data (ID: $currentId, Time: $createdAt vs Cmd: $commandCreatedAt)');
        }
      } catch (e) {
        print('Error polling: $e');
      }
    }

    // Start a timer to poll every 2 seconds
    final timer = Timer.periodic(Duration(seconds: 2), (timer) async {
       if (status != 'measuring') {
         timer.cancel();
         return;
       }
       await checkForNewData();
    });
    
    // SIMULATED PROGRESS (Resilient/Hybrid Mode)
    // If we get logs, we follow them. If not, we simulate gently to 80% to show activity.
    final progressTimer = Timer.periodic(Duration(milliseconds: 500), (t) {
       if (status != 'measuring') {
         t.cancel();
         return;
       }
       
       // Calculate dynamic limit based on Time vs Status
       int limit = 85; // Default behavior: Allow going up to 85% implicitly
       
       // If we HAVE specific status from ESP32, we obey it strictly
       // But if status is just 'triggered', we assume "Blind Mode" and allow layout to move
       if (esp32Status == 'validating') limit = 30;
       else if (esp32Status == 'stabilizing') limit = 50;
       else if (esp32Status == 'sampling') limit = 75;
       else if (esp32Status == 'processing') limit = 90;
       
       // If we are strictly in 'triggered' (no logs yet), we limit speed based on time
       // so it doesn't rush to 85% instantly.
       if (esp32Status == 'triggered' || esp32Status.isEmpty) {
          final seconds = DateTime.now().difference(startTime).inSeconds;
          if (seconds < 2) limit = 10;
          else if (seconds < 5) limit = 30;
          else if (seconds < 10) limit = 60;
          else limit = 85;
          
          // Update message for better UX in "Blind Mode"
          if (seconds > 3 && progress < 30) statusMessage = 'Connecting to sensor...';
          if (seconds > 6 && progress < 60) statusMessage = 'Analyzing bio-signals...';
          if (seconds > 12 && progress < 80) statusMessage = 'Processing data...';
       }

       // Only increment if below limit
       if (progress < limit) {
         setState(() {
            progress += 2; 
            if (progress > limit) progress = limit; 
         });
       }
    });

    // WATCHDOG TIMER: Relaxed for connection stability
    final watchdogTimer = Timer.periodic(Duration(seconds: 1), (t) {
       if (status != 'measuring') {
         t.cancel();
         return;
       }
       
       final duration = DateTime.now().difference(startTime);

       // GLOBAL TIMEOUT: Only kill if it takes ridiculously long (> 45s)
       // This gives the ESP32 plenty of time even if it's "Cold Starting"
       if (duration.inSeconds > 45) {
          t.cancel();
          setState(() {
            status = 'error';
            errorMessage = 'Connection timed out. Please check your internet or ESP32.';
            progress = 0;
          });
       }
    });

    try {
      await for (final statusUpdate in _supabaseService.streamCommandStatus(
        commandId!, 
        userId: userId,
      )) {
        // Stop if we already found data manually
        if (dataFound || status != 'measuring') break;

        // Extract values first
        final newStatus = statusUpdate['status'] ?? '';
        final rawMsg = statusUpdate['status_message']?.toString() ?? '';
        final newProgress = statusUpdate['progress'] ?? 0;
        final isProcessed = statusUpdate['processed'] == true;

        // Friendly Error Message Mapping
        String friendlyError = rawMsg;
        if (newStatus == 'error' || newStatus == 'failed') {
           if (rawMsg.contains('Finger missing') || rawMsg.contains('Bad Signal')) {
              friendlyError = 'Measurement interrupted. Finger moved or removed.';
           } else if (rawMsg.contains('DB Error')) {
              friendlyError = 'Database connection error. Try again.';
           } else if (friendlyError.isEmpty) {
              friendlyError = 'Measurement failed. Please try again.';
           }
        }

        // Critical: Check for failure status immediately
        if (newStatus == 'failed' || newStatus == 'error') {
            setState(() {
              status = 'error';
              errorMessage = friendlyError;
              progress = 0;
            });
            break;
        }

        setState(() {
          esp32Status = newStatus;
          
          if (rawMsg.isNotEmpty) statusMessage = rawMsg;
          
          if (newProgress > progress || isProcessed) {
             progress = newProgress;
          }
        });

        // Check if stream says completed
        if (esp32Status == 'completed' || isProcessed) {
           await checkForNewData(); // One last check
           if (!dataFound) {
              final data = await _supabaseService.getLatestMeasurement(userId);
              
              // REPEAT SERVER-SYNC VALIDATION
              final currentId = data?['id'];
              final createdAtStr = data?['created_at'] as String?;
              final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : null;

              // TIME Check: Measurement > Command Time
              bool isValid = data != null && 
                             createdAt != null && 
                             createdAt.isAfter(commandCreatedAt);
              
              if (isValid) {
                setState(() {
                  status = 'success';
                  glucoseData = GlucoseData.fromJson(data!);
                });
                dataFound = true;
              } else {
                 print('⚠️ Stream done but data stale (ID: $currentId, Time: $createdAt)');
                 setState(() {
                   status = 'error';
                   errorMessage = 'No new measurement data found.';
                 });
              }
           }
           break;
        }
        else if (esp32Status == 'error') {
           setState(() {
             status = 'error';
             errorMessage = statusMessage;
           });
           break;
        }
        else if (esp32Status == 'timeout') {
           // Timeout, but let's check one last time
           await checkForNewData();
           if (!dataFound) {
             setState(() {
               status = 'error';
               errorMessage = statusMessage;
             });
           }
           break;
        }
      }
    } finally {
      timer.cancel();
    }
  }

  void saveAndReturn() {
    if (glucoseData != null) {
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.glucoseDataSaved),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      Navigator.pop(context, {
        'glucoseLevel': glucoseData!.glucosePredict,
        'isFromIoT': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF2C7796), size: 25),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.glucoseChart.replaceAll(' Chart', '\nMeasuring'),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C7796),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section - HANYA tampil jika BUKAN preview result DAN BUKAN Error (agar error bisa full screen)
            if (status != 'success_preview' && status != 'error')
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (status == 'success') _buildSuccessState(),
                      if (status == 'success') const SizedBox(height: 30),
                      if (status == 'success') ...[
                        // Primary Action: Save
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: saveAndReturn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D7EA6), // Premium Blue
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.save,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Secondary Action: Measure Again
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            onPressed: startMeasurement,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF3D7EA6),
                              side: const BorderSide(color: Color(0xFF3D7EA6), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh_rounded, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.measureAgain,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            
            // State Widgets
            if (status == 'idle') _buildIdleState(),
            if (status == 'measuring') _buildMeasuringState(),
            
            // Error State - Pakai Expanded agar bisa centered & full screen
            if (status == 'error')Expanded(child: _buildErrorState()),
            
            // Preview Result - Pakai Expanded agar bisa centered & full screen
            if (status == 'success_preview') 
              Expanded(child: _buildSuccessPreview()),
          ],
        ),
      ),
    );
  }
  // Removed _buildBody helper to keep it simple and aligned with original structure

  Widget _buildCircleButton({bool isLoading = false}) {
    const double outerSize = 260;
    const double progressStroke = 12;
    const double whiteGap = 10;
    const double blueSize = 200;

    return Center(
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: outerSize,
              height: outerSize,
              child: CircularProgressIndicator(
                value: isLoading ? null : 1,
                strokeWidth: progressStroke,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  isLoading ? const Color(0xFF3D7EA6) : Colors.grey.shade400,
                ),
              ),
            ),
            Container(
              width: outerSize - (progressStroke * 2) - whiteGap,
              height: outerSize - (progressStroke * 2) - whiteGap,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5),
              ),
            ),
            Container(
              width: blueSize,
              height: blueSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3D7EA6),
              ),
            ),
            ClipOval(
              child: Image.asset(
                'assets/Logo.png',
                width: 70,
                height: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCircle() {
    const double outerSize = 260;
    const double progressStroke = 12;
    const double whiteGap = 10;
    const double redSize = 200;

    return Center(
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            SizedBox(
              width: outerSize,
              height: outerSize,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: progressStroke,
                backgroundColor: Colors.red.shade100,
                valueColor: AlwaysStoppedAnimation(Colors.red.shade300),
              ),
            ),

            // gapnya
            Container(
              width: outerSize - (progressStroke * 2) - whiteGap,
              height: outerSize - (progressStroke * 2) - whiteGap,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F5F5),
              ),
            ),

            // Daleman Circle (Merah)
            Container(
              width: redSize,
              height: redSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[100],
              ),
              child: const Center(
                child: Icon(
                  Icons.priority_high_rounded,
                  color: Colors.red,
                  size: 90,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCircleButton(isLoading: false),
          const SizedBox(height: 150),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6E9BB2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                  Text(
                    AppLocalizations.of(context)!.checkGlucoseNow,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: startMeasurement,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.start,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasuringState() {
    return Column(
      children: [
        // Circle dan progress ring
        _buildCircleButton(isLoading: true),

        const SizedBox(height: 150),

        // Box Bawah
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF6E9BB2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.measurementProcess,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Status message dari ESP32
              Text(
                statusMessage.isEmpty ? 'Waiting for sensor...' : statusMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Progress Bar % dari ESP32
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 57,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: LinearProgressIndicator(
                          value: progress / 100, // Convert 0-100 to 0.0-1.0
                          backgroundColor: Colors.white.withOpacity(0.4),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 65,
                    child: Center(
                      child: Text(
                        '$progress%', // Progress dari ESP32
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    if (glucoseData == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: glucoseData!.getGlucoseColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 12, color: glucoseData!.getGlucoseColor()),
                const SizedBox(width: 8),
                Text(
                  glucoseData!.getGlucoseStatus().toUpperCase(),
                  style: TextStyle(
                    color: glucoseData!.getGlucoseColor(),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Hero Value
          Text(
            glucoseData!.glucosePredict.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3E50),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'mg/dL',
            style: TextStyle(
              fontSize: 18, 
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.monitor_heart_outlined,
                  label: AppLocalizations.of(context)!.confidence,
                  value: glucoseData!.confidence,
                  color: glucoseData!.getConfidenceColor(),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: TimeOfDay.fromDateTime(glucoseData!.createdAt.toLocal()).format(context),
                  color: const Color(0xFF6E9BB2),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          Divider(color: Colors.grey[100]),
          const SizedBox(height: 10),
          
          Text(
            'Measurement completed successfully using non-invasive sensor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon, 
    required String label, 
    required String value, 
    required Color color
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.5), size: 24),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }



  Widget _buildSuccessPreview() {
    if (glucoseData == null) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Premium Circle
        Center(
          child: Container(
            width: 280,
            height: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D7EA6).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rings
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 20,
                    valueColor: AlwaysStoppedAnimation(
                      glucoseData!.getGlucoseColor().withOpacity(0.1)
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: 0.75, // Just for style, not real progress
                    strokeWidth: 20,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(glucoseData!.getGlucoseColor()),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RESULT',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      glucoseData!.glucosePredict.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C3E50),
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'mg/dL',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Bottom Result Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        glucoseData!.getGlucoseStatus(),
                        style: TextStyle(
                          color: glucoseData!.getGlucoseColor(),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: glucoseData!.getGlucoseColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.insights,
                      color: glucoseData!.getGlucoseColor(),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      status = 'success';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D7EA6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.continueText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        // Error Circle - Centered using Expanded
        Expanded(
          child: Center(
            child: _buildErrorCircle(),
          ),
        ),

        // Box bawah
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF6E9BB2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.measurementFailed,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Detailed Error Message
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  errorMessage.isNotEmpty
                      ? errorMessage
                      : AppLocalizations.of(context)!.timeoutEsp32,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              //button rettry
              ElevatedButton(
                onPressed: startMeasurement,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.startMeasurement,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
