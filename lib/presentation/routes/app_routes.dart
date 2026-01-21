import 'package:thermal_mobile/presentation/ui/setting/config_screen.dart';
import 'package:thermal_mobile/presentation/ui/setting/setting_page.dart';
import 'package:thermal_mobile/presentation/ui/vision_notification/vision_notification_list_screen.dart';

class AppRoutes {
  static const camera = '/camera';
  static const notification = '/notification';
  static const setting = '/setting';
  static const config = '/config';
  static const apiTest = '/api-test';
  static const login = '/login';
  static const visionNotification = '/vision-notification';
}

final routes = {
  // AppRoutes.camera: (_) => CameraPage(),
  // AppRoutes.notification: (_) => NotificationListPage(),
  AppRoutes.setting: (_) => SettingPage(),
  AppRoutes.config: (_) => const ConfigScreen(),
  AppRoutes.visionNotification: (_) => const VisionNotificationListScreen(),
  // AppRoutes.apiTest: (_) => const ApiTestPage(),
  // AppRoutes.main: (context) {
  //   return MultiBlocProvider(
  //     providers: [
  //       BlocProvider(
  //         create: (_) {
  //           return sl<BibleBloc>()..add(BibleInitEvent());
  //         },
  //       ),
  //     ],
  //     child: MainShell(),
  //   );
  // },
};
