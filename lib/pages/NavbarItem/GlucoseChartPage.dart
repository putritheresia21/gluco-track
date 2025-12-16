import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/SupabaseService.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';

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

  List<Glucoserecord> getWeeklyRecords() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(const Duration(days: 7));

    return allRecords.where((record) {
      return record.timeStamp.isAfter(startOfWeek);
    }).toList();
  }

  double getWeeklyAverage() {
    List<Glucoserecord> weeklyRecords = getWeeklyRecords();
    if (weeklyRecords.isEmpty) return 0;

    double sum =
        weeklyRecords.fold(0, (prev, record) => prev + record.glucoseLevel);
    return sum / weeklyRecords.length;
  }

  Map<int, List<Glucoserecord>> getWeeklyGroupedRecords() {
    List<Glucoserecord> weeklyRecords = getWeeklyRecords();
    Map<int, List<Glucoserecord>> grouped = {};

    for (int i = 0; i < 7; i++) {
      grouped[i] = [];
    }

    for (var record in weeklyRecords) {
      int dayOfWeek = record.timeStamp.weekday % 7;
      grouped[dayOfWeek]!.add(record);
    }

    return grouped;
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

    return AppLayout(
      showBack: false,
      showHeader: true,
      headerBottomRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      headerBackgroundColor: const Color(0xFFF5F5F5),
      headerForegroundColor: Colors.black,
      bodyBackgroundColor: const Color(0xFFF5F5F5),
      title: 'Glucose Chart',
      headerHeight: 70,
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
                // Weekly Summary Card
                _buildWeeklySummaryCard(),

                const SizedBox(height: 30),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "History",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
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
                                    fontSize: 25,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
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
                                              padding:
                                                  const EdgeInsets.only(top: 8),
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
                                                    GlucoseCondition.beforeMeal
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
    );
  }

  Widget _buildWeeklySummaryCard() {
    double weeklyAvg = getWeeklyAverage();
    Map<int, List<Glucoserecord>> weeklyGrouped = getWeeklyGroupedRecords();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E5EA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Weekly Summary",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                weeklyAvg > 0 ? weeklyAvg.toStringAsFixed(0) : "-",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF5350),
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "mg/dL",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF5350),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                List<Glucoserecord> dayRecords = weeklyGrouped[index] ?? [];
                List<Glucoserecord> beforeMeal = dayRecords
                    .where((r) => r.condition == GlucoseCondition.beforeMeal)
                    .toList();
                List<Glucoserecord> afterMeal = dayRecords
                    .where((r) => r.condition == GlucoseCondition.afterMeal)
                    .toList();

                double beforeAvg = beforeMeal.isEmpty
                    ? 0
                    : beforeMeal.fold(0.0, (sum, r) => sum + r.glucoseLevel) /
                        beforeMeal.length;
                double afterAvg = afterMeal.isEmpty
                    ? 0
                    : afterMeal.fold(0.0, (sum, r) => sum + r.glucoseLevel) /
                        afterMeal.length;

                return _buildBarPair(
                  index,
                  beforeAvg,
                  afterAvg,
                  ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                );
              }),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFFFF9800), "Before Meal"),
              const SizedBox(width: 20),
              _buildLegendItem(const Color(0xFFEF5350), "After Meal"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarPair(
      int index, double beforeValue, double afterValue, String label) {
    double maxHeight = 150;
    double maxValue = 300;

    double beforeHeight =
        beforeValue > 0 ? (beforeValue / maxValue) * maxHeight : 0;
    double afterHeight =
        afterValue > 0 ? (afterValue / maxValue) * maxHeight : 0;

    beforeHeight = beforeHeight.clamp(0, maxHeight);
    afterHeight = afterHeight.clamp(0, maxHeight);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          tappedBarIndex = index;
        });
      },
      onTapUp: (_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              tappedBarIndex = null;
            });
          }
        });
      },
      onTapCancel: () {
        setState(() {
          tappedBarIndex = null;
        });
      },
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: maxHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: beforeHeight > 5
                          ? beforeHeight
                          : (beforeValue > 0 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 12,
                      height: afterHeight > 5
                          ? afterHeight
                          : (afterValue > 0 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          if (tappedBarIndex == index && (beforeValue > 0 || afterValue > 0))
            Positioned(
              top: -30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  beforeValue > 0 && afterValue > 0
                      ? "${beforeValue.toStringAsFixed(0)}/${afterValue.toStringAsFixed(0)}"
                      : beforeValue > 0
                          ? beforeValue.toStringAsFixed(0)
                          : afterValue.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
