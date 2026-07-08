import 'package:flutter/material.dart';
import 'package:thermal_mobile/main.dart' as app_main;
import 'package:thermal_mobile/presentation/navigation/bottom_navigation.dart';
import 'package:thermal_mobile/presentation/ui/camera/camera_page.dart';
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
  int _authVersion = 0;
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = AppDrawerService.createAndBindScaffoldKey();
    _authVersion = app_main.authSessionVersion.value;
    app_main.authSessionVersion.addListener(_onAuthSessionChanged);
  }

  @override
  void dispose() {
    app_main.authSessionVersion.removeListener(_onAuthSessionChanged);
    AppDrawerService.unbindScaffoldKey(_scaffoldKey);
    super.dispose();
  }

  void _onAuthSessionChanged() {
    if (!mounted) return;
    setState(() {
      _authVersion = app_main.authSessionVersion.value;
      _index = 0;
    });
  }

  List<Widget> get _pages => [
    HomePage(key: ValueKey('home_$_authVersion')),
    CameraPage(key: ValueKey('camera_$_authVersion')),
    NotificationPage(key: ValueKey('notification_$_authVersion')),
    ReportPage(key: ValueKey('report_$_authVersion')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
