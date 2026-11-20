import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/supabase_client.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Proteksi error handling global saat bootstrap agar Android tidak force close
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Peringatan: Gagal initializeDateFormatting: $e');
  }

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Peringatan: Gagal inisialisasi SupabaseConfig saat startup: $e');
  }

  runApp(
    const ProviderScope(
      child: TransaksiSawitApp(),
    ),
  );
}

class TransaksiSawitApp extends StatelessWidget {
  const TransaksiSawitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RamSawit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}
