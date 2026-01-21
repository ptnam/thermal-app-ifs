import 'package:flutter/material.dart';
import 'package:thermal_mobile/presentation/navigation/bottom_navigation.dart';
import 'package:thermal_mobile/presentation/ui/camera/camera_page.dart';
import 'package:thermal_mobile/presentation/ui/chart/chart_page.dart';
import 'package:thermal_mobile/presentation/ui/home/home_page.dart';
import 'package:thermal_mobile/presentation/ui/notification/notification_page.dart';
import 'package:thermal_mobile/presentation/ui/report/report_page.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = [
    const HomePage(),
    const CameraPage(),
    // const ChartPage(),
    const NotificationPage(),
    const ReportPage(),
    // const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppDrawerService.scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Positioned(
            child: IndexedStack(index: _index, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigation(
          currentIndex: _index,
          onTap: (i) {
            setState(() {
              _index = i;
            });
          },
        ),
      ),
    );
  }
}
