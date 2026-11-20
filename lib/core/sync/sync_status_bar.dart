import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaksi_sawit_app/core/theme/app_theme.dart';
import 'package:transaksi_sawit_app/core/sync/sync_engine.dart';
import 'package:transaksi_sawit_app/core/supabase_client.dart';
import 'package:transaksi_sawit_app/features/auth/auth_controller.dart';

/// Widget bilah status sinkronisasi & jaringan offline-first
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncEngineProvider);
    final authState = ref.watch(authControllerProvider);
    final isDemoMode = !SupabaseConfig.isConfigured;
    final isDemoSession = isDemoMode && authState.profile != null;

    // Konfigurasi visual berdasarkan status
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    if (syncState.status == SyncStatus.syncing) {
      bgColor = AppColors.primary.withValues(alpha: 0.12);
      textColor = AppColors.primary;
      icon = Icons.sync;
      message = 'Menyelaraskan data offline...';
    } else if (isDemoSession) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
      icon = Icons.cloud_off_outlined;
      message = syncState.unsyncedCount > 0
          ? '${syncState.unsyncedCount} transaksi tersimpan di database lokal (Mode Demo)'
          : 'Mode Demo (Penyimpanan Data Hanya Berlaku di Lokal)';
    } else if (syncState.unsyncedCount > 0) {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade900;
      icon = Icons.cloud_upload_outlined;
      message = '${syncState.unsyncedCount} transaksi tersimpan lokal (menunggu koneksi)';
    } else if (syncState.status == SyncStatus.offline) {
      bgColor = isDemoMode ? Colors.orange.shade50 : Colors.grey.shade100;
      textColor = isDemoMode ? Colors.orange.shade900 : Colors.grey.shade700;
      icon = Icons.cloud_off_outlined;
      message = isDemoMode
          ? 'Mode Demo (Penyimpanan Data Hanya Berlaku di Lokal)'
          : 'Mode Offline (Data tersimpan di database lokal)';
    } else if (syncState.status == SyncStatus.error) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade900;
      icon = Icons.error_outline;
      message = syncState.errorMessage ?? 'Gagal melakukan sinkronisasi data';
    } else {
      // Idle & tersinkron sempurna
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.cloud_done_outlined;
      message = 'Data tersinkron sempurna';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: textColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (syncState.status == SyncStatus.syncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              ref.read(syncEngineProvider.notifier).syncNow();
              if (isDemoMode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sinkronisasi gagal: Aplikasi sedang dalam Mode Demo. Data hanya disimpan di database lokal perangkat.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 14, color: textColor),
                  const SizedBox(width: 4),
                  Text(
                    'Sinkron',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
