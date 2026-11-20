import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/main_layout_page.dart';
import 'auth_controller.dart';
import 'login_page.dart';

/// Gerbang Autentikasi aplikasi.
/// Memeriksa status sesi pengguna saat aplikasi dimuat.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
              SizedBox(height: 16),
              Text(
                'Memuat sesi pengguna...',
                style: TextStyle(
                  color: AppColors.inkMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const MainLayoutPage();
    }

    return const LoginPage();
  }
}
