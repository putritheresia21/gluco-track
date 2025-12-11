import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/SupabaseService.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/Widget/weekly_summary_card.dart';

class GlucoseChart extends StatefulWidget {
  const GlucoseChart({super.key});

  @override
  State<GlucoseChart> createState() => _GlucoseChartState();
}

class _GlucoseChartState extends State<GlucoseChart> {
  final Glucoserepository _repository = Glucoserepository();
  List<Glucoserecord> allRecords = [];
  DateTime? selectedDate;
  int? tappedBarIndex;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() => isLoading = true);

    try {
      // Get user ID from Supabase Auth
      final userId =
          SupabaseService.client.auth.currentUser?.id ?? 'default_user';

      // Fetch all records from Supabase
      final records = await _repository.getAllGlucoseRecords(userId);

      setState(() {
        allRecords = records;
        allRecords.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
        isLoading = false;
      });
    } catch (e) {
      print('Error loading records: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Glucoserecord> getRecordsByDate(DateTime date) {
    return allRecords.where((record) {
      return record.timeStamp.year == date.year &&
          record.timeStamp.month == date.month &&
          record.timeStamp.day == date.day;
    }).toList();
  }

  Color getGlucoseColor(double level, GlucoseCondition condition) {
    if (level < 70) {
      return const Color(0xFFFFF59D); // Kuning muda
    } else if (condition == GlucoseCondition.beforeMeal) {
      if (level >= 70 && level <= 99) {
        return const Color(0xFF66BB6A); // Hijau
      } else {
        return const Color(0xFFEF5350); // Merah
      }
    } else {
      if (level < 140) {
        return const Color(0xFF66BB6A); // Hijau
      } else {
        return const Color(0xFFEF5350); // Merah
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

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C7796),
          ),
        ),
      );
    }

    List<Glucoserecord> selectedDateRecords =
        selectedDate != null ? getRecordsByDate(selectedDate!) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadRecords,
          color: const Color(0xFF2C7796),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Glucose Chart",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weekly Summary Card
                  const WeeklySummaryCard(isCompactView: false),

                  const SizedBox(height: 30),

                  // History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "History",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: pickDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text("Pick a Date"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // History Cards
                  if (selectedDate != null)
                    selectedDateRecords.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C7796),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const Center(
                                  child: Text(
                                    "- mg/dL",
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tidak ada data untuk ${DateFormat('d MMM yyyy').format(selectedDate!)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: selectedDateRecords.map((record) {
                              Color statusColor = getGlucoseColor(
                                  record.glucoseLevel, record.condition);
                              String statusLabel = getGlucoseLabel(
                                  record.glucoseLevel, record.condition);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C7796),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  record.glucoseLevel
                                                      .toStringAsFixed(0),
                                                  style: const TextStyle(
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 15),
                                                  child: Text(
                                                    "mg/dL",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                statusLabel,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            // IoT Badge
                                            if (record.isFromIoT)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.sensors,
                                                      size: 14,
                                                      color: Colors.blue[300],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'IoT Device',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blue[300],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              DateFormat('d MMM yyyy, HH:mm')
                                                  .format(record.timeStamp),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              record.condition ==
                                                      GlucoseCondition
                                                          .beforeMeal
                                                  ? "Before Meal"
                                                  : "After Meal",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                  // Show all records count if no date selected
                  if (selectedDate == null && allRecords.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: Text(
                          'Total ${allRecords.length} records. Pilih tanggal untuk melihat detail.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                  // Empty state when no records at all
                  if (allRecords.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.insert_chart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada data glukosa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mulai tambahkan data pengukuran\nglukosa Anda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
