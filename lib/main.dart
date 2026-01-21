import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/themes.dart';
import 'package:thermal_mobile/presentation/bloc/user/user_bloc.dart';
import 'package:thermal_mobile/presentation/navigation/main_shell.dart';
import 'package:thermal_mobile/presentation/routes/app_routes.dart';
import 'package:thermal_mobile/presentation/ui/login/login_screen.dart';
import 'di/injection.dart';
import 'domain/repositories/auth_repository.dart';

late GlobalKey<NavigatorState> _navigatorKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Decide initial screen based on cached session
  final authRepo = getIt<AuthRepository>();
  final hasSession = await authRepo.hasValidSession();

  _navigatorKey = GlobalKey<NavigatorState>();
  runApp(MyApp(initialLoggedIn: hasSession, navigatorKey: _navigatorKey));
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
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
        // Thêm các BLoC khác ở đây nếu cần
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Camera Vision',
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
      builder: (context) => LoginScreen(
        authRepository: getIt<AuthRepository>(),
      ),
    ),
    (route) => false,
  );
}

