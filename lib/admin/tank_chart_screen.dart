import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TankChartScreen extends StatefulWidget {
  const TankChartScreen({super.key});

  @override
  State<TankChartScreen> createState() => _TankChartScreenState();
}

class _TankChartScreenState extends State<TankChartScreen> {
  int total = 0;
  int checked = 0;
  int unchecked = 0;
  int damaged = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTankData();
  }

  Future<void> fetchTankData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('firetank_Collection')
          .doc('status')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          total = data['total'] ?? 0;
          checked = data['checked'] ?? 0;
          unchecked = data['unchecked'] ?? 0;
          damaged = data['damaged'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: total.toDouble(),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(toY: total.toDouble(), color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                        toY: checked.toDouble(), color: Colors.green),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                        toY: unchecked.toDouble(), color: Colors.orange),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(toY: damaged.toDouble(), color: Colors.red),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('ตรวจสอบแล้ว');
                        case 1:
                          return const Text('ยังไม่ตรวจสอบ');
                        case 2:
                          return const Text('ชำรุด');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
            ),
          );
  }
}
