import 'package:drift/drift.dart';

/// Metadata sinkronisasi untuk semua tabel offline-first
mixin SyncColumns on Table {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  TextColumn get deviceId => text().nullable()();

  /// Waktu terakhir data diupdate secara lokal
  DateTimeColumn get localUpdatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Tabel Master Penjual / Petani Lokal
class LocalPenjual extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  TextColumn get nama => text().withLength(min: 1, max: 100)();
  TextColumn get noTelepon => text().nullable()();
  TextColumn get alamat => text().nullable()();
  TextColumn get catatan => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Master Jenis Buah Lokal
class LocalJenisBuah extends Table with SyncColumns {
  IntColumn get id => integer()(); // 1, 2, 3
  TextColumn get kode => text().withLength(min: 1, max: 10)();
  TextColumn get nama => text().withLength(min: 1, max: 50)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Transaksi Pembelian TBS Lokal
class LocalTransaksi extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  TextColumn get kodeTransaksi => text().unique()();
  TextColumn get penjualId => text()();
  DateTimeColumn get tanggalTransaksi => dateTime()();
  TextColumn get status => text().withDefault(const Constant('selesai'))(); // 'selesai' | 'dibatalkan'
  TextColumn get alasanBatal => text().nullable()();
  TextColumn get jenisPembayaran => text().withDefault(const Constant('tunai'))(); // 'tunai' | 'transfer'
  TextColumn get catatan => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Transaksi Item Lokal
class LocalTransaksiItem extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  TextColumn get transaksiId => text()();
  IntColumn get jenisBuahId => integer()();
  TextColumn get hargaPerKg => text()(); // Disimpan as String Decimal
  TextColumn get beratKg => text()(); // Disimpan as String Decimal
  TextColumn get beratKotorKg => text().nullable()();
  TextColumn get persenPotongan => text().nullable()();
  TextColumn get nilaiPotonganKg => text().nullable()();
  TextColumn get subtotal => text()(); // Disimpan as String Decimal
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Master Pabrik Lokal
class LocalPabrik extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  TextColumn get nama => text().withLength(min: 1, max: 100)();
  TextColumn get lokasi => text().nullable()();
  TextColumn get kontak => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Pengiriman Pabrik Lokal
class LocalPengirimanPabrik extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  TextColumn get noSpb => text().unique()();
  TextColumn get pabrikId => text()();
  DateTimeColumn get tanggalKirim => dateTime()();
  TextColumn get noKendaraan => text()();
  TextColumn get namaSupir => text()();
  TextColumn get status => text().withDefault(const Constant('dalam_perjalanan'))();
  TextColumn get beratKirimKg => text()(); // Decimal
  TextColumn get beratTimbangPabrikKg => text().nullable()(); // Decimal
  TextColumn get toleransiSusutPersen => text().nullable()(); // Decimal
  TextColumn get hargaPerKg => text().nullable()(); // Decimal
  TextColumn get potonganSortasiPersen => text().nullable()(); // Decimal
  TextColumn get potonganSortasiKg => text().nullable()(); // Decimal
  TextColumn get potonganLainnyaNominal => text().nullable()(); // Decimal
  TextColumn get catatanPotonganLainnya => text().nullable()();
  TextColumn get totalNilaiPenjualan => text().nullable()(); // Decimal
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Jenis Pengeluaran Lokal
class LocalJenisPengeluaran extends Table with SyncColumns {
  IntColumn get id => integer()();
  TextColumn get nama => text().withLength(min: 1, max: 50)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Pengeluaran Operasional Lokal
class LocalPengeluaran extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  IntColumn get jenisPengeluaranId => integer()();
  TextColumn get nominal => text()(); // Decimal
  DateTimeColumn get tanggal => dateTime()();
  TextColumn get keterangan => text()();
  TextColumn get metodePembayaran => text().withDefault(const Constant('tunai'))(); // 'tunai' | 'non_tunai'
  TextColumn get status => text().withDefault(const Constant('aktif'))();
  TextColumn get alasanBatal => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Topup Saldo / Kas Lokal
class LocalTopupSaldo extends Table with SyncColumns {
  TextColumn get id => text()(); // UUID String
  TextColumn get nominal => text()(); // Decimal
  DateTimeColumn get tanggal => dateTime()();
  TextColumn get keterangan => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('aktif'))();
  TextColumn get alasanBatal => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
