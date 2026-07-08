import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/constants/strings.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/repositories/auth_repository.dart';
import 'package:thermal_mobile/presentation/ui/login/login_screen.dart';
import 'package:thermal_mobile/main.dart' as app_main;
import 'package:thermal_mobile/presentation/bloc/user/user_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/user/user_state.dart';
import 'package:thermal_mobile/presentation/widgets/user_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom drawer widget có thể tái sử dụng
/// Sử dụng AppDrawerService để mở drawer từ bất kỳ đâu
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final user = state.currentUser;
                    final userName = user?.fullName ?? user?.userName ?? 'User';
                    final userRole =
                        user?.roleName ?? user?.role?.name ?? 'Admin';
                    final avatarUrl = user?.avatarUrl;

                    return DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.drawerBackgroundHeader,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          UserAvatar(
                            avatarUrl: avatarUrl,
                            name: userName,
                            radius: 30,
                            borderColor: Colors.white,
                            borderWidth: 2,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (app_main.isIslgEnabled) ...[
                            const SizedBox(height: 4),
                            Text(
                              userRole,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                if (app_main.isIslgEnabled)
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text(
                      'Cấu hình Server',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/config');
                    },
                  ),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final roleName =
                        (state.currentUser?.roleName ??
                                state.currentUser?.role?.name ??
                                '')
                            .toLowerCase();
                    final hasManagerPermission =
                        roleName == 'manager' || roleName == 'admin';

                    return FutureBuilder<bool>(
                      future: getIt<AuthRepository>().isUserLoginActive(),
                      builder: (context, snapshot) {
                        final isUserLoggedIn = snapshot.data ?? false;
                        if (!isUserLoggedIn || !hasManagerPermission) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            // ListTile(
                            //   leading: const Icon(
                            //     Icons.location_on,
                            //     color: Colors.white,
                            //   ),
                            //   title: const Text(
                            //     'Khu vực',
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            //   onTap: () {
                            //     Navigator.pop(context);
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (_) => const AreaManagerScreen(),
                            //       ),
                            //     );
                            //   },
                            // ),
                            // ListTile(
                            //   leading: const Icon(
                            //     Icons.videocam,
                            //     color: Colors.white,
                            //   ),
                            //   title: const Text(
                            //     'Camera',
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            //   onTap: () {
                            //     Navigator.pop(context);
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (_) => const CameraManagerScreen(),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.notifications_active, color: Colors.white),
                //   title: const Text(
                //     'Vision Notifications',
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, '/vision-notification');
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.white),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(AppStrings.privacyPolicyUrl),
                      mode: LaunchMode.externalApplication,
                    );
                    // Navigate to camera
                  },
                ),
                FutureBuilder<bool>(
                  future: getIt<AuthRepository>().isUserLoginActive(),
                  builder: (context, snapshot) {
                    final isUserLoggedIn = snapshot.data ?? false;

                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            isUserLoggedIn ? Icons.logout : Icons.login,
                            color: isUserLoggedIn ? Colors.red : Colors.white,
                          ),
                          title: Text(
                            isUserLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                            style: TextStyle(
                              color: isUserLoggedIn ? Colors.red : Colors.white,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (isUserLoggedIn) {
                              _showLogoutDialog(context);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(
                                    authRepository: getIt<AuthRepository>(),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(
          'Xác nhận đăng xuất',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
          style: TextStyle(color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
          ),
          FilledButton(
            onPressed: () => _handleLogout(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close dialog

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Unregister FCM token first
      await app_main.messagingService.unregisterToken();

      final authRepository = getIt<AuthRepository>();
      await authRepository.logout();
      app_main.notifyAuthSessionChanged();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      resetBlocInstances();
      app_main.navigateToLogin();
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context).pop(); // Close loading dialog
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
