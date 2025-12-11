import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/SupabaseService.dart';
import 'package:intl/intl.dart';

class WeeklySummaryCard extends StatefulWidget {
  final bool isCompactView;
  final VoidCallback? onTap;

  const WeeklySummaryCard({
    super.key,
    this.isCompactView = false,
    this.onTap,
  });

  @override
  State<WeeklySummaryCard> createState() => _WeeklySummaryCardState();
}

class _WeeklySummaryCardState extends State<WeeklySummaryCard> {
  final Glucoserepository _repository = Glucoserepository();
  List<Glucoserecord> allRecords = [];
  bool isLoading = true;
  int? tappedBarIndex;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() => isLoading = true);

    try {
      final userId =
          SupabaseService.client.auth.currentUser?.id ?? 'default_user';
      final records = await _repository.getAllGlucoseRecords(userId);

      if (mounted) {
        setState(() {
          allRecords = records;
          allRecords.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading records: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Glucoserecord> getWeeklyRecords() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    startOfWeek =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return allRecords.where((record) {
      return record.timeStamp
              .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          record.timeStamp.isBefore(startOfWeek.add(const Duration(days: 7)));
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C7796),
          ),
        ),
      );
    }

    double weeklyAvg = getWeeklyAverage();
    Map<int, List<Glucoserecord>> weeklyGrouped = getWeeklyGroupedRecords();

    if (widget.isCompactView) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                'Weekly Summary',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    weeklyAvg > 0 ? weeklyAvg.toStringAsFixed(0) : '-',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'mg/dL',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
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
                fontSize: 28,
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
                    fontSize: 72,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (tappedBarIndex == index && (beforeValue > 0 || afterValue > 0))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 5),
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
              ),
            ),
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
                  height:
                      afterHeight > 5 ? afterHeight : (afterValue > 0 ? 5 : 0),
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
