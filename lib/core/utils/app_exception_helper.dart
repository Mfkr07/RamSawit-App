import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper terpusat untuk menerjemahkan error Supabase, Postgrest, jaringan,
/// dan general exception menjadi pesan bahasa Indonesia yang komunikatif
/// bagi pengguna non-teknis (kasir / petani / staf lapangan).
class AppExceptionHelper {
  /// Mengonversi sembarang objek Exception/Error menjadi pesan ramah pengguna
  static String toUserFriendlyMessage(dynamic error) {
    if (error == null) return 'Terjadi kendala yang tidak diketahui.';

    // 1. Supabase Auth Exceptions
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials') ||
          msg.contains('invalid email or password')) {
        return 'Email atau kata sandi tidak cocok. Silakan periksa kembali.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Alamat email belum dikonfirmasi. Silakan periksa kotak masuk email Anda.';
      }
      if (msg.contains('user already registered') ||
          msg.contains('email already in use')) {
        return 'Alamat email ini sudah terdaftar di sistem.';
      }
      if (msg.contains('network') || msg.contains('connection')) {
        return 'Gagal terhubung ke server autentikasi. Periksa koneksi internet Anda.';
      }
      if (msg.contains('too many requests') || msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan masuk. Silakan tunggu beberapa saat sebelum mencoba lagi.';
      }
      return 'Gagal melakukan autentikasi: ${error.message}';
    }

    // 2. Supabase Postgrest (Database) Exceptions
    if (error is PostgrestException) {
      final code = error.code ?? '';
      final msg = error.message.toLowerCase();

      // Kode unik duplikasi data (PostgreSQL unique_violation: 23505)
      if (code == '23505' || msg.contains('duplicate key')) {
        if (msg.contains('kode_transaksi')) {
          return 'Kode transaksi ini sudah tercatat sebelumnya. Silakan refresh halaman.';
        }
        if (msg.contains('transaksi_id') && msg.contains('jenis_buah_id')) {
          return 'Jenis buah ini sudah dipilih pada transaksi yang sama.';
        }
        return 'Data yang Anda masukkan sudah terdaftar sebelumnya di sistem.';
      }

      // Foreign key violation (PostgreSQL foreign_key_violation: 23503)
      if (code == '23503' || msg.contains('violates foreign key')) {
        return 'Data tidak dapat dihapus atau diubah karena masih terkait dengan transaksi lain.';
      }

      // Check constraint violation (PostgreSQL check_violation: 23514)
      if (code == '23514' || msg.contains('check constraint')) {
        return 'Nilai input tidak sesuai aturan validasi (misal berat harus lebih dari 0 kg).';
      }

      // Row not found (PGRST116)
      if (code == 'PGRST116' || msg.contains('0 rows')) {
        return 'Data yang diminta tidak ditemukan di database.';
      }

      // Izin akses RLS (PostgreSQL 42501)
      if (code == '42501' || msg.contains('permission denied')) {
        return 'Anda tidak memiliki hak akses yang cukup untuk melakukan tindakan ini.';
      }

      return 'Kendala database: ${error.message}';
    }

    // 3. Network & Connection Issues
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection refused') ||
        errorString.contains('clientexception') ||
        errorString.contains('networkerror') ||
        errorString.contains('xmlhttprequest') ||
        errorString.contains('network is unreachable')) {
      return 'Tidak dapat terhubung ke server database. Periksa koneksi internet Anda.';
    }

    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Waktu koneksi habis. Server memerlukan waktu terlalu lama untuk merespons.';
    }

    // 4. Exception umum yang sudah berformat pesan bahasa Indonesia
    if (error is Exception) {
      final clean = error.toString().replaceFirst('Exception: ', '').trim();
      if (clean.isNotEmpty) return clean;
    }

    return 'Terjadi kendala saat memproses data. Silakan coba beberapa saat lagi.';
  }
}
