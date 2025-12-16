import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/SendDataToEsp32/esp32_service.dart';
import 'package:glucotrack_app/models/GlucoseData.dart';

class Glucoseprediction extends StatefulWidget {
  @override
  _GlucosepredictionState createState() => _GlucosepredictionState();
}

class _GlucosepredictionState extends State<Glucoseprediction> {
  final SupabaseService _supabaseService = SupabaseService();

  String status = 'idle'; // idle, measuring, success, error
  GlucoseData? glucoseData;
  String errorMessage = '';
  String userId = 'User_Test';
  int pollingAttempts = 0;
  final int maxPollingAttempts = 30;

  double get measurementProgress {
    return pollingAttempts / maxPollingAttempts;
  }

  int get measurementPercent {
    return (measurementProgress * 100).clamp(0, 100).toInt();
  }

  Future<void> startMeasurement() async {
    setState(() {
      status = 'measuring';
      glucoseData = null;
      errorMessage = '';
      pollingAttempts = 0;
    });

    // Kirim trigger
    final triggerTime = DateTime.now();
    final triggerSent = await _supabaseService.sendMeasurementTrigger(userId);

    if (!triggerSent) {
      setState(() {
        status = 'error';
        errorMessage = 'Gagal mengirim trigger ke ESP32';
      });
      return;
    }

    print('✅ Trigger dikirim ke ESP32');

    // Polling untuk hasil
    await for (final result in _supabaseService.pollForMeasurement(
      userId,
      maxAttempts: maxPollingAttempts,
    )) {
      setState(() {
        pollingAttempts++;
      });

      if (result != null) {
        setState(() {
          status = 'success_preview';
          glucoseData = GlucoseData.fromJson(result);
        });
        print('📊 Hasil diterima: $result');
        break;
      }

      if (pollingAttempts >= maxPollingAttempts) {
        setState(() {
          status = 'error';
          errorMessage = 'Timeout: ESP32 tidak merespons';
        });
        break;
      }
    }
  }

  void saveAndReturn() {
    if (glucoseData != null) {
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
                const Text(
                  "Glucose\nMeasuring",
                  style: TextStyle(
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (status == 'success') _buildSuccessState(),
                    if (status == 'success') const SizedBox(height: 30),
                    if (status == 'success') ...[
                      ElevatedButton(
                        onPressed: saveAndReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 10),
                            Text(
                              'Simpan Hasil',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: startMeasurement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 10),
                            Text(
                              'Ukur Lagi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ] else if (status != 'measuring' &&
                        status != 'idle' &&
                        status != 'success_preview') ...[
                      ElevatedButton(
                        onPressed: startMeasurement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 10),
                            Text(
                              'Mulai Pengukuran',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (status == 'idle') _buildIdleState(),
            if (status == 'measuring') _buildMeasuringState(),
            if (status == 'error') _buildErrorState(),
            if (status == 'success_preview') _buildSuccessPreview(),
          ],
        ),
      ),
    );
  }

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
          const SizedBox(height: 70),
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
                  'Check your glucose now!',
                  style: TextStyle(
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
                  child: const Text(
                    'Start',
                    style: TextStyle(
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

        const SizedBox(height: 70),

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
              const Text(
                'Measurement Process',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // Progress Bar %
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 57,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: LinearProgressIndicator(
                          value: measurementProgress,
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
                        '$measurementPercent%',
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
    if (glucoseData == null) return SizedBox();

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 20),
            Text(
              'Hasil Pengukuran',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Text(
              '${glucoseData!.glucosePredict.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: glucoseData!.getGlucoseColor(),
              ),
            ),
            Text(
              'mg/dL',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: glucoseData!.getGlucoseColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: glucoseData!.getGlucoseColor(), width: 2),
              ),
              child: Text(
                glucoseData!.getGlucoseStatus(),
                style: TextStyle(
                  color: glucoseData!.getGlucoseColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Confidence: ', style: TextStyle(color: Colors.grey[600])),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: glucoseData!.getConfidenceColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: glucoseData!.getConfidenceColor()),
                  ),
                  child: Text(
                    glucoseData!.confidence,
                    style: TextStyle(
                      color: glucoseData!.getConfidenceColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCircle() {
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
                value: 1,
                strokeWidth: progressStroke,
                backgroundColor: Colors.blue.shade100,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF3D7EA6)),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      glucoseData!.glucosePredict.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'mg/dL',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPreview() {
    if (glucoseData == null) return const SizedBox();

    return Column(
      children: [
        //Mengundang Circle
        _buildSuccessCircle(),

        const SizedBox(height: 70),

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
              const Text(
                'Hasil Pengukuran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: glucoseData!.getGlucoseColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: glucoseData!.getGlucoseColor(), width: 2),
                ),
                child: Text(
                  glucoseData!.getGlucoseStatus(),
                  style: TextStyle(
                    color: glucoseData!.getGlucoseColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    status = 'success';
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
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

  Widget _buildErrorState() {
    return Column(
      children: [
        // error circle
        _buildErrorCircle(),

        const SizedBox(height: 70),

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
              const Text(
                'Pengukuran Gagal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // error
              Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Timeout: ESP32 tidak merespons',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
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
                child: const Text(
                  'Mulai Pengukuran',
                  style: TextStyle(
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
