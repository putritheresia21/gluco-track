import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class GlucoseChart extends StatefulWidget {
  const GlucoseChart({super.key});

  @override
  State<GlucoseChart> createState() => GlucoseChartState();
}

class GlucoseChartState extends State<GlucoseChart> {
  List<Glucoserecord> beforeMeal = [];
  List<Glucoserecord> afterMeal = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User Belum Login.")),
      );
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('glucose_records')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .get();

    final records = snapshot.docs
        .map((doc) => Glucoserecord.fromMap(doc.id, doc.data()))
        .toList();

    setState(() {
      beforeMeal = records
          .where((record) => record.condition == GlucoseCondition.beforeMeal)
          .toList();
      afterMeal = records
          .where((record) => record.condition == GlucoseCondition.afterMeal)
          .toList();
      loading = false;
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget buildChart(){
    final allRecords = [...beforeMeal, ...afterMeal];
    allRecords.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    final uniqueDates = allRecords.map((e){
      return DateTime(e.timeStamp.year, e.timeStamp.month, e.timeStamp.day);
    }).toSet().toList();
    final barGroups = uniqueDates.asMap().entries.map((entry){
      final index = entry.key;
      final date = entry.value;

      final before = beforeMeal.firstWhere(
        (e) => isSameDay(e.timeStamp, date),
        orElse: () => Glucoserecord.empty());
      final after = afterMeal.firstWhere(
        (e) => isSameDay(e.timeStamp, date),
        orElse: () => Glucoserecord.empty());
      final bars = <BarChartRodData>[];
      if (before.id != '') {
        bars.add(BarChartRodData(
          toY: before.glucoseLevel,
          color: Colors.red,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ));
      }
      if (after.id != '') {
        bars.add(BarChartRodData(
          toY: after.glucoseLevel,
          color: Colors.orange,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ));
      }
      return BarChartGroupData(x: index, barRods: bars, barsSpace: 4);
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        maxY: 250,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData( 
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < uniqueDates.length) {
                  final d = uniqueDates[index];
                  return Text('${d.day}/${d.month}/${d.year}',
                    style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
              reservedSize: 32,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex){
              return BarTooltipItem(
                rod.toY.toStringAsFixed(1),
                TextStyle( 
                  color: rod.color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Glucose Chart"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : beforeMeal.isEmpty && afterMeal.isEmpty
              ? const Center(child: Text("No records found."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Perbandingan Glukosa Sebelum dan Sesudah Makan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(height: 300, child: buildChart()),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.circle, color: Colors.orange, size: 10),
                          SizedBox(width: 4),
                          Text("Sebelum Makan"),
                          SizedBox(width: 16),
                          Icon(Icons.circle, color: Colors.red, size: 10),
                          SizedBox(width: 4),
                          Text("Sesudah Makan"),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
