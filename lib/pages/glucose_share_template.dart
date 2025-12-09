import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GlucoseShareTemplate extends StatefulWidget {
  final double glucoseLevel;
  final GlucoseCondition condition;
  final DateTime timestamp;
  final bool isFromIoT;

  const GlucoseShareTemplate({
    super.key,
    required this.glucoseLevel,
    required this.condition,
    required this.timestamp,
    required this.isFromIoT,
  });

  @override
  State<GlucoseShareTemplate> createState() => _GlucoseShareTemplateState();
}

class _GlucoseShareTemplateState extends State<GlucoseShareTemplate> {
  final GlobalKey _globalKey = GlobalKey();
  bool isSharing = false;
  bool isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() {
        isLocaleInitialized = true;
      });
    }
  }

  Color getGlucoseColor(double level, GlucoseCondition condition) {
    if (level < 70) {
      return const Color(0xFFFFF59D);
    } else if (condition == GlucoseCondition.beforeMeal) {
      if (level >= 70 && level <= 99) {
        return const Color(0xFF66BB6A);
      } else {
        return const Color(0xFFEF5350);
      }
    } else {
      if (level < 140) {
        return const Color(0xFF66BB6A);
      } else {
        return const Color(0xFFEF5350);
      }
    }
  }

  String getGlucoseLabel(double level, GlucoseCondition condition) {
    if (level < 70) {
      return "Low";
    } else if (condition == GlucoseCondition.beforeMeal) {
      if (level >= 70 && level <= 99) {
        return "Good";
      } else {
        return "High";
      }
    } else {
      if (level < 140) {
        return "Good";
      } else {
        return "High";
      }
    }
  }

  Future<void> shareGlucoseResult() async {
    setState(() {
      isSharing = true;
    });

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/glucose_result_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Hasil Pengukuran Gula Darah - GlucoTrack',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membagikan: $e')),
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLocaleInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C7796),
          title: const Text(
            'Bagikan Hasil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, 'back'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C7796),
          ),
        ),
      );
    }

    final color = getGlucoseColor(widget.glucoseLevel, widget.condition);
    final label = getGlucoseLabel(widget.glucoseLevel, widget.condition);
    final dayFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C7796),
        title: const Text(
          'Bagikan Hasil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, 'back'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2C7796),
                        Color(0xFF1E5A73),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'GlucoTrack',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hasil Pengukuran Gula Darah',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Measurement Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isFromIoT
                                    ? const Color(0xFFE3F2FD)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.isFromIoT
                                      ? const Color(0xFF2196F3)
                                      : const Color(0xFFFF9800),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.isFromIoT
                                        ? Icons.sensors
                                        : Icons.edit,
                                    size: 16,
                                    color: widget.isFromIoT
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFFF9800),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.isFromIoT
                                        ? 'Perangkat IoT (Invasive)'
                                        : 'Glucometer Manual',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isFromIoT
                                          ? const Color(0xFF2196F3)
                                          : const Color(0xFFFF9800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Glucose Level Display
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        widget.glucoseLevel.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'mg/dL',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Condition & Time Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.restaurant,
                                        color: Color(0xFF2C7796),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Kondisi: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.condition ==
                                                GlucoseCondition.beforeMeal
                                            ? 'Before Meal'
                                            : 'After Meal',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C7796),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF2C7796),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dayFormat.format(widget.timestamp),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Color(0xFF2C7796),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeFormat.format(widget.timestamp),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '💙 Jaga kesehatan Anda dengan GlucoTrack',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Share Button
              ElevatedButton.icon(
                onPressed: isSharing ? null : shareGlucoseResult,
                icon: isSharing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.share, color: Colors.white),
                label: Text(
                  isSharing ? 'Membagikan...' : 'Bagikan Hasil',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C7796),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
