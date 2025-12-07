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
          status = 'success';
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Glucose Monitor'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Header
              // Container(
              //   padding: EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     shape: BoxShape.circle,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 10,
              //         offset: Offset(0, 5),
              //       ),
              //     ],
              //   ),
              //   child: Icon(
              //     Icons.water_drop_outlined,
              //     size: 60,
              //     color: Colors.blue,
              //   ),
              // ),
              // SizedBox(height: 30),

              // Status Card
              if (status == 'idle') _buildIdleState(),
              if (status == 'measuring') _buildMeasuringState(),
              if (status == 'success') _buildSuccessState(),
              if (status == 'error') _buildErrorState(),

              SizedBox(height: 30),

              // Action Buttons
              if (status == 'success') ...[
                // Save Button
                ElevatedButton(
                  onPressed: saveAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
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
                SizedBox(height: 15),
                // Measure Again Button
                ElevatedButton(
                  onPressed: startMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
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
              ] else if (status != 'measuring')
                ElevatedButton(
                  onPressed: startMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
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
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              'Siap untuk Pengukuran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Tekan tombol di bawah untuk memulai',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasuringState() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            CircularProgressIndicator(strokeWidth: 5),
            SizedBox(height: 20),
            Text(
              'Mengukur Glukosa...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Mohon tunggu, sedang membaca sensor',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Percobaan: $pollingAttempts/$maxPollingAttempts',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
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

  Widget _buildErrorState() {
    return Card(
      elevation: 5,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 20),
            Text(
              'Pengukuran Gagal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
