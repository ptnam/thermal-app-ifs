import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/themes.dart';
import 'package:thermal_mobile/core/services/firebase_messaging_service.dart';
import 'package:thermal_mobile/core/services/session_expiration_service.dart';
import 'package:thermal_mobile/data/network/user/user_token_api_service.dart';
import 'package:thermal_mobile/firebase_options.dart';
import 'package:thermal_mobile/presentation/bloc/user/user_bloc.dart';
import 'package:thermal_mobile/presentation/navigation/main_shell.dart';
import 'package:thermal_mobile/presentation/routes/app_routes.dart';
import 'package:thermal_mobile/presentation/ui/login/login_screen.dart';
import 'di/injection.dart';
import 'domain/repositories/auth_repository.dart';

late GlobalKey<NavigatorState> _navigatorKey;

/// Global FirebaseMessagingService instance
late FirebaseMessagingService messagingService;

/// Server config entry points are visible in the normal manual-login flow.
bool isFirestoreAutoLoginMode = false;

/// Manual-login mode is always enabled now.
bool isIslgEnabled = true;

/// Increments whenever active auth context changes.
final ValueNotifier<int> authSessionVersion = ValueNotifier<int>(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling for hot restart
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Benign on iOS: FirebaseAppDelegateProxyEnabled auto-configures the
    // "[DEFAULT]" app natively before this Dart check runs (and again on
    // hot restart), so Firebase.apps can read empty right before this call
    // throws duplicate-app. Not a real failure - safe to ignore.
    debugPrint(
      'ℹ️ Firebase already initialized natively, skipping duplicate init: $e',
    );
  }

  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await configureDependencies();

  // Initialize Firebase Messaging
  messagingService = FirebaseMessagingService();

  // Configure with dependencies
  messagingService.configure(userTokenApiService: getIt<UserTokenApiService>());

  await messagingService.initialize();

  // Setup notification tap handler
  messagingService.onNotificationTap = (data) {
    debugPrint('Notification tapped with data: $data');
    // Handle navigation based on notification data
    // Example: Navigate to specific screen based on notification type
  };

  // Setup token refresh handler
  messagingService.onTokenRefresh = (token) {
    debugPrint('New FCM token: $token');
    // Token is automatically sent to server when user is logged in
  };

  final authRepo = getIt<AuthRepository>();
  final initialLoggedIn = await authRepo.hasValidSession();

  _navigatorKey = GlobalKey<NavigatorState>();
  sessionExpiredVersion.addListener(_handleSessionExpired);
  runApp(MyApp(initialLoggedIn: initialLoggedIn, navigatorKey: _navigatorKey));
}

void _handleSessionExpired() {
  resetBlocInstances();
  notifyAuthSessionChanged();
  navigateToLogin();
}

class MyApp extends StatelessWidget {
  final bool initialLoggedIn;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    this.initialLoggedIn = false,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (context) => getIt<UserBloc>()),
        // Thêm các BLoC khác ở đây nếu cần
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'IFS - AISOFT',
        theme: AppTheme.darkTheme,
        navigatorKey: navigatorKey,
        routes: routes,
        home: initialLoggedIn
            ? const MainShell()
            : LoginScreen(authRepository: getIt<AuthRepository>()),
      ),
    );
  }
}

// Helper function to navigate to login from anywhere
void navigateToLogin() {
  _navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) =>
          LoginScreen(authRepository: getIt<AuthRepository>()),
    ),
    (route) => false,
  );
}

void notifyAuthSessionChanged() {
  authSessionVersion.value = authSessionVersion.value + 1;
}
