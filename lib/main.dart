import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'user/login.dart';

// นำเข้าหน้าต่าง ๆ ที่ต้องใช้
import 'admin/inspection_history.dart';
import 'admin/dashboard.dart';
import 'admin/fire_tank_status.dart';
import 'user/form_check.dart';
import 'admin/Fire_tank_management.dart';
import 'admin/buildings_management.dart';
import 'admin/fire_tank_types.dart';
import 'admin/tank_chart_screen.dart'; // เพิ่มหน้านี้เข้ามา

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ใช้ PathUrlStrategy เพื่อให้ URL ไม่มีเครื่องหมาย #
  setUrlStrategy(PathUrlStrategy());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firecheck System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // เปลี่ยนตรงนี้
      onGenerateRoute: (RouteSettings settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == '/user') {
          final tankId = uri.queryParameters['tankId'];
          if (tankId == null) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('ข้อผิดพลาด')),
                body: const Center(
                  child: Text('Tank ID ไม่ถูกต้องหรือไม่ได้ระบุ.'),
                ),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => FormCheckPage(tankId: tankId),
          );
        }

        switch (uri.path) {
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/firetankstatus':
            return MaterialPageRoute(
                builder: (context) => FireTankStatusPage());
          case '/inspectionhistory':
            return MaterialPageRoute(
                builder: (context) => InspectionHistoryPage());
          case '/fire_tank_management':
            return MaterialPageRoute(
                builder: (context) => FireTankManagementPage());
          case '/BuildingManagement':
            return MaterialPageRoute(
                builder: (context) => BuildingManagementScreen());
          case '/FireTankTypes':
            return MaterialPageRoute(builder: (context) => FireTankTypes());
          case '/FireTankStatusPage':
            return MaterialPageRoute(
                builder: (context) => FireTankStatusPage());
          case '/TankChartScreen':
            return MaterialPageRoute(
                builder: (context) => const TankChartScreen());
          default:
            return MaterialPageRoute(
                builder: (context) => const DashboardPage());
        }
      },
    );
  }
}
