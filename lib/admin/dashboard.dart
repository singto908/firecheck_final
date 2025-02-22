import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firecheck_setup/admin/dashboard_section/damage_info_section.dart';
import 'package:firecheck_setup/admin/dashboard_section/status_summary.dart';
import 'package:firecheck_setup/admin/dashboard_section/scheduleBox.dart';
import 'package:firecheck_setup/admin/fire_tank_status.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int remainingTime = FireTankStatusPageState.calculateRemainingTime();
  int remainingQuarterTimeInSeconds =
      FireTankStatusPageState.calculateNextQuarterEnd()
          .difference(DateTime.now())
          .inSeconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('firetank_Collection')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('ไม่พบข้อมูลถังดับเพลิง'));
          }

          final tanks = snapshot.data!.docs;
          final totalTanks = tanks.length;
          final checkedCount =
              tanks.where((doc) => doc['status'] == 'ตรวจสอบแล้ว').length;
          final brokenCount =
              tanks.where((doc) => doc['status'] == 'ชำรุด').length;
          final repairCount =
              tanks.where((doc) => doc['status'] == 'ส่งซ่อม').length;
          final otherCount =
              totalTanks - checkedCount - brokenCount - repairCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScheduleBox(
                  remainingTime: remainingTime,
                  remainingQuarterTime: remainingQuarterTimeInSeconds,
                ),
                const SizedBox(height: 10),
                StatusSummaryWidget(
                  totalTanks: totalTanks,
                  checkedCount: checkedCount,
                  brokenCount: brokenCount,
                  repairCount: repairCount,
                ),
                const SizedBox(height: 20),
                const DamageInfoSection(),
                const SizedBox(height: 20),
                const Text(
                  'กราฟวงกลมแสดงสถานะถังดับเพลิง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: checkedCount.toDouble(),
                                title: '$checkedCount',
                                color: Colors.green,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: brokenCount.toDouble(),
                                title: '$brokenCount',
                                color: Colors.red,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: repairCount.toDouble(),
                                title: '$repairCount',
                                color: Colors.orange,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: otherCount.toDouble(),
                                title: '$otherCount',
                                color: Colors.grey,
                                radius: 50,
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: const [
                          LegendItem(color: Colors.green, text: 'ตรวจสอบแล้ว'),
                          LegendItem(color: Colors.red, text: 'ชำรุด'),
                          LegendItem(color: Colors.orange, text: 'ส่งซ่อม'),
                          LegendItem(color: Colors.grey, text: 'อื่นๆ'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[850],
            ),
            child: const Text(
              'เมนู',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('ประวัติการตรวจสอบ'),
            onTap: () {
              Navigator.pushNamed(context, '/inspectionhistory');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('การจัดการถังดับเพลิง'),
            onTap: () {
              Navigator.pushNamed(context, '/fire_tank_management');
            },
          ),
          ListTile(
            leading: const Icon(Icons.apartment),
            title: const Text('การจัดการอาคาร'),
            onTap: () {
              Navigator.pushNamed(context, '/BuildingManagement');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: const Text('ประเภทถังดับเพลิง'),
            onTap: () {
              Navigator.pushNamed(context, '/FireTankTypes');
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
