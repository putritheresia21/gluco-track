import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/pages/ReminderSettingsPage.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:glucotrack_app/Widget/CustomCard.dart';
import 'package:intl/intl.dart';

class GlucoseHourlyChart extends StatefulWidget {
  final List<Glucoserecord> records;

  const GlucoseHourlyChart({super.key, required this.records});

  @override
  State<GlucoseHourlyChart> createState() => _GlucoseHourlyChartState();
}

class _GlucoseHourlyChartState extends State<GlucoseHourlyChart> {
  // Filter for records from today (00:00 to 23:59)
  List<Glucoserecord> get _todayRecords {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final filtered = widget.records.where((r) {
      return r.timeStamp.isAfter(startOfDay) &&
          r.timeStamp.isBefore(endOfDay);
    }).toList();

    // Sort by time ascending
    filtered.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Reminder Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Glucose Trend',
                style: FontUtils.style(
                  size: FontSize.lg,
                  weight: FontWeightType.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReminderSettingsPage(),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF2C7796),
                    size: 20,
                  ),
                ),
                tooltip: 'Set Reminder',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Chart
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                LineChart(
                  _mainData(),
                ),
                if (_todayRecords.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'No data for today',
                        style: FontUtils.style(
                          size: FontSize.md,
                          color: Colors.grey,
                          weight: FontWeightType.medium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xffe7e8ec),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 6, // Every 6 hours
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = '00:00';
                  break;
                case 6:
                  text = '06:00';
                  break;
                case 12:
                  text = '12:00';
                  break;
                case 18:
                  text = '18:00';
                  break;
                default:
                  return Container();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50, // 0, 50, 100, 150...
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              if (value % 100 == 0) {
                 return Text('${value.toInt()}', style: style);
              }
              return Container();
            },
            reservedSize: 32,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: 300, // Reasonable max for glucose
      lineBarsData: [
        LineChartBarData(
          spots: _getSpots(),
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Color(0xFF2C7796), Color(0xFF62CE54)],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2C7796).withOpacity(0.3),
                const Color(0xFF62CE54).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              
              // Find original record to get exact time?
              // For now, just format the X (hour) back to time
              final hour = flSpot.x.toInt();
              final minute = ((flSpot.x - hour) * 60).toInt();
              final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

              return LineTooltipItem(
                '$timeStr\n${flSpot.y.toInt()} mg/dL',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return _todayRecords.map((record) {
      final hour = record.timeStamp.hour;
      final minute = record.timeStamp.minute;
      final x = hour + (minute / 60.0);
      return FlSpot(x, record.glucoseLevel);
    }).toList();
  }
}
