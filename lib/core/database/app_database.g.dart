// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalPenjualTable extends LocalPenjual
    with TableInfo<$LocalPenjualTable, LocalPenjualData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPenjualTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noTeleponMeta = const VerificationMeta(
    'noTelepon',
  );
  @override
  late final GeneratedColumn<String> noTelepon = GeneratedColumn<String>(
    'no_telepon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alamatMeta = const VerificationMeta('alamat');
  @override
  late final GeneratedColumn<String> alamat = GeneratedColumn<String>(
    'alamat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nama,
    noTelepon,
    alamat,
    catatan,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_penjual';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPenjualData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('no_telepon')) {
      context.handle(
        _noTeleponMeta,
        noTelepon.isAcceptableOrUnknown(data['no_telepon']!, _noTeleponMeta),
      );
    }
    if (data.containsKey('alamat')) {
      context.handle(
        _alamatMeta,
        alamat.isAcceptableOrUnknown(data['alamat']!, _alamatMeta),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPenjualData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPenjualData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      noTelepon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no_telepon'],
      ),
      alamat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alamat'],
      ),
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalPenjualTable createAlias(String alias) {
    return $LocalPenjualTable(attachedDatabase, alias);
  }
}

class LocalPenjualData extends DataClass
    implements Insertable<LocalPenjualData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final String nama;
  final String? noTelepon;
  final String? alamat;
  final String? catatan;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPenjualData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.nama,
    this.noTelepon,
    this.alamat,
    this.catatan,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || noTelepon != null) {
      map['no_telepon'] = Variable<String>(noTelepon);
    }
    if (!nullToAbsent || alamat != null) {
      map['alamat'] = Variable<String>(alamat);
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPenjualCompanion toCompanion(bool nullToAbsent) {
    return LocalPenjualCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      nama: Value(nama),
      noTelepon: noTelepon == null && nullToAbsent
          ? const Value.absent()
          : Value(noTelepon),
      alamat: alamat == null && nullToAbsent
          ? const Value.absent()
          : Value(alamat),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      isActive: Value(isActive),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPenjualData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPenjualData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      noTelepon: serializer.fromJson<String?>(json['noTelepon']),
      alamat: serializer.fromJson<String?>(json['alamat']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'noTelepon': serializer.toJson<String?>(noTelepon),
      'alamat': serializer.toJson<String?>(alamat),
      'catatan': serializer.toJson<String?>(catatan),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPenjualData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? nama,
    Value<String?> noTelepon = const Value.absent(),
    Value<String?> alamat = const Value.absent(),
    Value<String?> catatan = const Value.absent(),
    bool? isActive,
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalPenjualData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    nama: nama ?? this.nama,
    noTelepon: noTelepon.present ? noTelepon.value : this.noTelepon,
    alamat: alamat.present ? alamat.value : this.alamat,
    catatan: catatan.present ? catatan.value : this.catatan,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPenjualData copyWithCompanion(LocalPenjualCompanion data) {
    return LocalPenjualData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      noTelepon: data.noTelepon.present ? data.noTelepon.value : this.noTelepon,
      alamat: data.alamat.present ? data.alamat.value : this.alamat,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPenjualData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('noTelepon: $noTelepon, ')
          ..write('alamat: $alamat, ')
          ..write('catatan: $catatan, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nama,
    noTelepon,
    alamat,
    catatan,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPenjualData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.noTelepon == this.noTelepon &&
          other.alamat == this.alamat &&
          other.catatan == this.catatan &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPenjualCompanion extends UpdateCompanion<LocalPenjualData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> nama;
  final Value<String?> noTelepon;
  final Value<String?> alamat;
  final Value<String?> catatan;
  final Value<bool> isActive;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPenjualCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.noTelepon = const Value.absent(),
    this.alamat = const Value.absent(),
    this.catatan = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPenjualCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String nama,
    this.noTelepon = const Value.absent(),
    this.alamat = const Value.absent(),
    this.catatan = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama);
  static Insertable<LocalPenjualData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? noTelepon,
    Expression<String>? alamat,
    Expression<String>? catatan,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (noTelepon != null) 'no_telepon': noTelepon,
      if (alamat != null) 'alamat': alamat,
      if (catatan != null) 'catatan': catatan,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPenjualCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? nama,
    Value<String?>? noTelepon,
    Value<String?>? alamat,
    Value<String?>? catatan,
    Value<bool>? isActive,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPenjualCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      catatan: catatan ?? this.catatan,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (noTelepon.present) {
      map['no_telepon'] = Variable<String>(noTelepon.value);
    }
    if (alamat.present) {
      map['alamat'] = Variable<String>(alamat.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPenjualCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('noTelepon: $noTelepon, ')
          ..write('alamat: $alamat, ')
          ..write('catatan: $catatan, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalJenisBuahTable extends LocalJenisBuah
    with TableInfo<$LocalJenisBuahTable, LocalJenisBuahData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalJenisBuahTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kodeMeta = const VerificationMeta('kode');
  @override
  late final GeneratedColumn<String> kode = GeneratedColumn<String>(
    'kode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    kode,
    nama,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_jenis_buah';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalJenisBuahData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kode')) {
      context.handle(
        _kodeMeta,
        kode.isAcceptableOrUnknown(data['kode']!, _kodeMeta),
      );
    } else if (isInserting) {
      context.missing(_kodeMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalJenisBuahData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalJenisBuahData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kode'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $LocalJenisBuahTable createAlias(String alias) {
    return $LocalJenisBuahTable(attachedDatabase, alias);
  }
}

class LocalJenisBuahData extends DataClass
    implements Insertable<LocalJenisBuahData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final int id;
  final String kode;
  final String nama;
  final bool isActive;
  const LocalJenisBuahData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.kode,
    required this.nama,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<int>(id);
    map['kode'] = Variable<String>(kode);
    map['nama'] = Variable<String>(nama);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalJenisBuahCompanion toCompanion(bool nullToAbsent) {
    return LocalJenisBuahCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      kode: Value(kode),
      nama: Value(nama),
      isActive: Value(isActive),
    );
  }

  factory LocalJenisBuahData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalJenisBuahData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<int>(json['id']),
      kode: serializer.fromJson<String>(json['kode']),
      nama: serializer.fromJson<String>(json['nama']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<int>(id),
      'kode': serializer.toJson<String>(kode),
      'nama': serializer.toJson<String>(nama),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalJenisBuahData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? id,
    String? kode,
    String? nama,
    bool? isActive,
  }) => LocalJenisBuahData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    kode: kode ?? this.kode,
    nama: nama ?? this.nama,
    isActive: isActive ?? this.isActive,
  );
  LocalJenisBuahData copyWithCompanion(LocalJenisBuahCompanion data) {
    return LocalJenisBuahData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      kode: data.kode.present ? data.kode.value : this.kode,
      nama: data.nama.present ? data.nama.value : this.nama,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalJenisBuahData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('kode: $kode, ')
          ..write('nama: $nama, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    kode,
    nama,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalJenisBuahData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.kode == this.kode &&
          other.nama == this.nama &&
          other.isActive == this.isActive);
}

class LocalJenisBuahCompanion extends UpdateCompanion<LocalJenisBuahData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> id;
  final Value<String> kode;
  final Value<String> nama;
  final Value<bool> isActive;
  const LocalJenisBuahCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.kode = const Value.absent(),
    this.nama = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  LocalJenisBuahCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String kode,
    required String nama,
    this.isActive = const Value.absent(),
  }) : kode = Value(kode),
       nama = Value(nama);
  static Insertable<LocalJenisBuahData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? id,
    Expression<String>? kode,
    Expression<String>? nama,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (kode != null) 'kode': kode,
      if (nama != null) 'nama': nama,
      if (isActive != null) 'is_active': isActive,
    });
  }

  LocalJenisBuahCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? id,
    Value<String>? kode,
    Value<String>? nama,
    Value<bool>? isActive,
  }) {
    return LocalJenisBuahCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kode.present) {
      map['kode'] = Variable<String>(kode.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalJenisBuahCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('kode: $kode, ')
          ..write('nama: $nama, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $LocalTransaksiTable extends LocalTransaksi
    with TableInfo<$LocalTransaksiTable, LocalTransaksiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kodeTransaksiMeta = const VerificationMeta(
    'kodeTransaksi',
  );
  @override
  late final GeneratedColumn<String> kodeTransaksi = GeneratedColumn<String>(
    'kode_transaksi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _penjualIdMeta = const VerificationMeta(
    'penjualId',
  );
  @override
  late final GeneratedColumn<String> penjualId = GeneratedColumn<String>(
    'penjual_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalTransaksiMeta = const VerificationMeta(
    'tanggalTransaksi',
  );
  @override
  late final GeneratedColumn<DateTime> tanggalTransaksi =
      GeneratedColumn<DateTime>(
        'tanggal_transaksi',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('selesai'),
  );
  static const VerificationMeta _alasanBatalMeta = const VerificationMeta(
    'alasanBatal',
  );
  @override
  late final GeneratedColumn<String> alasanBatal = GeneratedColumn<String>(
    'alasan_batal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jenisPembayaranMeta = const VerificationMeta(
    'jenisPembayaran',
  );
  @override
  late final GeneratedColumn<String> jenisPembayaran = GeneratedColumn<String>(
    'jenis_pembayaran',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tunai'),
  );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    kodeTransaksi,
    penjualId,
    tanggalTransaksi,
    status,
    alasanBatal,
    jenisPembayaran,
    catatan,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transaksi';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaksiData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kode_transaksi')) {
      context.handle(
        _kodeTransaksiMeta,
        kodeTransaksi.isAcceptableOrUnknown(
          data['kode_transaksi']!,
          _kodeTransaksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kodeTransaksiMeta);
    }
    if (data.containsKey('penjual_id')) {
      context.handle(
        _penjualIdMeta,
        penjualId.isAcceptableOrUnknown(data['penjual_id']!, _penjualIdMeta),
      );
    } else if (isInserting) {
      context.missing(_penjualIdMeta);
    }
    if (data.containsKey('tanggal_transaksi')) {
      context.handle(
        _tanggalTransaksiMeta,
        tanggalTransaksi.isAcceptableOrUnknown(
          data['tanggal_transaksi']!,
          _tanggalTransaksiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tanggalTransaksiMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('alasan_batal')) {
      context.handle(
        _alasanBatalMeta,
        alasanBatal.isAcceptableOrUnknown(
          data['alasan_batal']!,
          _alasanBatalMeta,
        ),
      );
    }
    if (data.containsKey('jenis_pembayaran')) {
      context.handle(
        _jenisPembayaranMeta,
        jenisPembayaran.isAcceptableOrUnknown(
          data['jenis_pembayaran']!,
          _jenisPembayaranMeta,
        ),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaksiData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaksiData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kodeTransaksi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kode_transaksi'],
      )!,
      penjualId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}penjual_id'],
      )!,
      tanggalTransaksi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal_transaksi'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      alasanBatal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alasan_batal'],
      ),
      jenisPembayaran: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis_pembayaran'],
      )!,
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalTransaksiTable createAlias(String alias) {
    return $LocalTransaksiTable(attachedDatabase, alias);
  }
}

class LocalTransaksiData extends DataClass
    implements Insertable<LocalTransaksiData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final String kodeTransaksi;
  final String penjualId;
  final DateTime tanggalTransaksi;
  final String status;
  final String? alasanBatal;
  final String jenisPembayaran;
  final String? catatan;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalTransaksiData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.kodeTransaksi,
    required this.penjualId,
    required this.tanggalTransaksi,
    required this.status,
    this.alasanBatal,
    required this.jenisPembayaran,
    this.catatan,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['kode_transaksi'] = Variable<String>(kodeTransaksi);
    map['penjual_id'] = Variable<String>(penjualId);
    map['tanggal_transaksi'] = Variable<DateTime>(tanggalTransaksi);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || alasanBatal != null) {
      map['alasan_batal'] = Variable<String>(alasanBatal);
    }
    map['jenis_pembayaran'] = Variable<String>(jenisPembayaran);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTransaksiCompanion toCompanion(bool nullToAbsent) {
    return LocalTransaksiCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      kodeTransaksi: Value(kodeTransaksi),
      penjualId: Value(penjualId),
      tanggalTransaksi: Value(tanggalTransaksi),
      status: Value(status),
      alasanBatal: alasanBatal == null && nullToAbsent
          ? const Value.absent()
          : Value(alasanBatal),
      jenisPembayaran: Value(jenisPembayaran),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTransaksiData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaksiData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      kodeTransaksi: serializer.fromJson<String>(json['kodeTransaksi']),
      penjualId: serializer.fromJson<String>(json['penjualId']),
      tanggalTransaksi: serializer.fromJson<DateTime>(json['tanggalTransaksi']),
      status: serializer.fromJson<String>(json['status']),
      alasanBatal: serializer.fromJson<String?>(json['alasanBatal']),
      jenisPembayaran: serializer.fromJson<String>(json['jenisPembayaran']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'kodeTransaksi': serializer.toJson<String>(kodeTransaksi),
      'penjualId': serializer.toJson<String>(penjualId),
      'tanggalTransaksi': serializer.toJson<DateTime>(tanggalTransaksi),
      'status': serializer.toJson<String>(status),
      'alasanBatal': serializer.toJson<String?>(alasanBatal),
      'jenisPembayaran': serializer.toJson<String>(jenisPembayaran),
      'catatan': serializer.toJson<String?>(catatan),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTransaksiData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? kodeTransaksi,
    String? penjualId,
    DateTime? tanggalTransaksi,
    String? status,
    Value<String?> alasanBatal = const Value.absent(),
    String? jenisPembayaran,
    Value<String?> catatan = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalTransaksiData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    kodeTransaksi: kodeTransaksi ?? this.kodeTransaksi,
    penjualId: penjualId ?? this.penjualId,
    tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
    status: status ?? this.status,
    alasanBatal: alasanBatal.present ? alasanBatal.value : this.alasanBatal,
    jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
    catatan: catatan.present ? catatan.value : this.catatan,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalTransaksiData copyWithCompanion(LocalTransaksiCompanion data) {
    return LocalTransaksiData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      kodeTransaksi: data.kodeTransaksi.present
          ? data.kodeTransaksi.value
          : this.kodeTransaksi,
      penjualId: data.penjualId.present ? data.penjualId.value : this.penjualId,
      tanggalTransaksi: data.tanggalTransaksi.present
          ? data.tanggalTransaksi.value
          : this.tanggalTransaksi,
      status: data.status.present ? data.status.value : this.status,
      alasanBatal: data.alasanBatal.present
          ? data.alasanBatal.value
          : this.alasanBatal,
      jenisPembayaran: data.jenisPembayaran.present
          ? data.jenisPembayaran.value
          : this.jenisPembayaran,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaksiData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('kodeTransaksi: $kodeTransaksi, ')
          ..write('penjualId: $penjualId, ')
          ..write('tanggalTransaksi: $tanggalTransaksi, ')
          ..write('status: $status, ')
          ..write('alasanBatal: $alasanBatal, ')
          ..write('jenisPembayaran: $jenisPembayaran, ')
          ..write('catatan: $catatan, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    kodeTransaksi,
    penjualId,
    tanggalTransaksi,
    status,
    alasanBatal,
    jenisPembayaran,
    catatan,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaksiData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.kodeTransaksi == this.kodeTransaksi &&
          other.penjualId == this.penjualId &&
          other.tanggalTransaksi == this.tanggalTransaksi &&
          other.status == this.status &&
          other.alasanBatal == this.alasanBatal &&
          other.jenisPembayaran == this.jenisPembayaran &&
          other.catatan == this.catatan &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalTransaksiCompanion extends UpdateCompanion<LocalTransaksiData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> kodeTransaksi;
  final Value<String> penjualId;
  final Value<DateTime> tanggalTransaksi;
  final Value<String> status;
  final Value<String?> alasanBatal;
  final Value<String> jenisPembayaran;
  final Value<String?> catatan;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTransaksiCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.kodeTransaksi = const Value.absent(),
    this.penjualId = const Value.absent(),
    this.tanggalTransaksi = const Value.absent(),
    this.status = const Value.absent(),
    this.alasanBatal = const Value.absent(),
    this.jenisPembayaran = const Value.absent(),
    this.catatan = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransaksiCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String kodeTransaksi,
    required String penjualId,
    required DateTime tanggalTransaksi,
    this.status = const Value.absent(),
    this.alasanBatal = const Value.absent(),
    this.jenisPembayaran = const Value.absent(),
    this.catatan = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kodeTransaksi = Value(kodeTransaksi),
       penjualId = Value(penjualId),
       tanggalTransaksi = Value(tanggalTransaksi);
  static Insertable<LocalTransaksiData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? kodeTransaksi,
    Expression<String>? penjualId,
    Expression<DateTime>? tanggalTransaksi,
    Expression<String>? status,
    Expression<String>? alasanBatal,
    Expression<String>? jenisPembayaran,
    Expression<String>? catatan,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (kodeTransaksi != null) 'kode_transaksi': kodeTransaksi,
      if (penjualId != null) 'penjual_id': penjualId,
      if (tanggalTransaksi != null) 'tanggal_transaksi': tanggalTransaksi,
      if (status != null) 'status': status,
      if (alasanBatal != null) 'alasan_batal': alasanBatal,
      if (jenisPembayaran != null) 'jenis_pembayaran': jenisPembayaran,
      if (catatan != null) 'catatan': catatan,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransaksiCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? kodeTransaksi,
    Value<String>? penjualId,
    Value<DateTime>? tanggalTransaksi,
    Value<String>? status,
    Value<String?>? alasanBatal,
    Value<String>? jenisPembayaran,
    Value<String?>? catatan,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalTransaksiCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      kodeTransaksi: kodeTransaksi ?? this.kodeTransaksi,
      penjualId: penjualId ?? this.penjualId,
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      status: status ?? this.status,
      alasanBatal: alasanBatal ?? this.alasanBatal,
      jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
      catatan: catatan ?? this.catatan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kodeTransaksi.present) {
      map['kode_transaksi'] = Variable<String>(kodeTransaksi.value);
    }
    if (penjualId.present) {
      map['penjual_id'] = Variable<String>(penjualId.value);
    }
    if (tanggalTransaksi.present) {
      map['tanggal_transaksi'] = Variable<DateTime>(tanggalTransaksi.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (alasanBatal.present) {
      map['alasan_batal'] = Variable<String>(alasanBatal.value);
    }
    if (jenisPembayaran.present) {
      map['jenis_pembayaran'] = Variable<String>(jenisPembayaran.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaksiCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('kodeTransaksi: $kodeTransaksi, ')
          ..write('penjualId: $penjualId, ')
          ..write('tanggalTransaksi: $tanggalTransaksi, ')
          ..write('status: $status, ')
          ..write('alasanBatal: $alasanBatal, ')
          ..write('jenisPembayaran: $jenisPembayaran, ')
          ..write('catatan: $catatan, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransaksiItemTable extends LocalTransaksiItem
    with TableInfo<$LocalTransaksiItemTable, LocalTransaksiItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransaksiItemTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transaksiIdMeta = const VerificationMeta(
    'transaksiId',
  );
  @override
  late final GeneratedColumn<String> transaksiId = GeneratedColumn<String>(
    'transaksi_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jenisBuahIdMeta = const VerificationMeta(
    'jenisBuahId',
  );
  @override
  late final GeneratedColumn<int> jenisBuahId = GeneratedColumn<int>(
    'jenis_buah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hargaPerKgMeta = const VerificationMeta(
    'hargaPerKg',
  );
  @override
  late final GeneratedColumn<String> hargaPerKg = GeneratedColumn<String>(
    'harga_per_kg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beratKgMeta = const VerificationMeta(
    'beratKg',
  );
  @override
  late final GeneratedColumn<String> beratKg = GeneratedColumn<String>(
    'berat_kg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beratKotorKgMeta = const VerificationMeta(
    'beratKotorKg',
  );
  @override
  late final GeneratedColumn<String> beratKotorKg = GeneratedColumn<String>(
    'berat_kotor_kg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _persenPotonganMeta = const VerificationMeta(
    'persenPotongan',
  );
  @override
  late final GeneratedColumn<String> persenPotongan = GeneratedColumn<String>(
    'persen_potongan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nilaiPotonganKgMeta = const VerificationMeta(
    'nilaiPotonganKg',
  );
  @override
  late final GeneratedColumn<String> nilaiPotonganKg = GeneratedColumn<String>(
    'nilai_potongan_kg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<String> subtotal = GeneratedColumn<String>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    transaksiId,
    jenisBuahId,
    hargaPerKg,
    beratKg,
    beratKotorKg,
    persenPotongan,
    nilaiPotonganKg,
    subtotal,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transaksi_item';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaksiItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaksi_id')) {
      context.handle(
        _transaksiIdMeta,
        transaksiId.isAcceptableOrUnknown(
          data['transaksi_id']!,
          _transaksiIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaksiIdMeta);
    }
    if (data.containsKey('jenis_buah_id')) {
      context.handle(
        _jenisBuahIdMeta,
        jenisBuahId.isAcceptableOrUnknown(
          data['jenis_buah_id']!,
          _jenisBuahIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jenisBuahIdMeta);
    }
    if (data.containsKey('harga_per_kg')) {
      context.handle(
        _hargaPerKgMeta,
        hargaPerKg.isAcceptableOrUnknown(
          data['harga_per_kg']!,
          _hargaPerKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hargaPerKgMeta);
    }
    if (data.containsKey('berat_kg')) {
      context.handle(
        _beratKgMeta,
        beratKg.isAcceptableOrUnknown(data['berat_kg']!, _beratKgMeta),
      );
    } else if (isInserting) {
      context.missing(_beratKgMeta);
    }
    if (data.containsKey('berat_kotor_kg')) {
      context.handle(
        _beratKotorKgMeta,
        beratKotorKg.isAcceptableOrUnknown(
          data['berat_kotor_kg']!,
          _beratKotorKgMeta,
        ),
      );
    }
    if (data.containsKey('persen_potongan')) {
      context.handle(
        _persenPotonganMeta,
        persenPotongan.isAcceptableOrUnknown(
          data['persen_potongan']!,
          _persenPotonganMeta,
        ),
      );
    }
    if (data.containsKey('nilai_potongan_kg')) {
      context.handle(
        _nilaiPotonganKgMeta,
        nilaiPotonganKg.isAcceptableOrUnknown(
          data['nilai_potongan_kg']!,
          _nilaiPotonganKgMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaksiItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaksiItemData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transaksiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaksi_id'],
      )!,
      jenisBuahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jenis_buah_id'],
      )!,
      hargaPerKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}harga_per_kg'],
      )!,
      beratKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}berat_kg'],
      )!,
      beratKotorKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}berat_kotor_kg'],
      ),
      persenPotongan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persen_potongan'],
      ),
      nilaiPotonganKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nilai_potongan_kg'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtotal'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalTransaksiItemTable createAlias(String alias) {
    return $LocalTransaksiItemTable(attachedDatabase, alias);
  }
}

class LocalTransaksiItemData extends DataClass
    implements Insertable<LocalTransaksiItemData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final String transaksiId;
  final int jenisBuahId;
  final String hargaPerKg;
  final String beratKg;
  final String? beratKotorKg;
  final String? persenPotongan;
  final String? nilaiPotonganKg;
  final String subtotal;
  final DateTime createdAt;
  const LocalTransaksiItemData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.transaksiId,
    required this.jenisBuahId,
    required this.hargaPerKg,
    required this.beratKg,
    this.beratKotorKg,
    this.persenPotongan,
    this.nilaiPotonganKg,
    required this.subtotal,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['transaksi_id'] = Variable<String>(transaksiId);
    map['jenis_buah_id'] = Variable<int>(jenisBuahId);
    map['harga_per_kg'] = Variable<String>(hargaPerKg);
    map['berat_kg'] = Variable<String>(beratKg);
    if (!nullToAbsent || beratKotorKg != null) {
      map['berat_kotor_kg'] = Variable<String>(beratKotorKg);
    }
    if (!nullToAbsent || persenPotongan != null) {
      map['persen_potongan'] = Variable<String>(persenPotongan);
    }
    if (!nullToAbsent || nilaiPotonganKg != null) {
      map['nilai_potongan_kg'] = Variable<String>(nilaiPotonganKg);
    }
    map['subtotal'] = Variable<String>(subtotal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalTransaksiItemCompanion toCompanion(bool nullToAbsent) {
    return LocalTransaksiItemCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      transaksiId: Value(transaksiId),
      jenisBuahId: Value(jenisBuahId),
      hargaPerKg: Value(hargaPerKg),
      beratKg: Value(beratKg),
      beratKotorKg: beratKotorKg == null && nullToAbsent
          ? const Value.absent()
          : Value(beratKotorKg),
      persenPotongan: persenPotongan == null && nullToAbsent
          ? const Value.absent()
          : Value(persenPotongan),
      nilaiPotonganKg: nilaiPotonganKg == null && nullToAbsent
          ? const Value.absent()
          : Value(nilaiPotonganKg),
      subtotal: Value(subtotal),
      createdAt: Value(createdAt),
    );
  }

  factory LocalTransaksiItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaksiItemData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      transaksiId: serializer.fromJson<String>(json['transaksiId']),
      jenisBuahId: serializer.fromJson<int>(json['jenisBuahId']),
      hargaPerKg: serializer.fromJson<String>(json['hargaPerKg']),
      beratKg: serializer.fromJson<String>(json['beratKg']),
      beratKotorKg: serializer.fromJson<String?>(json['beratKotorKg']),
      persenPotongan: serializer.fromJson<String?>(json['persenPotongan']),
      nilaiPotonganKg: serializer.fromJson<String?>(json['nilaiPotonganKg']),
      subtotal: serializer.fromJson<String>(json['subtotal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'transaksiId': serializer.toJson<String>(transaksiId),
      'jenisBuahId': serializer.toJson<int>(jenisBuahId),
      'hargaPerKg': serializer.toJson<String>(hargaPerKg),
      'beratKg': serializer.toJson<String>(beratKg),
      'beratKotorKg': serializer.toJson<String?>(beratKotorKg),
      'persenPotongan': serializer.toJson<String?>(persenPotongan),
      'nilaiPotonganKg': serializer.toJson<String?>(nilaiPotonganKg),
      'subtotal': serializer.toJson<String>(subtotal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalTransaksiItemData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? transaksiId,
    int? jenisBuahId,
    String? hargaPerKg,
    String? beratKg,
    Value<String?> beratKotorKg = const Value.absent(),
    Value<String?> persenPotongan = const Value.absent(),
    Value<String?> nilaiPotonganKg = const Value.absent(),
    String? subtotal,
    DateTime? createdAt,
  }) => LocalTransaksiItemData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    transaksiId: transaksiId ?? this.transaksiId,
    jenisBuahId: jenisBuahId ?? this.jenisBuahId,
    hargaPerKg: hargaPerKg ?? this.hargaPerKg,
    beratKg: beratKg ?? this.beratKg,
    beratKotorKg: beratKotorKg.present ? beratKotorKg.value : this.beratKotorKg,
    persenPotongan: persenPotongan.present
        ? persenPotongan.value
        : this.persenPotongan,
    nilaiPotonganKg: nilaiPotonganKg.present
        ? nilaiPotonganKg.value
        : this.nilaiPotonganKg,
    subtotal: subtotal ?? this.subtotal,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalTransaksiItemData copyWithCompanion(LocalTransaksiItemCompanion data) {
    return LocalTransaksiItemData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      transaksiId: data.transaksiId.present
          ? data.transaksiId.value
          : this.transaksiId,
      jenisBuahId: data.jenisBuahId.present
          ? data.jenisBuahId.value
          : this.jenisBuahId,
      hargaPerKg: data.hargaPerKg.present
          ? data.hargaPerKg.value
          : this.hargaPerKg,
      beratKg: data.beratKg.present ? data.beratKg.value : this.beratKg,
      beratKotorKg: data.beratKotorKg.present
          ? data.beratKotorKg.value
          : this.beratKotorKg,
      persenPotongan: data.persenPotongan.present
          ? data.persenPotongan.value
          : this.persenPotongan,
      nilaiPotonganKg: data.nilaiPotonganKg.present
          ? data.nilaiPotonganKg.value
          : this.nilaiPotonganKg,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaksiItemData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('jenisBuahId: $jenisBuahId, ')
          ..write('hargaPerKg: $hargaPerKg, ')
          ..write('beratKg: $beratKg, ')
          ..write('beratKotorKg: $beratKotorKg, ')
          ..write('persenPotongan: $persenPotongan, ')
          ..write('nilaiPotonganKg: $nilaiPotonganKg, ')
          ..write('subtotal: $subtotal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    transaksiId,
    jenisBuahId,
    hargaPerKg,
    beratKg,
    beratKotorKg,
    persenPotongan,
    nilaiPotonganKg,
    subtotal,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaksiItemData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.transaksiId == this.transaksiId &&
          other.jenisBuahId == this.jenisBuahId &&
          other.hargaPerKg == this.hargaPerKg &&
          other.beratKg == this.beratKg &&
          other.beratKotorKg == this.beratKotorKg &&
          other.persenPotongan == this.persenPotongan &&
          other.nilaiPotonganKg == this.nilaiPotonganKg &&
          other.subtotal == this.subtotal &&
          other.createdAt == this.createdAt);
}

class LocalTransaksiItemCompanion
    extends UpdateCompanion<LocalTransaksiItemData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> transaksiId;
  final Value<int> jenisBuahId;
  final Value<String> hargaPerKg;
  final Value<String> beratKg;
  final Value<String?> beratKotorKg;
  final Value<String?> persenPotongan;
  final Value<String?> nilaiPotonganKg;
  final Value<String> subtotal;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalTransaksiItemCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.transaksiId = const Value.absent(),
    this.jenisBuahId = const Value.absent(),
    this.hargaPerKg = const Value.absent(),
    this.beratKg = const Value.absent(),
    this.beratKotorKg = const Value.absent(),
    this.persenPotongan = const Value.absent(),
    this.nilaiPotonganKg = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransaksiItemCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String transaksiId,
    required int jenisBuahId,
    required String hargaPerKg,
    required String beratKg,
    this.beratKotorKg = const Value.absent(),
    this.persenPotongan = const Value.absent(),
    this.nilaiPotonganKg = const Value.absent(),
    required String subtotal,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transaksiId = Value(transaksiId),
       jenisBuahId = Value(jenisBuahId),
       hargaPerKg = Value(hargaPerKg),
       beratKg = Value(beratKg),
       subtotal = Value(subtotal);
  static Insertable<LocalTransaksiItemData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? transaksiId,
    Expression<int>? jenisBuahId,
    Expression<String>? hargaPerKg,
    Expression<String>? beratKg,
    Expression<String>? beratKotorKg,
    Expression<String>? persenPotongan,
    Expression<String>? nilaiPotonganKg,
    Expression<String>? subtotal,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (transaksiId != null) 'transaksi_id': transaksiId,
      if (jenisBuahId != null) 'jenis_buah_id': jenisBuahId,
      if (hargaPerKg != null) 'harga_per_kg': hargaPerKg,
      if (beratKg != null) 'berat_kg': beratKg,
      if (beratKotorKg != null) 'berat_kotor_kg': beratKotorKg,
      if (persenPotongan != null) 'persen_potongan': persenPotongan,
      if (nilaiPotonganKg != null) 'nilai_potongan_kg': nilaiPotonganKg,
      if (subtotal != null) 'subtotal': subtotal,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransaksiItemCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? transaksiId,
    Value<int>? jenisBuahId,
    Value<String>? hargaPerKg,
    Value<String>? beratKg,
    Value<String?>? beratKotorKg,
    Value<String?>? persenPotongan,
    Value<String?>? nilaiPotonganKg,
    Value<String>? subtotal,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalTransaksiItemCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      jenisBuahId: jenisBuahId ?? this.jenisBuahId,
      hargaPerKg: hargaPerKg ?? this.hargaPerKg,
      beratKg: beratKg ?? this.beratKg,
      beratKotorKg: beratKotorKg ?? this.beratKotorKg,
      persenPotongan: persenPotongan ?? this.persenPotongan,
      nilaiPotonganKg: nilaiPotonganKg ?? this.nilaiPotonganKg,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transaksiId.present) {
      map['transaksi_id'] = Variable<String>(transaksiId.value);
    }
    if (jenisBuahId.present) {
      map['jenis_buah_id'] = Variable<int>(jenisBuahId.value);
    }
    if (hargaPerKg.present) {
      map['harga_per_kg'] = Variable<String>(hargaPerKg.value);
    }
    if (beratKg.present) {
      map['berat_kg'] = Variable<String>(beratKg.value);
    }
    if (beratKotorKg.present) {
      map['berat_kotor_kg'] = Variable<String>(beratKotorKg.value);
    }
    if (persenPotongan.present) {
      map['persen_potongan'] = Variable<String>(persenPotongan.value);
    }
    if (nilaiPotonganKg.present) {
      map['nilai_potongan_kg'] = Variable<String>(nilaiPotonganKg.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<String>(subtotal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaksiItemCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('jenisBuahId: $jenisBuahId, ')
          ..write('hargaPerKg: $hargaPerKg, ')
          ..write('beratKg: $beratKg, ')
          ..write('beratKotorKg: $beratKotorKg, ')
          ..write('persenPotongan: $persenPotongan, ')
          ..write('nilaiPotonganKg: $nilaiPotonganKg, ')
          ..write('subtotal: $subtotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPabrikTable extends LocalPabrik
    with TableInfo<$LocalPabrikTable, LocalPabrikData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPabrikTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lokasiMeta = const VerificationMeta('lokasi');
  @override
  late final GeneratedColumn<String> lokasi = GeneratedColumn<String>(
    'lokasi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kontakMeta = const VerificationMeta('kontak');
  @override
  late final GeneratedColumn<String> kontak = GeneratedColumn<String>(
    'kontak',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nama,
    lokasi,
    kontak,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pabrik';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPabrikData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('lokasi')) {
      context.handle(
        _lokasiMeta,
        lokasi.isAcceptableOrUnknown(data['lokasi']!, _lokasiMeta),
      );
    }
    if (data.containsKey('kontak')) {
      context.handle(
        _kontakMeta,
        kontak.isAcceptableOrUnknown(data['kontak']!, _kontakMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPabrikData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPabrikData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      lokasi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lokasi'],
      ),
      kontak: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kontak'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalPabrikTable createAlias(String alias) {
    return $LocalPabrikTable(attachedDatabase, alias);
  }
}

class LocalPabrikData extends DataClass implements Insertable<LocalPabrikData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final String nama;
  final String? lokasi;
  final String? kontak;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPabrikData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.nama,
    this.lokasi,
    this.kontak,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || lokasi != null) {
      map['lokasi'] = Variable<String>(lokasi);
    }
    if (!nullToAbsent || kontak != null) {
      map['kontak'] = Variable<String>(kontak);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPabrikCompanion toCompanion(bool nullToAbsent) {
    return LocalPabrikCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      nama: Value(nama),
      lokasi: lokasi == null && nullToAbsent
          ? const Value.absent()
          : Value(lokasi),
      kontak: kontak == null && nullToAbsent
          ? const Value.absent()
          : Value(kontak),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPabrikData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPabrikData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      lokasi: serializer.fromJson<String?>(json['lokasi']),
      kontak: serializer.fromJson<String?>(json['kontak']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'lokasi': serializer.toJson<String?>(lokasi),
      'kontak': serializer.toJson<String?>(kontak),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPabrikData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? nama,
    Value<String?> lokasi = const Value.absent(),
    Value<String?> kontak = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalPabrikData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    nama: nama ?? this.nama,
    lokasi: lokasi.present ? lokasi.value : this.lokasi,
    kontak: kontak.present ? kontak.value : this.kontak,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPabrikData copyWithCompanion(LocalPabrikCompanion data) {
    return LocalPabrikData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      lokasi: data.lokasi.present ? data.lokasi.value : this.lokasi,
      kontak: data.kontak.present ? data.kontak.value : this.kontak,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPabrikData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('lokasi: $lokasi, ')
          ..write('kontak: $kontak, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nama,
    lokasi,
    kontak,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPabrikData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.lokasi == this.lokasi &&
          other.kontak == this.kontak &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPabrikCompanion extends UpdateCompanion<LocalPabrikData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> nama;
  final Value<String?> lokasi;
  final Value<String?> kontak;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPabrikCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.lokasi = const Value.absent(),
    this.kontak = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPabrikCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String nama,
    this.lokasi = const Value.absent(),
    this.kontak = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama);
  static Insertable<LocalPabrikData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? lokasi,
    Expression<String>? kontak,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (lokasi != null) 'lokasi': lokasi,
      if (kontak != null) 'kontak': kontak,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPabrikCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? nama,
    Value<String?>? lokasi,
    Value<String?>? kontak,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPabrikCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      kontak: kontak ?? this.kontak,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (lokasi.present) {
      map['lokasi'] = Variable<String>(lokasi.value);
    }
    if (kontak.present) {
      map['kontak'] = Variable<String>(kontak.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPabrikCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('lokasi: $lokasi, ')
          ..write('kontak: $kontak, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPengirimanPabrikTable extends LocalPengirimanPabrik
    with TableInfo<$LocalPengirimanPabrikTable, LocalPengirimanPabrikData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPengirimanPabrikTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noSpbMeta = const VerificationMeta('noSpb');
  @override
  late final GeneratedColumn<String> noSpb = GeneratedColumn<String>(
    'no_spb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pabrikIdMeta = const VerificationMeta(
    'pabrikId',
  );
  @override
  late final GeneratedColumn<String> pabrikId = GeneratedColumn<String>(
    'pabrik_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalKirimMeta = const VerificationMeta(
    'tanggalKirim',
  );
  @override
  late final GeneratedColumn<DateTime> tanggalKirim = GeneratedColumn<DateTime>(
    'tanggal_kirim',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noKendaraanMeta = const VerificationMeta(
    'noKendaraan',
  );
  @override
  late final GeneratedColumn<String> noKendaraan = GeneratedColumn<String>(
    'no_kendaraan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaSupirMeta = const VerificationMeta(
    'namaSupir',
  );
  @override
  late final GeneratedColumn<String> namaSupir = GeneratedColumn<String>(
    'nama_supir',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dalam_perjalanan'),
  );
  static const VerificationMeta _beratKirimKgMeta = const VerificationMeta(
    'beratKirimKg',
  );
  @override
  late final GeneratedColumn<String> beratKirimKg = GeneratedColumn<String>(
    'berat_kirim_kg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beratTimbangPabrikKgMeta =
      const VerificationMeta('beratTimbangPabrikKg');
  @override
  late final GeneratedColumn<String> beratTimbangPabrikKg =
      GeneratedColumn<String>(
        'berat_timbang_pabrik_kg',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _toleransiSusutPersenMeta =
      const VerificationMeta('toleransiSusutPersen');
  @override
  late final GeneratedColumn<String> toleransiSusutPersen =
      GeneratedColumn<String>(
        'toleransi_susut_persen',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hargaPerKgMeta = const VerificationMeta(
    'hargaPerKg',
  );
  @override
  late final GeneratedColumn<String> hargaPerKg = GeneratedColumn<String>(
    'harga_per_kg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potonganSortasiPersenMeta =
      const VerificationMeta('potonganSortasiPersen');
  @override
  late final GeneratedColumn<String> potonganSortasiPersen =
      GeneratedColumn<String>(
        'potongan_sortasi_persen',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _potonganSortasiKgMeta = const VerificationMeta(
    'potonganSortasiKg',
  );
  @override
  late final GeneratedColumn<String> potonganSortasiKg =
      GeneratedColumn<String>(
        'potongan_sortasi_kg',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _potonganLainnyaNominalMeta =
      const VerificationMeta('potonganLainnyaNominal');
  @override
  late final GeneratedColumn<String> potonganLainnyaNominal =
      GeneratedColumn<String>(
        'potongan_lainnya_nominal',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _catatanPotonganLainnyaMeta =
      const VerificationMeta('catatanPotonganLainnya');
  @override
  late final GeneratedColumn<String> catatanPotonganLainnya =
      GeneratedColumn<String>(
        'catatan_potongan_lainnya',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalNilaiPenjualanMeta =
      const VerificationMeta('totalNilaiPenjualan');
  @override
  late final GeneratedColumn<String> totalNilaiPenjualan =
      GeneratedColumn<String>(
        'total_nilai_penjualan',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    noSpb,
    pabrikId,
    tanggalKirim,
    noKendaraan,
    namaSupir,
    status,
    beratKirimKg,
    beratTimbangPabrikKg,
    toleransiSusutPersen,
    hargaPerKg,
    potonganSortasiPersen,
    potonganSortasiKg,
    potonganLainnyaNominal,
    catatanPotonganLainnya,
    totalNilaiPenjualan,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pengiriman_pabrik';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPengirimanPabrikData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('no_spb')) {
      context.handle(
        _noSpbMeta,
        noSpb.isAcceptableOrUnknown(data['no_spb']!, _noSpbMeta),
      );
    } else if (isInserting) {
      context.missing(_noSpbMeta);
    }
    if (data.containsKey('pabrik_id')) {
      context.handle(
        _pabrikIdMeta,
        pabrikId.isAcceptableOrUnknown(data['pabrik_id']!, _pabrikIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pabrikIdMeta);
    }
    if (data.containsKey('tanggal_kirim')) {
      context.handle(
        _tanggalKirimMeta,
        tanggalKirim.isAcceptableOrUnknown(
          data['tanggal_kirim']!,
          _tanggalKirimMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tanggalKirimMeta);
    }
    if (data.containsKey('no_kendaraan')) {
      context.handle(
        _noKendaraanMeta,
        noKendaraan.isAcceptableOrUnknown(
          data['no_kendaraan']!,
          _noKendaraanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_noKendaraanMeta);
    }
    if (data.containsKey('nama_supir')) {
      context.handle(
        _namaSupirMeta,
        namaSupir.isAcceptableOrUnknown(data['nama_supir']!, _namaSupirMeta),
      );
    } else if (isInserting) {
      context.missing(_namaSupirMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('berat_kirim_kg')) {
      context.handle(
        _beratKirimKgMeta,
        beratKirimKg.isAcceptableOrUnknown(
          data['berat_kirim_kg']!,
          _beratKirimKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beratKirimKgMeta);
    }
    if (data.containsKey('berat_timbang_pabrik_kg')) {
      context.handle(
        _beratTimbangPabrikKgMeta,
        beratTimbangPabrikKg.isAcceptableOrUnknown(
          data['berat_timbang_pabrik_kg']!,
          _beratTimbangPabrikKgMeta,
        ),
      );
    }
    if (data.containsKey('toleransi_susut_persen')) {
      context.handle(
        _toleransiSusutPersenMeta,
        toleransiSusutPersen.isAcceptableOrUnknown(
          data['toleransi_susut_persen']!,
          _toleransiSusutPersenMeta,
        ),
      );
    }
    if (data.containsKey('harga_per_kg')) {
      context.handle(
        _hargaPerKgMeta,
        hargaPerKg.isAcceptableOrUnknown(
          data['harga_per_kg']!,
          _hargaPerKgMeta,
        ),
      );
    }
    if (data.containsKey('potongan_sortasi_persen')) {
      context.handle(
        _potonganSortasiPersenMeta,
        potonganSortasiPersen.isAcceptableOrUnknown(
          data['potongan_sortasi_persen']!,
          _potonganSortasiPersenMeta,
        ),
      );
    }
    if (data.containsKey('potongan_sortasi_kg')) {
      context.handle(
        _potonganSortasiKgMeta,
        potonganSortasiKg.isAcceptableOrUnknown(
          data['potongan_sortasi_kg']!,
          _potonganSortasiKgMeta,
        ),
      );
    }
    if (data.containsKey('potongan_lainnya_nominal')) {
      context.handle(
        _potonganLainnyaNominalMeta,
        potonganLainnyaNominal.isAcceptableOrUnknown(
          data['potongan_lainnya_nominal']!,
          _potonganLainnyaNominalMeta,
        ),
      );
    }
    if (data.containsKey('catatan_potongan_lainnya')) {
      context.handle(
        _catatanPotonganLainnyaMeta,
        catatanPotonganLainnya.isAcceptableOrUnknown(
          data['catatan_potongan_lainnya']!,
          _catatanPotonganLainnyaMeta,
        ),
      );
    }
    if (data.containsKey('total_nilai_penjualan')) {
      context.handle(
        _totalNilaiPenjualanMeta,
        totalNilaiPenjualan.isAcceptableOrUnknown(
          data['total_nilai_penjualan']!,
          _totalNilaiPenjualanMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPengirimanPabrikData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPengirimanPabrikData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noSpb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no_spb'],
      )!,
      pabrikId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pabrik_id'],
      )!,
      tanggalKirim: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal_kirim'],
      )!,
      noKendaraan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no_kendaraan'],
      )!,
      namaSupir: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama_supir'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      beratKirimKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}berat_kirim_kg'],
      )!,
      beratTimbangPabrikKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}berat_timbang_pabrik_kg'],
      ),
      toleransiSusutPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toleransi_susut_persen'],
      ),
      hargaPerKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}harga_per_kg'],
      ),
      potonganSortasiPersen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}potongan_sortasi_persen'],
      ),
      potonganSortasiKg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}potongan_sortasi_kg'],
      ),
      potonganLainnyaNominal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}potongan_lainnya_nominal'],
      ),
      catatanPotonganLainnya: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan_potongan_lainnya'],
      ),
      totalNilaiPenjualan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_nilai_penjualan'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalPengirimanPabrikTable createAlias(String alias) {
    return $LocalPengirimanPabrikTable(attachedDatabase, alias);
  }
}

class LocalPengirimanPabrikData extends DataClass
    implements Insertable<LocalPengirimanPabrikData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final String noSpb;
  final String pabrikId;
  final DateTime tanggalKirim;
  final String noKendaraan;
  final String namaSupir;
  final String status;
  final String beratKirimKg;
  final String? beratTimbangPabrikKg;
  final String? toleransiSusutPersen;
  final String? hargaPerKg;
  final String? potonganSortasiPersen;
  final String? potonganSortasiKg;
  final String? potonganLainnyaNominal;
  final String? catatanPotonganLainnya;
  final String? totalNilaiPenjualan;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPengirimanPabrikData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.noSpb,
    required this.pabrikId,
    required this.tanggalKirim,
    required this.noKendaraan,
    required this.namaSupir,
    required this.status,
    required this.beratKirimKg,
    this.beratTimbangPabrikKg,
    this.toleransiSusutPersen,
    this.hargaPerKg,
    this.potonganSortasiPersen,
    this.potonganSortasiKg,
    this.potonganLainnyaNominal,
    this.catatanPotonganLainnya,
    this.totalNilaiPenjualan,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['no_spb'] = Variable<String>(noSpb);
    map['pabrik_id'] = Variable<String>(pabrikId);
    map['tanggal_kirim'] = Variable<DateTime>(tanggalKirim);
    map['no_kendaraan'] = Variable<String>(noKendaraan);
    map['nama_supir'] = Variable<String>(namaSupir);
    map['status'] = Variable<String>(status);
    map['berat_kirim_kg'] = Variable<String>(beratKirimKg);
    if (!nullToAbsent || beratTimbangPabrikKg != null) {
      map['berat_timbang_pabrik_kg'] = Variable<String>(beratTimbangPabrikKg);
    }
    if (!nullToAbsent || toleransiSusutPersen != null) {
      map['toleransi_susut_persen'] = Variable<String>(toleransiSusutPersen);
    }
    if (!nullToAbsent || hargaPerKg != null) {
      map['harga_per_kg'] = Variable<String>(hargaPerKg);
    }
    if (!nullToAbsent || potonganSortasiPersen != null) {
      map['potongan_sortasi_persen'] = Variable<String>(potonganSortasiPersen);
    }
    if (!nullToAbsent || potonganSortasiKg != null) {
      map['potongan_sortasi_kg'] = Variable<String>(potonganSortasiKg);
    }
    if (!nullToAbsent || potonganLainnyaNominal != null) {
      map['potongan_lainnya_nominal'] = Variable<String>(
        potonganLainnyaNominal,
      );
    }
    if (!nullToAbsent || catatanPotonganLainnya != null) {
      map['catatan_potongan_lainnya'] = Variable<String>(
        catatanPotonganLainnya,
      );
    }
    if (!nullToAbsent || totalNilaiPenjualan != null) {
      map['total_nilai_penjualan'] = Variable<String>(totalNilaiPenjualan);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPengirimanPabrikCompanion toCompanion(bool nullToAbsent) {
    return LocalPengirimanPabrikCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      noSpb: Value(noSpb),
      pabrikId: Value(pabrikId),
      tanggalKirim: Value(tanggalKirim),
      noKendaraan: Value(noKendaraan),
      namaSupir: Value(namaSupir),
      status: Value(status),
      beratKirimKg: Value(beratKirimKg),
      beratTimbangPabrikKg: beratTimbangPabrikKg == null && nullToAbsent
          ? const Value.absent()
          : Value(beratTimbangPabrikKg),
      toleransiSusutPersen: toleransiSusutPersen == null && nullToAbsent
          ? const Value.absent()
          : Value(toleransiSusutPersen),
      hargaPerKg: hargaPerKg == null && nullToAbsent
          ? const Value.absent()
          : Value(hargaPerKg),
      potonganSortasiPersen: potonganSortasiPersen == null && nullToAbsent
          ? const Value.absent()
          : Value(potonganSortasiPersen),
      potonganSortasiKg: potonganSortasiKg == null && nullToAbsent
          ? const Value.absent()
          : Value(potonganSortasiKg),
      potonganLainnyaNominal: potonganLainnyaNominal == null && nullToAbsent
          ? const Value.absent()
          : Value(potonganLainnyaNominal),
      catatanPotonganLainnya: catatanPotonganLainnya == null && nullToAbsent
          ? const Value.absent()
          : Value(catatanPotonganLainnya),
      totalNilaiPenjualan: totalNilaiPenjualan == null && nullToAbsent
          ? const Value.absent()
          : Value(totalNilaiPenjualan),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPengirimanPabrikData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPengirimanPabrikData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      noSpb: serializer.fromJson<String>(json['noSpb']),
      pabrikId: serializer.fromJson<String>(json['pabrikId']),
      tanggalKirim: serializer.fromJson<DateTime>(json['tanggalKirim']),
      noKendaraan: serializer.fromJson<String>(json['noKendaraan']),
      namaSupir: serializer.fromJson<String>(json['namaSupir']),
      status: serializer.fromJson<String>(json['status']),
      beratKirimKg: serializer.fromJson<String>(json['beratKirimKg']),
      beratTimbangPabrikKg: serializer.fromJson<String?>(
        json['beratTimbangPabrikKg'],
      ),
      toleransiSusutPersen: serializer.fromJson<String?>(
        json['toleransiSusutPersen'],
      ),
      hargaPerKg: serializer.fromJson<String?>(json['hargaPerKg']),
      potonganSortasiPersen: serializer.fromJson<String?>(
        json['potonganSortasiPersen'],
      ),
      potonganSortasiKg: serializer.fromJson<String?>(
        json['potonganSortasiKg'],
      ),
      potonganLainnyaNominal: serializer.fromJson<String?>(
        json['potonganLainnyaNominal'],
      ),
      catatanPotonganLainnya: serializer.fromJson<String?>(
        json['catatanPotonganLainnya'],
      ),
      totalNilaiPenjualan: serializer.fromJson<String?>(
        json['totalNilaiPenjualan'],
      ),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'noSpb': serializer.toJson<String>(noSpb),
      'pabrikId': serializer.toJson<String>(pabrikId),
      'tanggalKirim': serializer.toJson<DateTime>(tanggalKirim),
      'noKendaraan': serializer.toJson<String>(noKendaraan),
      'namaSupir': serializer.toJson<String>(namaSupir),
      'status': serializer.toJson<String>(status),
      'beratKirimKg': serializer.toJson<String>(beratKirimKg),
      'beratTimbangPabrikKg': serializer.toJson<String?>(beratTimbangPabrikKg),
      'toleransiSusutPersen': serializer.toJson<String?>(toleransiSusutPersen),
      'hargaPerKg': serializer.toJson<String?>(hargaPerKg),
      'potonganSortasiPersen': serializer.toJson<String?>(
        potonganSortasiPersen,
      ),
      'potonganSortasiKg': serializer.toJson<String?>(potonganSortasiKg),
      'potonganLainnyaNominal': serializer.toJson<String?>(
        potonganLainnyaNominal,
      ),
      'catatanPotonganLainnya': serializer.toJson<String?>(
        catatanPotonganLainnya,
      ),
      'totalNilaiPenjualan': serializer.toJson<String?>(totalNilaiPenjualan),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPengirimanPabrikData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? noSpb,
    String? pabrikId,
    DateTime? tanggalKirim,
    String? noKendaraan,
    String? namaSupir,
    String? status,
    String? beratKirimKg,
    Value<String?> beratTimbangPabrikKg = const Value.absent(),
    Value<String?> toleransiSusutPersen = const Value.absent(),
    Value<String?> hargaPerKg = const Value.absent(),
    Value<String?> potonganSortasiPersen = const Value.absent(),
    Value<String?> potonganSortasiKg = const Value.absent(),
    Value<String?> potonganLainnyaNominal = const Value.absent(),
    Value<String?> catatanPotonganLainnya = const Value.absent(),
    Value<String?> totalNilaiPenjualan = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalPengirimanPabrikData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    noSpb: noSpb ?? this.noSpb,
    pabrikId: pabrikId ?? this.pabrikId,
    tanggalKirim: tanggalKirim ?? this.tanggalKirim,
    noKendaraan: noKendaraan ?? this.noKendaraan,
    namaSupir: namaSupir ?? this.namaSupir,
    status: status ?? this.status,
    beratKirimKg: beratKirimKg ?? this.beratKirimKg,
    beratTimbangPabrikKg: beratTimbangPabrikKg.present
        ? beratTimbangPabrikKg.value
        : this.beratTimbangPabrikKg,
    toleransiSusutPersen: toleransiSusutPersen.present
        ? toleransiSusutPersen.value
        : this.toleransiSusutPersen,
    hargaPerKg: hargaPerKg.present ? hargaPerKg.value : this.hargaPerKg,
    potonganSortasiPersen: potonganSortasiPersen.present
        ? potonganSortasiPersen.value
        : this.potonganSortasiPersen,
    potonganSortasiKg: potonganSortasiKg.present
        ? potonganSortasiKg.value
        : this.potonganSortasiKg,
    potonganLainnyaNominal: potonganLainnyaNominal.present
        ? potonganLainnyaNominal.value
        : this.potonganLainnyaNominal,
    catatanPotonganLainnya: catatanPotonganLainnya.present
        ? catatanPotonganLainnya.value
        : this.catatanPotonganLainnya,
    totalNilaiPenjualan: totalNilaiPenjualan.present
        ? totalNilaiPenjualan.value
        : this.totalNilaiPenjualan,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPengirimanPabrikData copyWithCompanion(
    LocalPengirimanPabrikCompanion data,
  ) {
    return LocalPengirimanPabrikData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      noSpb: data.noSpb.present ? data.noSpb.value : this.noSpb,
      pabrikId: data.pabrikId.present ? data.pabrikId.value : this.pabrikId,
      tanggalKirim: data.tanggalKirim.present
          ? data.tanggalKirim.value
          : this.tanggalKirim,
      noKendaraan: data.noKendaraan.present
          ? data.noKendaraan.value
          : this.noKendaraan,
      namaSupir: data.namaSupir.present ? data.namaSupir.value : this.namaSupir,
      status: data.status.present ? data.status.value : this.status,
      beratKirimKg: data.beratKirimKg.present
          ? data.beratKirimKg.value
          : this.beratKirimKg,
      beratTimbangPabrikKg: data.beratTimbangPabrikKg.present
          ? data.beratTimbangPabrikKg.value
          : this.beratTimbangPabrikKg,
      toleransiSusutPersen: data.toleransiSusutPersen.present
          ? data.toleransiSusutPersen.value
          : this.toleransiSusutPersen,
      hargaPerKg: data.hargaPerKg.present
          ? data.hargaPerKg.value
          : this.hargaPerKg,
      potonganSortasiPersen: data.potonganSortasiPersen.present
          ? data.potonganSortasiPersen.value
          : this.potonganSortasiPersen,
      potonganSortasiKg: data.potonganSortasiKg.present
          ? data.potonganSortasiKg.value
          : this.potonganSortasiKg,
      potonganLainnyaNominal: data.potonganLainnyaNominal.present
          ? data.potonganLainnyaNominal.value
          : this.potonganLainnyaNominal,
      catatanPotonganLainnya: data.catatanPotonganLainnya.present
          ? data.catatanPotonganLainnya.value
          : this.catatanPotonganLainnya,
      totalNilaiPenjualan: data.totalNilaiPenjualan.present
          ? data.totalNilaiPenjualan.value
          : this.totalNilaiPenjualan,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPengirimanPabrikData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('noSpb: $noSpb, ')
          ..write('pabrikId: $pabrikId, ')
          ..write('tanggalKirim: $tanggalKirim, ')
          ..write('noKendaraan: $noKendaraan, ')
          ..write('namaSupir: $namaSupir, ')
          ..write('status: $status, ')
          ..write('beratKirimKg: $beratKirimKg, ')
          ..write('beratTimbangPabrikKg: $beratTimbangPabrikKg, ')
          ..write('toleransiSusutPersen: $toleransiSusutPersen, ')
          ..write('hargaPerKg: $hargaPerKg, ')
          ..write('potonganSortasiPersen: $potonganSortasiPersen, ')
          ..write('potonganSortasiKg: $potonganSortasiKg, ')
          ..write('potonganLainnyaNominal: $potonganLainnyaNominal, ')
          ..write('catatanPotonganLainnya: $catatanPotonganLainnya, ')
          ..write('totalNilaiPenjualan: $totalNilaiPenjualan, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    noSpb,
    pabrikId,
    tanggalKirim,
    noKendaraan,
    namaSupir,
    status,
    beratKirimKg,
    beratTimbangPabrikKg,
    toleransiSusutPersen,
    hargaPerKg,
    potonganSortasiPersen,
    potonganSortasiKg,
    potonganLainnyaNominal,
    catatanPotonganLainnya,
    totalNilaiPenjualan,
    createdBy,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPengirimanPabrikData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.noSpb == this.noSpb &&
          other.pabrikId == this.pabrikId &&
          other.tanggalKirim == this.tanggalKirim &&
          other.noKendaraan == this.noKendaraan &&
          other.namaSupir == this.namaSupir &&
          other.status == this.status &&
          other.beratKirimKg == this.beratKirimKg &&
          other.beratTimbangPabrikKg == this.beratTimbangPabrikKg &&
          other.toleransiSusutPersen == this.toleransiSusutPersen &&
          other.hargaPerKg == this.hargaPerKg &&
          other.potonganSortasiPersen == this.potonganSortasiPersen &&
          other.potonganSortasiKg == this.potonganSortasiKg &&
          other.potonganLainnyaNominal == this.potonganLainnyaNominal &&
          other.catatanPotonganLainnya == this.catatanPotonganLainnya &&
          other.totalNilaiPenjualan == this.totalNilaiPenjualan &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPengirimanPabrikCompanion
    extends UpdateCompanion<LocalPengirimanPabrikData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> noSpb;
  final Value<String> pabrikId;
  final Value<DateTime> tanggalKirim;
  final Value<String> noKendaraan;
  final Value<String> namaSupir;
  final Value<String> status;
  final Value<String> beratKirimKg;
  final Value<String?> beratTimbangPabrikKg;
  final Value<String?> toleransiSusutPersen;
  final Value<String?> hargaPerKg;
  final Value<String?> potonganSortasiPersen;
  final Value<String?> potonganSortasiKg;
  final Value<String?> potonganLainnyaNominal;
  final Value<String?> catatanPotonganLainnya;
  final Value<String?> totalNilaiPenjualan;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPengirimanPabrikCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.noSpb = const Value.absent(),
    this.pabrikId = const Value.absent(),
    this.tanggalKirim = const Value.absent(),
    this.noKendaraan = const Value.absent(),
    this.namaSupir = const Value.absent(),
    this.status = const Value.absent(),
    this.beratKirimKg = const Value.absent(),
    this.beratTimbangPabrikKg = const Value.absent(),
    this.toleransiSusutPersen = const Value.absent(),
    this.hargaPerKg = const Value.absent(),
    this.potonganSortasiPersen = const Value.absent(),
    this.potonganSortasiKg = const Value.absent(),
    this.potonganLainnyaNominal = const Value.absent(),
    this.catatanPotonganLainnya = const Value.absent(),
    this.totalNilaiPenjualan = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPengirimanPabrikCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String noSpb,
    required String pabrikId,
    required DateTime tanggalKirim,
    required String noKendaraan,
    required String namaSupir,
    this.status = const Value.absent(),
    required String beratKirimKg,
    this.beratTimbangPabrikKg = const Value.absent(),
    this.toleransiSusutPersen = const Value.absent(),
    this.hargaPerKg = const Value.absent(),
    this.potonganSortasiPersen = const Value.absent(),
    this.potonganSortasiKg = const Value.absent(),
    this.potonganLainnyaNominal = const Value.absent(),
    this.catatanPotonganLainnya = const Value.absent(),
    this.totalNilaiPenjualan = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noSpb = Value(noSpb),
       pabrikId = Value(pabrikId),
       tanggalKirim = Value(tanggalKirim),
       noKendaraan = Value(noKendaraan),
       namaSupir = Value(namaSupir),
       beratKirimKg = Value(beratKirimKg);
  static Insertable<LocalPengirimanPabrikData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? noSpb,
    Expression<String>? pabrikId,
    Expression<DateTime>? tanggalKirim,
    Expression<String>? noKendaraan,
    Expression<String>? namaSupir,
    Expression<String>? status,
    Expression<String>? beratKirimKg,
    Expression<String>? beratTimbangPabrikKg,
    Expression<String>? toleransiSusutPersen,
    Expression<String>? hargaPerKg,
    Expression<String>? potonganSortasiPersen,
    Expression<String>? potonganSortasiKg,
    Expression<String>? potonganLainnyaNominal,
    Expression<String>? catatanPotonganLainnya,
    Expression<String>? totalNilaiPenjualan,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (noSpb != null) 'no_spb': noSpb,
      if (pabrikId != null) 'pabrik_id': pabrikId,
      if (tanggalKirim != null) 'tanggal_kirim': tanggalKirim,
      if (noKendaraan != null) 'no_kendaraan': noKendaraan,
      if (namaSupir != null) 'nama_supir': namaSupir,
      if (status != null) 'status': status,
      if (beratKirimKg != null) 'berat_kirim_kg': beratKirimKg,
      if (beratTimbangPabrikKg != null)
        'berat_timbang_pabrik_kg': beratTimbangPabrikKg,
      if (toleransiSusutPersen != null)
        'toleransi_susut_persen': toleransiSusutPersen,
      if (hargaPerKg != null) 'harga_per_kg': hargaPerKg,
      if (potonganSortasiPersen != null)
        'potongan_sortasi_persen': potonganSortasiPersen,
      if (potonganSortasiKg != null) 'potongan_sortasi_kg': potonganSortasiKg,
      if (potonganLainnyaNominal != null)
        'potongan_lainnya_nominal': potonganLainnyaNominal,
      if (catatanPotonganLainnya != null)
        'catatan_potongan_lainnya': catatanPotonganLainnya,
      if (totalNilaiPenjualan != null)
        'total_nilai_penjualan': totalNilaiPenjualan,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPengirimanPabrikCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? noSpb,
    Value<String>? pabrikId,
    Value<DateTime>? tanggalKirim,
    Value<String>? noKendaraan,
    Value<String>? namaSupir,
    Value<String>? status,
    Value<String>? beratKirimKg,
    Value<String?>? beratTimbangPabrikKg,
    Value<String?>? toleransiSusutPersen,
    Value<String?>? hargaPerKg,
    Value<String?>? potonganSortasiPersen,
    Value<String?>? potonganSortasiKg,
    Value<String?>? potonganLainnyaNominal,
    Value<String?>? catatanPotonganLainnya,
    Value<String?>? totalNilaiPenjualan,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPengirimanPabrikCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      noSpb: noSpb ?? this.noSpb,
      pabrikId: pabrikId ?? this.pabrikId,
      tanggalKirim: tanggalKirim ?? this.tanggalKirim,
      noKendaraan: noKendaraan ?? this.noKendaraan,
      namaSupir: namaSupir ?? this.namaSupir,
      status: status ?? this.status,
      beratKirimKg: beratKirimKg ?? this.beratKirimKg,
      beratTimbangPabrikKg: beratTimbangPabrikKg ?? this.beratTimbangPabrikKg,
      toleransiSusutPersen: toleransiSusutPersen ?? this.toleransiSusutPersen,
      hargaPerKg: hargaPerKg ?? this.hargaPerKg,
      potonganSortasiPersen:
          potonganSortasiPersen ?? this.potonganSortasiPersen,
      potonganSortasiKg: potonganSortasiKg ?? this.potonganSortasiKg,
      potonganLainnyaNominal:
          potonganLainnyaNominal ?? this.potonganLainnyaNominal,
      catatanPotonganLainnya:
          catatanPotonganLainnya ?? this.catatanPotonganLainnya,
      totalNilaiPenjualan: totalNilaiPenjualan ?? this.totalNilaiPenjualan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noSpb.present) {
      map['no_spb'] = Variable<String>(noSpb.value);
    }
    if (pabrikId.present) {
      map['pabrik_id'] = Variable<String>(pabrikId.value);
    }
    if (tanggalKirim.present) {
      map['tanggal_kirim'] = Variable<DateTime>(tanggalKirim.value);
    }
    if (noKendaraan.present) {
      map['no_kendaraan'] = Variable<String>(noKendaraan.value);
    }
    if (namaSupir.present) {
      map['nama_supir'] = Variable<String>(namaSupir.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (beratKirimKg.present) {
      map['berat_kirim_kg'] = Variable<String>(beratKirimKg.value);
    }
    if (beratTimbangPabrikKg.present) {
      map['berat_timbang_pabrik_kg'] = Variable<String>(
        beratTimbangPabrikKg.value,
      );
    }
    if (toleransiSusutPersen.present) {
      map['toleransi_susut_persen'] = Variable<String>(
        toleransiSusutPersen.value,
      );
    }
    if (hargaPerKg.present) {
      map['harga_per_kg'] = Variable<String>(hargaPerKg.value);
    }
    if (potonganSortasiPersen.present) {
      map['potongan_sortasi_persen'] = Variable<String>(
        potonganSortasiPersen.value,
      );
    }
    if (potonganSortasiKg.present) {
      map['potongan_sortasi_kg'] = Variable<String>(potonganSortasiKg.value);
    }
    if (potonganLainnyaNominal.present) {
      map['potongan_lainnya_nominal'] = Variable<String>(
        potonganLainnyaNominal.value,
      );
    }
    if (catatanPotonganLainnya.present) {
      map['catatan_potongan_lainnya'] = Variable<String>(
        catatanPotonganLainnya.value,
      );
    }
    if (totalNilaiPenjualan.present) {
      map['total_nilai_penjualan'] = Variable<String>(
        totalNilaiPenjualan.value,
      );
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPengirimanPabrikCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('noSpb: $noSpb, ')
          ..write('pabrikId: $pabrikId, ')
          ..write('tanggalKirim: $tanggalKirim, ')
          ..write('noKendaraan: $noKendaraan, ')
          ..write('namaSupir: $namaSupir, ')
          ..write('status: $status, ')
          ..write('beratKirimKg: $beratKirimKg, ')
          ..write('beratTimbangPabrikKg: $beratTimbangPabrikKg, ')
          ..write('toleransiSusutPersen: $toleransiSusutPersen, ')
          ..write('hargaPerKg: $hargaPerKg, ')
          ..write('potonganSortasiPersen: $potonganSortasiPersen, ')
          ..write('potonganSortasiKg: $potonganSortasiKg, ')
          ..write('potonganLainnyaNominal: $potonganLainnyaNominal, ')
          ..write('catatanPotonganLainnya: $catatanPotonganLainnya, ')
          ..write('totalNilaiPenjualan: $totalNilaiPenjualan, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalJenisPengeluaranTable extends LocalJenisPengeluaran
    with TableInfo<$LocalJenisPengeluaranTable, LocalJenisPengeluaranData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalJenisPengeluaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nama,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_jenis_pengeluaran';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalJenisPengeluaranData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalJenisPengeluaranData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalJenisPengeluaranData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $LocalJenisPengeluaranTable createAlias(String alias) {
    return $LocalJenisPengeluaranTable(attachedDatabase, alias);
  }
}

class LocalJenisPengeluaranData extends DataClass
    implements Insertable<LocalJenisPengeluaranData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final int id;
  final String nama;
  final bool isActive;
  const LocalJenisPengeluaranData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.nama,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<int>(id);
    map['nama'] = Variable<String>(nama);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalJenisPengeluaranCompanion toCompanion(bool nullToAbsent) {
    return LocalJenisPengeluaranCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      nama: Value(nama),
      isActive: Value(isActive),
    );
  }

  factory LocalJenisPengeluaranData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalJenisPengeluaranData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String>(nama),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalJenisPengeluaranData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? id,
    String? nama,
    bool? isActive,
  }) => LocalJenisPengeluaranData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    nama: nama ?? this.nama,
    isActive: isActive ?? this.isActive,
  );
  LocalJenisPengeluaranData copyWithCompanion(
    LocalJenisPengeluaranCompanion data,
  ) {
    return LocalJenisPengeluaranData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalJenisPengeluaranData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nama,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalJenisPengeluaranData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.isActive == this.isActive);
}

class LocalJenisPengeluaranCompanion
    extends UpdateCompanion<LocalJenisPengeluaranData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> id;
  final Value<String> nama;
  final Value<bool> isActive;
  const LocalJenisPengeluaranCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  LocalJenisPengeluaranCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String nama,
    this.isActive = const Value.absent(),
  }) : nama = Value(nama);
  static Insertable<LocalJenisPengeluaranData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? id,
    Expression<String>? nama,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (isActive != null) 'is_active': isActive,
    });
  }

  LocalJenisPengeluaranCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? id,
    Value<String>? nama,
    Value<bool>? isActive,
  }) {
    return LocalJenisPengeluaranCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      nama: nama ?? this.nama,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalJenisPengeluaranCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $LocalPengeluaranTable extends LocalPengeluaran
    with TableInfo<$LocalPengeluaranTable, LocalPengeluaranData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPengeluaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jenisPengeluaranIdMeta =
      const VerificationMeta('jenisPengeluaranId');
  @override
  late final GeneratedColumn<int> jenisPengeluaranId = GeneratedColumn<int>(
    'jenis_pengeluaran_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<String> nominal = GeneratedColumn<String>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keteranganMeta = const VerificationMeta(
    'keterangan',
  );
  @override
  late final GeneratedColumn<String> keterangan = GeneratedColumn<String>(
    'keterangan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metodePembayaranMeta = const VerificationMeta(
    'metodePembayaran',
  );
  @override
  late final GeneratedColumn<String> metodePembayaran = GeneratedColumn<String>(
    'metode_pembayaran',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tunai'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('aktif'),
  );
  static const VerificationMeta _alasanBatalMeta = const VerificationMeta(
    'alasanBatal',
  );
  @override
  late final GeneratedColumn<String> alasanBatal = GeneratedColumn<String>(
    'alasan_batal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    jenisPengeluaranId,
    nominal,
    tanggal,
    keterangan,
    metodePembayaran,
    status,
    alasanBatal,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pengeluaran';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPengeluaranData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('jenis_pengeluaran_id')) {
      context.handle(
        _jenisPengeluaranIdMeta,
        jenisPengeluaranId.isAcceptableOrUnknown(
          data['jenis_pengeluaran_id']!,
          _jenisPengeluaranIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jenisPengeluaranIdMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('keterangan')) {
      context.handle(
        _keteranganMeta,
        keterangan.isAcceptableOrUnknown(data['keterangan']!, _keteranganMeta),
      );
    } else if (isInserting) {
      context.missing(_keteranganMeta);
    }
    if (data.containsKey('metode_pembayaran')) {
      context.handle(
        _metodePembayaranMeta,
        metodePembayaran.isAcceptableOrUnknown(
          data['metode_pembayaran']!,
          _metodePembayaranMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('alasan_batal')) {
      context.handle(
        _alasanBatalMeta,
        alasanBatal.isAcceptableOrUnknown(
          data['alasan_batal']!,
          _alasanBatalMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPengeluaranData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPengeluaranData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jenisPengeluaranId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jenis_pengeluaran_id'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominal'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      keterangan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keterangan'],
      )!,
      metodePembayaran: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metode_pembayaran'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      alasanBatal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alasan_batal'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalPengeluaranTable createAlias(String alias) {
    return $LocalPengeluaranTable(attachedDatabase, alias);
  }
}

class LocalPengeluaranData extends DataClass
    implements Insertable<LocalPengeluaranData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final int jenisPengeluaranId;
  final String nominal;
  final DateTime tanggal;
  final String keterangan;
  final String metodePembayaran;
  final String status;
  final String? alasanBatal;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPengeluaranData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.jenisPengeluaranId,
    required this.nominal,
    required this.tanggal,
    required this.keterangan,
    required this.metodePembayaran,
    required this.status,
    this.alasanBatal,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['jenis_pengeluaran_id'] = Variable<int>(jenisPengeluaranId);
    map['nominal'] = Variable<String>(nominal);
    map['tanggal'] = Variable<DateTime>(tanggal);
    map['keterangan'] = Variable<String>(keterangan);
    map['metode_pembayaran'] = Variable<String>(metodePembayaran);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || alasanBatal != null) {
      map['alasan_batal'] = Variable<String>(alasanBatal);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPengeluaranCompanion toCompanion(bool nullToAbsent) {
    return LocalPengeluaranCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      jenisPengeluaranId: Value(jenisPengeluaranId),
      nominal: Value(nominal),
      tanggal: Value(tanggal),
      keterangan: Value(keterangan),
      metodePembayaran: Value(metodePembayaran),
      status: Value(status),
      alasanBatal: alasanBatal == null && nullToAbsent
          ? const Value.absent()
          : Value(alasanBatal),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPengeluaranData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPengeluaranData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      jenisPengeluaranId: serializer.fromJson<int>(json['jenisPengeluaranId']),
      nominal: serializer.fromJson<String>(json['nominal']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      keterangan: serializer.fromJson<String>(json['keterangan']),
      metodePembayaran: serializer.fromJson<String>(json['metodePembayaran']),
      status: serializer.fromJson<String>(json['status']),
      alasanBatal: serializer.fromJson<String?>(json['alasanBatal']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'jenisPengeluaranId': serializer.toJson<int>(jenisPengeluaranId),
      'nominal': serializer.toJson<String>(nominal),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'keterangan': serializer.toJson<String>(keterangan),
      'metodePembayaran': serializer.toJson<String>(metodePembayaran),
      'status': serializer.toJson<String>(status),
      'alasanBatal': serializer.toJson<String?>(alasanBatal),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPengeluaranData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    int? jenisPengeluaranId,
    String? nominal,
    DateTime? tanggal,
    String? keterangan,
    String? metodePembayaran,
    String? status,
    Value<String?> alasanBatal = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalPengeluaranData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    jenisPengeluaranId: jenisPengeluaranId ?? this.jenisPengeluaranId,
    nominal: nominal ?? this.nominal,
    tanggal: tanggal ?? this.tanggal,
    keterangan: keterangan ?? this.keterangan,
    metodePembayaran: metodePembayaran ?? this.metodePembayaran,
    status: status ?? this.status,
    alasanBatal: alasanBatal.present ? alasanBatal.value : this.alasanBatal,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPengeluaranData copyWithCompanion(LocalPengeluaranCompanion data) {
    return LocalPengeluaranData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      jenisPengeluaranId: data.jenisPengeluaranId.present
          ? data.jenisPengeluaranId.value
          : this.jenisPengeluaranId,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      keterangan: data.keterangan.present
          ? data.keterangan.value
          : this.keterangan,
      metodePembayaran: data.metodePembayaran.present
          ? data.metodePembayaran.value
          : this.metodePembayaran,
      status: data.status.present ? data.status.value : this.status,
      alasanBatal: data.alasanBatal.present
          ? data.alasanBatal.value
          : this.alasanBatal,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPengeluaranData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('jenisPengeluaranId: $jenisPengeluaranId, ')
          ..write('nominal: $nominal, ')
          ..write('tanggal: $tanggal, ')
          ..write('keterangan: $keterangan, ')
          ..write('metodePembayaran: $metodePembayaran, ')
          ..write('status: $status, ')
          ..write('alasanBatal: $alasanBatal, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    jenisPengeluaranId,
    nominal,
    tanggal,
    keterangan,
    metodePembayaran,
    status,
    alasanBatal,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPengeluaranData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.jenisPengeluaranId == this.jenisPengeluaranId &&
          other.nominal == this.nominal &&
          other.tanggal == this.tanggal &&
          other.keterangan == this.keterangan &&
          other.metodePembayaran == this.metodePembayaran &&
          other.status == this.status &&
          other.alasanBatal == this.alasanBatal &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPengeluaranCompanion extends UpdateCompanion<LocalPengeluaranData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<int> jenisPengeluaranId;
  final Value<String> nominal;
  final Value<DateTime> tanggal;
  final Value<String> keterangan;
  final Value<String> metodePembayaran;
  final Value<String> status;
  final Value<String?> alasanBatal;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPengeluaranCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.jenisPengeluaranId = const Value.absent(),
    this.nominal = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.keterangan = const Value.absent(),
    this.metodePembayaran = const Value.absent(),
    this.status = const Value.absent(),
    this.alasanBatal = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPengeluaranCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required int jenisPengeluaranId,
    required String nominal,
    required DateTime tanggal,
    required String keterangan,
    this.metodePembayaran = const Value.absent(),
    this.status = const Value.absent(),
    this.alasanBatal = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jenisPengeluaranId = Value(jenisPengeluaranId),
       nominal = Value(nominal),
       tanggal = Value(tanggal),
       keterangan = Value(keterangan);
  static Insertable<LocalPengeluaranData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<int>? jenisPengeluaranId,
    Expression<String>? nominal,
    Expression<DateTime>? tanggal,
    Expression<String>? keterangan,
    Expression<String>? metodePembayaran,
    Expression<String>? status,
    Expression<String>? alasanBatal,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (jenisPengeluaranId != null)
        'jenis_pengeluaran_id': jenisPengeluaranId,
      if (nominal != null) 'nominal': nominal,
      if (tanggal != null) 'tanggal': tanggal,
      if (keterangan != null) 'keterangan': keterangan,
      if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
      if (status != null) 'status': status,
      if (alasanBatal != null) 'alasan_batal': alasanBatal,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPengeluaranCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<int>? jenisPengeluaranId,
    Value<String>? nominal,
    Value<DateTime>? tanggal,
    Value<String>? keterangan,
    Value<String>? metodePembayaran,
    Value<String>? status,
    Value<String?>? alasanBatal,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPengeluaranCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      jenisPengeluaranId: jenisPengeluaranId ?? this.jenisPengeluaranId,
      nominal: nominal ?? this.nominal,
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      status: status ?? this.status,
      alasanBatal: alasanBatal ?? this.alasanBatal,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jenisPengeluaranId.present) {
      map['jenis_pengeluaran_id'] = Variable<int>(jenisPengeluaranId.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<String>(nominal.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (keterangan.present) {
      map['keterangan'] = Variable<String>(keterangan.value);
    }
    if (metodePembayaran.present) {
      map['metode_pembayaran'] = Variable<String>(metodePembayaran.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (alasanBatal.present) {
      map['alasan_batal'] = Variable<String>(alasanBatal.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPengeluaranCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('jenisPengeluaranId: $jenisPengeluaranId, ')
          ..write('nominal: $nominal, ')
          ..write('tanggal: $tanggal, ')
          ..write('keterangan: $keterangan, ')
          ..write('metodePembayaran: $metodePembayaran, ')
          ..write('status: $status, ')
          ..write('alasanBatal: $alasanBatal, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTopupSaldoTable extends LocalTopupSaldo
    with TableInfo<$LocalTopupSaldoTable, LocalTopupSaldoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTopupSaldoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nominalMeta = const VerificationMeta(
    'nominal',
  );
  @override
  late final GeneratedColumn<String> nominal = GeneratedColumn<String>(
    'nominal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keteranganMeta = const VerificationMeta(
    'keterangan',
  );
  @override
  late final GeneratedColumn<String> keterangan = GeneratedColumn<String>(
    'keterangan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('aktif'),
  );
  static const VerificationMeta _alasanBatalMeta = const VerificationMeta(
    'alasanBatal',
  );
  @override
  late final GeneratedColumn<String> alasanBatal = GeneratedColumn<String>(
    'alasan_batal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nominal,
    tanggal,
    keterangan,
    status,
    alasanBatal,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_topup_saldo';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTopupSaldoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(
        _nominalMeta,
        nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta),
      );
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('keterangan')) {
      context.handle(
        _keteranganMeta,
        keterangan.isAcceptableOrUnknown(data['keterangan']!, _keteranganMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('alasan_batal')) {
      context.handle(
        _alasanBatalMeta,
        alasanBatal.isAcceptableOrUnknown(
          data['alasan_batal']!,
          _alasanBatalMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTopupSaldoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTopupSaldoData(
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nominal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominal'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      keterangan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keterangan'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      alasanBatal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alasan_batal'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalTopupSaldoTable createAlias(String alias) {
    return $LocalTopupSaldoTable(attachedDatabase, alias);
  }
}

class LocalTopupSaldoData extends DataClass
    implements Insertable<LocalTopupSaldoData> {
  /// Flag status apakah data sudah tersinkron ke Supabase cloud
  final bool isSynced;

  /// ID perangkat pencatat (misal: 'MOB-xxx' atau 'DSK-xxx')
  final String? deviceId;

  /// Waktu terakhir data diupdate secara lokal
  final DateTime localUpdatedAt;

  /// Soft delete flag untuk sinkronisasi penghapusan ke cloud
  final DateTime? deletedAt;
  final String id;
  final String nominal;
  final DateTime tanggal;
  final String? keterangan;
  final String status;
  final String? alasanBatal;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalTopupSaldoData({
    required this.isSynced,
    this.deviceId,
    required this.localUpdatedAt,
    this.deletedAt,
    required this.id,
    required this.nominal,
    required this.tanggal,
    this.keterangan,
    required this.status,
    this.alasanBatal,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['nominal'] = Variable<String>(nominal);
    map['tanggal'] = Variable<DateTime>(tanggal);
    if (!nullToAbsent || keterangan != null) {
      map['keterangan'] = Variable<String>(keterangan);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || alasanBatal != null) {
      map['alasan_batal'] = Variable<String>(alasanBatal);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTopupSaldoCompanion toCompanion(bool nullToAbsent) {
    return LocalTopupSaldoCompanion(
      isSynced: Value(isSynced),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      localUpdatedAt: Value(localUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      nominal: Value(nominal),
      tanggal: Value(tanggal),
      keterangan: keterangan == null && nullToAbsent
          ? const Value.absent()
          : Value(keterangan),
      status: Value(status),
      alasanBatal: alasanBatal == null && nullToAbsent
          ? const Value.absent()
          : Value(alasanBatal),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTopupSaldoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTopupSaldoData(
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      nominal: serializer.fromJson<String>(json['nominal']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      keterangan: serializer.fromJson<String?>(json['keterangan']),
      status: serializer.fromJson<String>(json['status']),
      alasanBatal: serializer.fromJson<String?>(json['alasanBatal']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isSynced': serializer.toJson<bool>(isSynced),
      'deviceId': serializer.toJson<String?>(deviceId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'nominal': serializer.toJson<String>(nominal),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'keterangan': serializer.toJson<String?>(keterangan),
      'status': serializer.toJson<String>(status),
      'alasanBatal': serializer.toJson<String?>(alasanBatal),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTopupSaldoData copyWith({
    bool? isSynced,
    Value<String?> deviceId = const Value.absent(),
    DateTime? localUpdatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? nominal,
    DateTime? tanggal,
    Value<String?> keterangan = const Value.absent(),
    String? status,
    Value<String?> alasanBatal = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalTopupSaldoData(
    isSynced: isSynced ?? this.isSynced,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    nominal: nominal ?? this.nominal,
    tanggal: tanggal ?? this.tanggal,
    keterangan: keterangan.present ? keterangan.value : this.keterangan,
    status: status ?? this.status,
    alasanBatal: alasanBatal.present ? alasanBatal.value : this.alasanBatal,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalTopupSaldoData copyWithCompanion(LocalTopupSaldoCompanion data) {
    return LocalTopupSaldoData(
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      keterangan: data.keterangan.present
          ? data.keterangan.value
          : this.keterangan,
      status: data.status.present ? data.status.value : this.status,
      alasanBatal: data.alasanBatal.present
          ? data.alasanBatal.value
          : this.alasanBatal,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTopupSaldoData(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nominal: $nominal, ')
          ..write('tanggal: $tanggal, ')
          ..write('keterangan: $keterangan, ')
          ..write('status: $status, ')
          ..write('alasanBatal: $alasanBatal, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isSynced,
    deviceId,
    localUpdatedAt,
    deletedAt,
    id,
    nominal,
    tanggal,
    keterangan,
    status,
    alasanBatal,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTopupSaldoData &&
          other.isSynced == this.isSynced &&
          other.deviceId == this.deviceId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.nominal == this.nominal &&
          other.tanggal == this.tanggal &&
          other.keterangan == this.keterangan &&
          other.status == this.status &&
          other.alasanBatal == this.alasanBatal &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalTopupSaldoCompanion extends UpdateCompanion<LocalTopupSaldoData> {
  final Value<bool> isSynced;
  final Value<String?> deviceId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> nominal;
  final Value<DateTime> tanggal;
  final Value<String?> keterangan;
  final Value<String> status;
  final Value<String?> alasanBatal;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTopupSaldoCompanion({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.nominal = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.keterangan = const Value.absent(),
    this.status = const Value.absent(),
    this.alasanBatal = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTopupSaldoCompanion.insert({
    this.isSynced = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String nominal,
    required DateTime tanggal,
    this.keterangan = const Value.absent(),
    this.status = const Value.absent(),
    this.alasanBatal = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nominal = Value(nominal),
       tanggal = Value(tanggal);
  static Insertable<LocalTopupSaldoData> custom({
    Expression<bool>? isSynced,
    Expression<String>? deviceId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? nominal,
    Expression<DateTime>? tanggal,
    Expression<String>? keterangan,
    Expression<String>? status,
    Expression<String>? alasanBatal,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isSynced != null) 'is_synced': isSynced,
      if (deviceId != null) 'device_id': deviceId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (nominal != null) 'nominal': nominal,
      if (tanggal != null) 'tanggal': tanggal,
      if (keterangan != null) 'keterangan': keterangan,
      if (status != null) 'status': status,
      if (alasanBatal != null) 'alasan_batal': alasanBatal,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTopupSaldoCompanion copyWith({
    Value<bool>? isSynced,
    Value<String?>? deviceId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? nominal,
    Value<DateTime>? tanggal,
    Value<String?>? keterangan,
    Value<String>? status,
    Value<String?>? alasanBatal,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalTopupSaldoCompanion(
      isSynced: isSynced ?? this.isSynced,
      deviceId: deviceId ?? this.deviceId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      nominal: nominal ?? this.nominal,
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      alasanBatal: alasanBatal ?? this.alasanBatal,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<String>(nominal.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (keterangan.present) {
      map['keterangan'] = Variable<String>(keterangan.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (alasanBatal.present) {
      map['alasan_batal'] = Variable<String>(alasanBatal.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTopupSaldoCompanion(')
          ..write('isSynced: $isSynced, ')
          ..write('deviceId: $deviceId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nominal: $nominal, ')
          ..write('tanggal: $tanggal, ')
          ..write('keterangan: $keterangan, ')
          ..write('status: $status, ')
          ..write('alasanBatal: $alasanBatal, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalPenjualTable localPenjual = $LocalPenjualTable(this);
  late final $LocalJenisBuahTable localJenisBuah = $LocalJenisBuahTable(this);
  late final $LocalTransaksiTable localTransaksi = $LocalTransaksiTable(this);
  late final $LocalTransaksiItemTable localTransaksiItem =
      $LocalTransaksiItemTable(this);
  late final $LocalPabrikTable localPabrik = $LocalPabrikTable(this);
  late final $LocalPengirimanPabrikTable localPengirimanPabrik =
      $LocalPengirimanPabrikTable(this);
  late final $LocalJenisPengeluaranTable localJenisPengeluaran =
      $LocalJenisPengeluaranTable(this);
  late final $LocalPengeluaranTable localPengeluaran = $LocalPengeluaranTable(
    this,
  );
  late final $LocalTopupSaldoTable localTopupSaldo = $LocalTopupSaldoTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localPenjual,
    localJenisBuah,
    localTransaksi,
    localTransaksiItem,
    localPabrik,
    localPengirimanPabrik,
    localJenisPengeluaran,
    localPengeluaran,
    localTopupSaldo,
  ];
}

typedef $$LocalPenjualTableCreateCompanionBuilder =
    LocalPenjualCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String nama,
      Value<String?> noTelepon,
      Value<String?> alamat,
      Value<String?> catatan,
      Value<bool> isActive,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPenjualTableUpdateCompanionBuilder =
    LocalPenjualCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> nama,
      Value<String?> noTelepon,
      Value<String?> alamat,
      Value<String?> catatan,
      Value<bool> isActive,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalPenjualTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPenjualTable> {
  $$LocalPenjualTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noTelepon => $composableBuilder(
    column: $table.noTelepon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPenjualTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPenjualTable> {
  $$LocalPenjualTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noTelepon => $composableBuilder(
    column: $table.noTelepon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPenjualTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPenjualTable> {
  $$LocalPenjualTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get noTelepon =>
      $composableBuilder(column: $table.noTelepon, builder: (column) => column);

  GeneratedColumn<String> get alamat =>
      $composableBuilder(column: $table.alamat, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPenjualTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPenjualTable,
          LocalPenjualData,
          $$LocalPenjualTableFilterComposer,
          $$LocalPenjualTableOrderingComposer,
          $$LocalPenjualTableAnnotationComposer,
          $$LocalPenjualTableCreateCompanionBuilder,
          $$LocalPenjualTableUpdateCompanionBuilder,
          (
            LocalPenjualData,
            BaseReferences<_$AppDatabase, $LocalPenjualTable, LocalPenjualData>,
          ),
          LocalPenjualData,
          PrefetchHooks Function()
        > {
  $$LocalPenjualTableTableManager(_$AppDatabase db, $LocalPenjualTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPenjualTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPenjualTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPenjualTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String?> noTelepon = const Value.absent(),
                Value<String?> alamat = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPenjualCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nama: nama,
                noTelepon: noTelepon,
                alamat: alamat,
                catatan: catatan,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String nama,
                Value<String?> noTelepon = const Value.absent(),
                Value<String?> alamat = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPenjualCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nama: nama,
                noTelepon: noTelepon,
                alamat: alamat,
                catatan: catatan,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPenjualTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPenjualTable,
      LocalPenjualData,
      $$LocalPenjualTableFilterComposer,
      $$LocalPenjualTableOrderingComposer,
      $$LocalPenjualTableAnnotationComposer,
      $$LocalPenjualTableCreateCompanionBuilder,
      $$LocalPenjualTableUpdateCompanionBuilder,
      (
        LocalPenjualData,
        BaseReferences<_$AppDatabase, $LocalPenjualTable, LocalPenjualData>,
      ),
      LocalPenjualData,
      PrefetchHooks Function()
    >;
typedef $$LocalJenisBuahTableCreateCompanionBuilder =
    LocalJenisBuahCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<int> id,
      required String kode,
      required String nama,
      Value<bool> isActive,
    });
typedef $$LocalJenisBuahTableUpdateCompanionBuilder =
    LocalJenisBuahCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<int> id,
      Value<String> kode,
      Value<String> nama,
      Value<bool> isActive,
    });

class $$LocalJenisBuahTableFilterComposer
    extends Composer<_$AppDatabase, $LocalJenisBuahTable> {
  $$LocalJenisBuahTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kode => $composableBuilder(
    column: $table.kode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalJenisBuahTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalJenisBuahTable> {
  $$LocalJenisBuahTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kode => $composableBuilder(
    column: $table.kode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalJenisBuahTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalJenisBuahTable> {
  $$LocalJenisBuahTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kode =>
      $composableBuilder(column: $table.kode, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalJenisBuahTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalJenisBuahTable,
          LocalJenisBuahData,
          $$LocalJenisBuahTableFilterComposer,
          $$LocalJenisBuahTableOrderingComposer,
          $$LocalJenisBuahTableAnnotationComposer,
          $$LocalJenisBuahTableCreateCompanionBuilder,
          $$LocalJenisBuahTableUpdateCompanionBuilder,
          (
            LocalJenisBuahData,
            BaseReferences<
              _$AppDatabase,
              $LocalJenisBuahTable,
              LocalJenisBuahData
            >,
          ),
          LocalJenisBuahData,
          PrefetchHooks Function()
        > {
  $$LocalJenisBuahTableTableManager(
    _$AppDatabase db,
    $LocalJenisBuahTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalJenisBuahTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalJenisBuahTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalJenisBuahTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> kode = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LocalJenisBuahCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                kode: kode,
                nama: nama,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String kode,
                required String nama,
                Value<bool> isActive = const Value.absent(),
              }) => LocalJenisBuahCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                kode: kode,
                nama: nama,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalJenisBuahTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalJenisBuahTable,
      LocalJenisBuahData,
      $$LocalJenisBuahTableFilterComposer,
      $$LocalJenisBuahTableOrderingComposer,
      $$LocalJenisBuahTableAnnotationComposer,
      $$LocalJenisBuahTableCreateCompanionBuilder,
      $$LocalJenisBuahTableUpdateCompanionBuilder,
      (
        LocalJenisBuahData,
        BaseReferences<_$AppDatabase, $LocalJenisBuahTable, LocalJenisBuahData>,
      ),
      LocalJenisBuahData,
      PrefetchHooks Function()
    >;
typedef $$LocalTransaksiTableCreateCompanionBuilder =
    LocalTransaksiCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String kodeTransaksi,
      required String penjualId,
      required DateTime tanggalTransaksi,
      Value<String> status,
      Value<String?> alasanBatal,
      Value<String> jenisPembayaran,
      Value<String?> catatan,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalTransaksiTableUpdateCompanionBuilder =
    LocalTransaksiCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> kodeTransaksi,
      Value<String> penjualId,
      Value<DateTime> tanggalTransaksi,
      Value<String> status,
      Value<String?> alasanBatal,
      Value<String> jenisPembayaran,
      Value<String?> catatan,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalTransaksiTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransaksiTable> {
  $$LocalTransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kodeTransaksi => $composableBuilder(
    column: $table.kodeTransaksi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get penjualId => $composableBuilder(
    column: $table.penjualId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggalTransaksi => $composableBuilder(
    column: $table.tanggalTransaksi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jenisPembayaran => $composableBuilder(
    column: $table.jenisPembayaran,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransaksiTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransaksiTable> {
  $$LocalTransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kodeTransaksi => $composableBuilder(
    column: $table.kodeTransaksi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get penjualId => $composableBuilder(
    column: $table.penjualId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggalTransaksi => $composableBuilder(
    column: $table.tanggalTransaksi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jenisPembayaran => $composableBuilder(
    column: $table.jenisPembayaran,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransaksiTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransaksiTable> {
  $$LocalTransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kodeTransaksi => $composableBuilder(
    column: $table.kodeTransaksi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get penjualId =>
      $composableBuilder(column: $table.penjualId, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggalTransaksi => $composableBuilder(
    column: $table.tanggalTransaksi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jenisPembayaran => $composableBuilder(
    column: $table.jenisPembayaran,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTransaksiTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransaksiTable,
          LocalTransaksiData,
          $$LocalTransaksiTableFilterComposer,
          $$LocalTransaksiTableOrderingComposer,
          $$LocalTransaksiTableAnnotationComposer,
          $$LocalTransaksiTableCreateCompanionBuilder,
          $$LocalTransaksiTableUpdateCompanionBuilder,
          (
            LocalTransaksiData,
            BaseReferences<
              _$AppDatabase,
              $LocalTransaksiTable,
              LocalTransaksiData
            >,
          ),
          LocalTransaksiData,
          PrefetchHooks Function()
        > {
  $$LocalTransaksiTableTableManager(
    _$AppDatabase db,
    $LocalTransaksiTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransaksiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> kodeTransaksi = const Value.absent(),
                Value<String> penjualId = const Value.absent(),
                Value<DateTime> tanggalTransaksi = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> alasanBatal = const Value.absent(),
                Value<String> jenisPembayaran = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransaksiCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                kodeTransaksi: kodeTransaksi,
                penjualId: penjualId,
                tanggalTransaksi: tanggalTransaksi,
                status: status,
                alasanBatal: alasanBatal,
                jenisPembayaran: jenisPembayaran,
                catatan: catatan,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String kodeTransaksi,
                required String penjualId,
                required DateTime tanggalTransaksi,
                Value<String> status = const Value.absent(),
                Value<String?> alasanBatal = const Value.absent(),
                Value<String> jenisPembayaran = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransaksiCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                kodeTransaksi: kodeTransaksi,
                penjualId: penjualId,
                tanggalTransaksi: tanggalTransaksi,
                status: status,
                alasanBatal: alasanBatal,
                jenisPembayaran: jenisPembayaran,
                catatan: catatan,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransaksiTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransaksiTable,
      LocalTransaksiData,
      $$LocalTransaksiTableFilterComposer,
      $$LocalTransaksiTableOrderingComposer,
      $$LocalTransaksiTableAnnotationComposer,
      $$LocalTransaksiTableCreateCompanionBuilder,
      $$LocalTransaksiTableUpdateCompanionBuilder,
      (
        LocalTransaksiData,
        BaseReferences<_$AppDatabase, $LocalTransaksiTable, LocalTransaksiData>,
      ),
      LocalTransaksiData,
      PrefetchHooks Function()
    >;
typedef $$LocalTransaksiItemTableCreateCompanionBuilder =
    LocalTransaksiItemCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String transaksiId,
      required int jenisBuahId,
      required String hargaPerKg,
      required String beratKg,
      Value<String?> beratKotorKg,
      Value<String?> persenPotongan,
      Value<String?> nilaiPotonganKg,
      required String subtotal,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LocalTransaksiItemTableUpdateCompanionBuilder =
    LocalTransaksiItemCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> transaksiId,
      Value<int> jenisBuahId,
      Value<String> hargaPerKg,
      Value<String> beratKg,
      Value<String?> beratKotorKg,
      Value<String?> persenPotongan,
      Value<String?> nilaiPotonganKg,
      Value<String> subtotal,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalTransaksiItemTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransaksiItemTable> {
  $$LocalTransaksiItemTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transaksiId => $composableBuilder(
    column: $table.transaksiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jenisBuahId => $composableBuilder(
    column: $table.jenisBuahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hargaPerKg => $composableBuilder(
    column: $table.hargaPerKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beratKg => $composableBuilder(
    column: $table.beratKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beratKotorKg => $composableBuilder(
    column: $table.beratKotorKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get persenPotongan => $composableBuilder(
    column: $table.persenPotongan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nilaiPotonganKg => $composableBuilder(
    column: $table.nilaiPotonganKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransaksiItemTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransaksiItemTable> {
  $$LocalTransaksiItemTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transaksiId => $composableBuilder(
    column: $table.transaksiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jenisBuahId => $composableBuilder(
    column: $table.jenisBuahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hargaPerKg => $composableBuilder(
    column: $table.hargaPerKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beratKg => $composableBuilder(
    column: $table.beratKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beratKotorKg => $composableBuilder(
    column: $table.beratKotorKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get persenPotongan => $composableBuilder(
    column: $table.persenPotongan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nilaiPotonganKg => $composableBuilder(
    column: $table.nilaiPotonganKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransaksiItemTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransaksiItemTable> {
  $$LocalTransaksiItemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transaksiId => $composableBuilder(
    column: $table.transaksiId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jenisBuahId => $composableBuilder(
    column: $table.jenisBuahId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hargaPerKg => $composableBuilder(
    column: $table.hargaPerKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get beratKg =>
      $composableBuilder(column: $table.beratKg, builder: (column) => column);

  GeneratedColumn<String> get beratKotorKg => $composableBuilder(
    column: $table.beratKotorKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get persenPotongan => $composableBuilder(
    column: $table.persenPotongan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nilaiPotonganKg => $composableBuilder(
    column: $table.nilaiPotonganKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalTransaksiItemTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransaksiItemTable,
          LocalTransaksiItemData,
          $$LocalTransaksiItemTableFilterComposer,
          $$LocalTransaksiItemTableOrderingComposer,
          $$LocalTransaksiItemTableAnnotationComposer,
          $$LocalTransaksiItemTableCreateCompanionBuilder,
          $$LocalTransaksiItemTableUpdateCompanionBuilder,
          (
            LocalTransaksiItemData,
            BaseReferences<
              _$AppDatabase,
              $LocalTransaksiItemTable,
              LocalTransaksiItemData
            >,
          ),
          LocalTransaksiItemData,
          PrefetchHooks Function()
        > {
  $$LocalTransaksiItemTableTableManager(
    _$AppDatabase db,
    $LocalTransaksiItemTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransaksiItemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransaksiItemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransaksiItemTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> transaksiId = const Value.absent(),
                Value<int> jenisBuahId = const Value.absent(),
                Value<String> hargaPerKg = const Value.absent(),
                Value<String> beratKg = const Value.absent(),
                Value<String?> beratKotorKg = const Value.absent(),
                Value<String?> persenPotongan = const Value.absent(),
                Value<String?> nilaiPotonganKg = const Value.absent(),
                Value<String> subtotal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransaksiItemCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                transaksiId: transaksiId,
                jenisBuahId: jenisBuahId,
                hargaPerKg: hargaPerKg,
                beratKg: beratKg,
                beratKotorKg: beratKotorKg,
                persenPotongan: persenPotongan,
                nilaiPotonganKg: nilaiPotonganKg,
                subtotal: subtotal,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String transaksiId,
                required int jenisBuahId,
                required String hargaPerKg,
                required String beratKg,
                Value<String?> beratKotorKg = const Value.absent(),
                Value<String?> persenPotongan = const Value.absent(),
                Value<String?> nilaiPotonganKg = const Value.absent(),
                required String subtotal,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransaksiItemCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                transaksiId: transaksiId,
                jenisBuahId: jenisBuahId,
                hargaPerKg: hargaPerKg,
                beratKg: beratKg,
                beratKotorKg: beratKotorKg,
                persenPotongan: persenPotongan,
                nilaiPotonganKg: nilaiPotonganKg,
                subtotal: subtotal,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransaksiItemTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransaksiItemTable,
      LocalTransaksiItemData,
      $$LocalTransaksiItemTableFilterComposer,
      $$LocalTransaksiItemTableOrderingComposer,
      $$LocalTransaksiItemTableAnnotationComposer,
      $$LocalTransaksiItemTableCreateCompanionBuilder,
      $$LocalTransaksiItemTableUpdateCompanionBuilder,
      (
        LocalTransaksiItemData,
        BaseReferences<
          _$AppDatabase,
          $LocalTransaksiItemTable,
          LocalTransaksiItemData
        >,
      ),
      LocalTransaksiItemData,
      PrefetchHooks Function()
    >;
typedef $$LocalPabrikTableCreateCompanionBuilder =
    LocalPabrikCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String nama,
      Value<String?> lokasi,
      Value<String?> kontak,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPabrikTableUpdateCompanionBuilder =
    LocalPabrikCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> nama,
      Value<String?> lokasi,
      Value<String?> kontak,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalPabrikTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPabrikTable> {
  $$LocalPabrikTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lokasi => $composableBuilder(
    column: $table.lokasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kontak => $composableBuilder(
    column: $table.kontak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPabrikTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPabrikTable> {
  $$LocalPabrikTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lokasi => $composableBuilder(
    column: $table.lokasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kontak => $composableBuilder(
    column: $table.kontak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPabrikTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPabrikTable> {
  $$LocalPabrikTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get lokasi =>
      $composableBuilder(column: $table.lokasi, builder: (column) => column);

  GeneratedColumn<String> get kontak =>
      $composableBuilder(column: $table.kontak, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPabrikTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPabrikTable,
          LocalPabrikData,
          $$LocalPabrikTableFilterComposer,
          $$LocalPabrikTableOrderingComposer,
          $$LocalPabrikTableAnnotationComposer,
          $$LocalPabrikTableCreateCompanionBuilder,
          $$LocalPabrikTableUpdateCompanionBuilder,
          (
            LocalPabrikData,
            BaseReferences<_$AppDatabase, $LocalPabrikTable, LocalPabrikData>,
          ),
          LocalPabrikData,
          PrefetchHooks Function()
        > {
  $$LocalPabrikTableTableManager(_$AppDatabase db, $LocalPabrikTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPabrikTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPabrikTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPabrikTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String?> lokasi = const Value.absent(),
                Value<String?> kontak = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPabrikCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nama: nama,
                lokasi: lokasi,
                kontak: kontak,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String nama,
                Value<String?> lokasi = const Value.absent(),
                Value<String?> kontak = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPabrikCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nama: nama,
                lokasi: lokasi,
                kontak: kontak,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPabrikTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPabrikTable,
      LocalPabrikData,
      $$LocalPabrikTableFilterComposer,
      $$LocalPabrikTableOrderingComposer,
      $$LocalPabrikTableAnnotationComposer,
      $$LocalPabrikTableCreateCompanionBuilder,
      $$LocalPabrikTableUpdateCompanionBuilder,
      (
        LocalPabrikData,
        BaseReferences<_$AppDatabase, $LocalPabrikTable, LocalPabrikData>,
      ),
      LocalPabrikData,
      PrefetchHooks Function()
    >;
typedef $$LocalPengirimanPabrikTableCreateCompanionBuilder =
    LocalPengirimanPabrikCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String noSpb,
      required String pabrikId,
      required DateTime tanggalKirim,
      required String noKendaraan,
      required String namaSupir,
      Value<String> status,
      required String beratKirimKg,
      Value<String?> beratTimbangPabrikKg,
      Value<String?> toleransiSusutPersen,
      Value<String?> hargaPerKg,
      Value<String?> potonganSortasiPersen,
      Value<String?> potonganSortasiKg,
      Value<String?> potonganLainnyaNominal,
      Value<String?> catatanPotonganLainnya,
      Value<String?> totalNilaiPenjualan,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPengirimanPabrikTableUpdateCompanionBuilder =
    LocalPengirimanPabrikCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> noSpb,
      Value<String> pabrikId,
      Value<DateTime> tanggalKirim,
      Value<String> noKendaraan,
      Value<String> namaSupir,
      Value<String> status,
      Value<String> beratKirimKg,
      Value<String?> beratTimbangPabrikKg,
      Value<String?> toleransiSusutPersen,
      Value<String?> hargaPerKg,
      Value<String?> potonganSortasiPersen,
      Value<String?> potonganSortasiKg,
      Value<String?> potonganLainnyaNominal,
      Value<String?> catatanPotonganLainnya,
      Value<String?> totalNilaiPenjualan,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalPengirimanPabrikTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPengirimanPabrikTable> {
  $$LocalPengirimanPabrikTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noSpb => $composableBuilder(
    column: $table.noSpb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pabrikId => $composableBuilder(
    column: $table.pabrikId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggalKirim => $composableBuilder(
    column: $table.tanggalKirim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noKendaraan => $composableBuilder(
    column: $table.noKendaraan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namaSupir => $composableBuilder(
    column: $table.namaSupir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beratKirimKg => $composableBuilder(
    column: $table.beratKirimKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beratTimbangPabrikKg => $composableBuilder(
    column: $table.beratTimbangPabrikKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toleransiSusutPersen => $composableBuilder(
    column: $table.toleransiSusutPersen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hargaPerKg => $composableBuilder(
    column: $table.hargaPerKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potonganSortasiPersen => $composableBuilder(
    column: $table.potonganSortasiPersen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potonganSortasiKg => $composableBuilder(
    column: $table.potonganSortasiKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potonganLainnyaNominal => $composableBuilder(
    column: $table.potonganLainnyaNominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatanPotonganLainnya => $composableBuilder(
    column: $table.catatanPotonganLainnya,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalNilaiPenjualan => $composableBuilder(
    column: $table.totalNilaiPenjualan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPengirimanPabrikTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPengirimanPabrikTable> {
  $$LocalPengirimanPabrikTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noSpb => $composableBuilder(
    column: $table.noSpb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pabrikId => $composableBuilder(
    column: $table.pabrikId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggalKirim => $composableBuilder(
    column: $table.tanggalKirim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noKendaraan => $composableBuilder(
    column: $table.noKendaraan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namaSupir => $composableBuilder(
    column: $table.namaSupir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beratKirimKg => $composableBuilder(
    column: $table.beratKirimKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beratTimbangPabrikKg => $composableBuilder(
    column: $table.beratTimbangPabrikKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toleransiSusutPersen => $composableBuilder(
    column: $table.toleransiSusutPersen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hargaPerKg => $composableBuilder(
    column: $table.hargaPerKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potonganSortasiPersen => $composableBuilder(
    column: $table.potonganSortasiPersen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potonganSortasiKg => $composableBuilder(
    column: $table.potonganSortasiKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potonganLainnyaNominal => $composableBuilder(
    column: $table.potonganLainnyaNominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatanPotonganLainnya => $composableBuilder(
    column: $table.catatanPotonganLainnya,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalNilaiPenjualan => $composableBuilder(
    column: $table.totalNilaiPenjualan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPengirimanPabrikTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPengirimanPabrikTable> {
  $$LocalPengirimanPabrikTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noSpb =>
      $composableBuilder(column: $table.noSpb, builder: (column) => column);

  GeneratedColumn<String> get pabrikId =>
      $composableBuilder(column: $table.pabrikId, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggalKirim => $composableBuilder(
    column: $table.tanggalKirim,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noKendaraan => $composableBuilder(
    column: $table.noKendaraan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get namaSupir =>
      $composableBuilder(column: $table.namaSupir, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get beratKirimKg => $composableBuilder(
    column: $table.beratKirimKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get beratTimbangPabrikKg => $composableBuilder(
    column: $table.beratTimbangPabrikKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toleransiSusutPersen => $composableBuilder(
    column: $table.toleransiSusutPersen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hargaPerKg => $composableBuilder(
    column: $table.hargaPerKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get potonganSortasiPersen => $composableBuilder(
    column: $table.potonganSortasiPersen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get potonganSortasiKg => $composableBuilder(
    column: $table.potonganSortasiKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get potonganLainnyaNominal => $composableBuilder(
    column: $table.potonganLainnyaNominal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatanPotonganLainnya => $composableBuilder(
    column: $table.catatanPotonganLainnya,
    builder: (column) => column,
  );

  GeneratedColumn<String> get totalNilaiPenjualan => $composableBuilder(
    column: $table.totalNilaiPenjualan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPengirimanPabrikTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPengirimanPabrikTable,
          LocalPengirimanPabrikData,
          $$LocalPengirimanPabrikTableFilterComposer,
          $$LocalPengirimanPabrikTableOrderingComposer,
          $$LocalPengirimanPabrikTableAnnotationComposer,
          $$LocalPengirimanPabrikTableCreateCompanionBuilder,
          $$LocalPengirimanPabrikTableUpdateCompanionBuilder,
          (
            LocalPengirimanPabrikData,
            BaseReferences<
              _$AppDatabase,
              $LocalPengirimanPabrikTable,
              LocalPengirimanPabrikData
            >,
          ),
          LocalPengirimanPabrikData,
          PrefetchHooks Function()
        > {
  $$LocalPengirimanPabrikTableTableManager(
    _$AppDatabase db,
    $LocalPengirimanPabrikTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPengirimanPabrikTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalPengirimanPabrikTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPengirimanPabrikTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> noSpb = const Value.absent(),
                Value<String> pabrikId = const Value.absent(),
                Value<DateTime> tanggalKirim = const Value.absent(),
                Value<String> noKendaraan = const Value.absent(),
                Value<String> namaSupir = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> beratKirimKg = const Value.absent(),
                Value<String?> beratTimbangPabrikKg = const Value.absent(),
                Value<String?> toleransiSusutPersen = const Value.absent(),
                Value<String?> hargaPerKg = const Value.absent(),
                Value<String?> potonganSortasiPersen = const Value.absent(),
                Value<String?> potonganSortasiKg = const Value.absent(),
                Value<String?> potonganLainnyaNominal = const Value.absent(),
                Value<String?> catatanPotonganLainnya = const Value.absent(),
                Value<String?> totalNilaiPenjualan = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPengirimanPabrikCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                noSpb: noSpb,
                pabrikId: pabrikId,
                tanggalKirim: tanggalKirim,
                noKendaraan: noKendaraan,
                namaSupir: namaSupir,
                status: status,
                beratKirimKg: beratKirimKg,
                beratTimbangPabrikKg: beratTimbangPabrikKg,
                toleransiSusutPersen: toleransiSusutPersen,
                hargaPerKg: hargaPerKg,
                potonganSortasiPersen: potonganSortasiPersen,
                potonganSortasiKg: potonganSortasiKg,
                potonganLainnyaNominal: potonganLainnyaNominal,
                catatanPotonganLainnya: catatanPotonganLainnya,
                totalNilaiPenjualan: totalNilaiPenjualan,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String noSpb,
                required String pabrikId,
                required DateTime tanggalKirim,
                required String noKendaraan,
                required String namaSupir,
                Value<String> status = const Value.absent(),
                required String beratKirimKg,
                Value<String?> beratTimbangPabrikKg = const Value.absent(),
                Value<String?> toleransiSusutPersen = const Value.absent(),
                Value<String?> hargaPerKg = const Value.absent(),
                Value<String?> potonganSortasiPersen = const Value.absent(),
                Value<String?> potonganSortasiKg = const Value.absent(),
                Value<String?> potonganLainnyaNominal = const Value.absent(),
                Value<String?> catatanPotonganLainnya = const Value.absent(),
                Value<String?> totalNilaiPenjualan = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPengirimanPabrikCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                noSpb: noSpb,
                pabrikId: pabrikId,
                tanggalKirim: tanggalKirim,
                noKendaraan: noKendaraan,
                namaSupir: namaSupir,
                status: status,
                beratKirimKg: beratKirimKg,
                beratTimbangPabrikKg: beratTimbangPabrikKg,
                toleransiSusutPersen: toleransiSusutPersen,
                hargaPerKg: hargaPerKg,
                potonganSortasiPersen: potonganSortasiPersen,
                potonganSortasiKg: potonganSortasiKg,
                potonganLainnyaNominal: potonganLainnyaNominal,
                catatanPotonganLainnya: catatanPotonganLainnya,
                totalNilaiPenjualan: totalNilaiPenjualan,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPengirimanPabrikTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPengirimanPabrikTable,
      LocalPengirimanPabrikData,
      $$LocalPengirimanPabrikTableFilterComposer,
      $$LocalPengirimanPabrikTableOrderingComposer,
      $$LocalPengirimanPabrikTableAnnotationComposer,
      $$LocalPengirimanPabrikTableCreateCompanionBuilder,
      $$LocalPengirimanPabrikTableUpdateCompanionBuilder,
      (
        LocalPengirimanPabrikData,
        BaseReferences<
          _$AppDatabase,
          $LocalPengirimanPabrikTable,
          LocalPengirimanPabrikData
        >,
      ),
      LocalPengirimanPabrikData,
      PrefetchHooks Function()
    >;
typedef $$LocalJenisPengeluaranTableCreateCompanionBuilder =
    LocalJenisPengeluaranCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<int> id,
      required String nama,
      Value<bool> isActive,
    });
typedef $$LocalJenisPengeluaranTableUpdateCompanionBuilder =
    LocalJenisPengeluaranCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<int> id,
      Value<String> nama,
      Value<bool> isActive,
    });

class $$LocalJenisPengeluaranTableFilterComposer
    extends Composer<_$AppDatabase, $LocalJenisPengeluaranTable> {
  $$LocalJenisPengeluaranTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalJenisPengeluaranTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalJenisPengeluaranTable> {
  $$LocalJenisPengeluaranTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalJenisPengeluaranTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalJenisPengeluaranTable> {
  $$LocalJenisPengeluaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalJenisPengeluaranTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalJenisPengeluaranTable,
          LocalJenisPengeluaranData,
          $$LocalJenisPengeluaranTableFilterComposer,
          $$LocalJenisPengeluaranTableOrderingComposer,
          $$LocalJenisPengeluaranTableAnnotationComposer,
          $$LocalJenisPengeluaranTableCreateCompanionBuilder,
          $$LocalJenisPengeluaranTableUpdateCompanionBuilder,
          (
            LocalJenisPengeluaranData,
            BaseReferences<
              _$AppDatabase,
              $LocalJenisPengeluaranTable,
              LocalJenisPengeluaranData
            >,
          ),
          LocalJenisPengeluaranData,
          PrefetchHooks Function()
        > {
  $$LocalJenisPengeluaranTableTableManager(
    _$AppDatabase db,
    $LocalJenisPengeluaranTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalJenisPengeluaranTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalJenisPengeluaranTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalJenisPengeluaranTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LocalJenisPengeluaranCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nama: nama,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String nama,
                Value<bool> isActive = const Value.absent(),
              }) => LocalJenisPengeluaranCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nama: nama,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalJenisPengeluaranTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalJenisPengeluaranTable,
      LocalJenisPengeluaranData,
      $$LocalJenisPengeluaranTableFilterComposer,
      $$LocalJenisPengeluaranTableOrderingComposer,
      $$LocalJenisPengeluaranTableAnnotationComposer,
      $$LocalJenisPengeluaranTableCreateCompanionBuilder,
      $$LocalJenisPengeluaranTableUpdateCompanionBuilder,
      (
        LocalJenisPengeluaranData,
        BaseReferences<
          _$AppDatabase,
          $LocalJenisPengeluaranTable,
          LocalJenisPengeluaranData
        >,
      ),
      LocalJenisPengeluaranData,
      PrefetchHooks Function()
    >;
typedef $$LocalPengeluaranTableCreateCompanionBuilder =
    LocalPengeluaranCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required int jenisPengeluaranId,
      required String nominal,
      required DateTime tanggal,
      required String keterangan,
      Value<String> metodePembayaran,
      Value<String> status,
      Value<String?> alasanBatal,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPengeluaranTableUpdateCompanionBuilder =
    LocalPengeluaranCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<int> jenisPengeluaranId,
      Value<String> nominal,
      Value<DateTime> tanggal,
      Value<String> keterangan,
      Value<String> metodePembayaran,
      Value<String> status,
      Value<String?> alasanBatal,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalPengeluaranTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPengeluaranTable> {
  $$LocalPengeluaranTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jenisPengeluaranId => $composableBuilder(
    column: $table.jenisPengeluaranId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodePembayaran => $composableBuilder(
    column: $table.metodePembayaran,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPengeluaranTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPengeluaranTable> {
  $$LocalPengeluaranTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jenisPengeluaranId => $composableBuilder(
    column: $table.jenisPengeluaranId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodePembayaran => $composableBuilder(
    column: $table.metodePembayaran,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPengeluaranTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPengeluaranTable> {
  $$LocalPengeluaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jenisPengeluaranId => $composableBuilder(
    column: $table.jenisPengeluaranId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metodePembayaran => $composableBuilder(
    column: $table.metodePembayaran,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPengeluaranTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPengeluaranTable,
          LocalPengeluaranData,
          $$LocalPengeluaranTableFilterComposer,
          $$LocalPengeluaranTableOrderingComposer,
          $$LocalPengeluaranTableAnnotationComposer,
          $$LocalPengeluaranTableCreateCompanionBuilder,
          $$LocalPengeluaranTableUpdateCompanionBuilder,
          (
            LocalPengeluaranData,
            BaseReferences<
              _$AppDatabase,
              $LocalPengeluaranTable,
              LocalPengeluaranData
            >,
          ),
          LocalPengeluaranData,
          PrefetchHooks Function()
        > {
  $$LocalPengeluaranTableTableManager(
    _$AppDatabase db,
    $LocalPengeluaranTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPengeluaranTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPengeluaranTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPengeluaranTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> jenisPengeluaranId = const Value.absent(),
                Value<String> nominal = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<String> keterangan = const Value.absent(),
                Value<String> metodePembayaran = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> alasanBatal = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPengeluaranCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                jenisPengeluaranId: jenisPengeluaranId,
                nominal: nominal,
                tanggal: tanggal,
                keterangan: keterangan,
                metodePembayaran: metodePembayaran,
                status: status,
                alasanBatal: alasanBatal,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required int jenisPengeluaranId,
                required String nominal,
                required DateTime tanggal,
                required String keterangan,
                Value<String> metodePembayaran = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> alasanBatal = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPengeluaranCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                jenisPengeluaranId: jenisPengeluaranId,
                nominal: nominal,
                tanggal: tanggal,
                keterangan: keterangan,
                metodePembayaran: metodePembayaran,
                status: status,
                alasanBatal: alasanBatal,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPengeluaranTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPengeluaranTable,
      LocalPengeluaranData,
      $$LocalPengeluaranTableFilterComposer,
      $$LocalPengeluaranTableOrderingComposer,
      $$LocalPengeluaranTableAnnotationComposer,
      $$LocalPengeluaranTableCreateCompanionBuilder,
      $$LocalPengeluaranTableUpdateCompanionBuilder,
      (
        LocalPengeluaranData,
        BaseReferences<
          _$AppDatabase,
          $LocalPengeluaranTable,
          LocalPengeluaranData
        >,
      ),
      LocalPengeluaranData,
      PrefetchHooks Function()
    >;
typedef $$LocalTopupSaldoTableCreateCompanionBuilder =
    LocalTopupSaldoCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String nominal,
      required DateTime tanggal,
      Value<String?> keterangan,
      Value<String> status,
      Value<String?> alasanBatal,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalTopupSaldoTableUpdateCompanionBuilder =
    LocalTopupSaldoCompanion Function({
      Value<bool> isSynced,
      Value<String?> deviceId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> nominal,
      Value<DateTime> tanggal,
      Value<String?> keterangan,
      Value<String> status,
      Value<String?> alasanBatal,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalTopupSaldoTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTopupSaldoTable> {
  $$LocalTopupSaldoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTopupSaldoTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTopupSaldoTable> {
  $$LocalTopupSaldoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nominal => $composableBuilder(
    column: $table.nominal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTopupSaldoTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTopupSaldoTable> {
  $$LocalTopupSaldoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get alasanBatal => $composableBuilder(
    column: $table.alasanBatal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTopupSaldoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTopupSaldoTable,
          LocalTopupSaldoData,
          $$LocalTopupSaldoTableFilterComposer,
          $$LocalTopupSaldoTableOrderingComposer,
          $$LocalTopupSaldoTableAnnotationComposer,
          $$LocalTopupSaldoTableCreateCompanionBuilder,
          $$LocalTopupSaldoTableUpdateCompanionBuilder,
          (
            LocalTopupSaldoData,
            BaseReferences<
              _$AppDatabase,
              $LocalTopupSaldoTable,
              LocalTopupSaldoData
            >,
          ),
          LocalTopupSaldoData,
          PrefetchHooks Function()
        > {
  $$LocalTopupSaldoTableTableManager(
    _$AppDatabase db,
    $LocalTopupSaldoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTopupSaldoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTopupSaldoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTopupSaldoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> nominal = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<String?> keterangan = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> alasanBatal = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTopupSaldoCompanion(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nominal: nominal,
                tanggal: tanggal,
                keterangan: keterangan,
                status: status,
                alasanBatal: alasanBatal,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isSynced = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String nominal,
                required DateTime tanggal,
                Value<String?> keterangan = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> alasanBatal = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTopupSaldoCompanion.insert(
                isSynced: isSynced,
                deviceId: deviceId,
                localUpdatedAt: localUpdatedAt,
                deletedAt: deletedAt,
                id: id,
                nominal: nominal,
                tanggal: tanggal,
                keterangan: keterangan,
                status: status,
                alasanBatal: alasanBatal,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTopupSaldoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTopupSaldoTable,
      LocalTopupSaldoData,
      $$LocalTopupSaldoTableFilterComposer,
      $$LocalTopupSaldoTableOrderingComposer,
      $$LocalTopupSaldoTableAnnotationComposer,
      $$LocalTopupSaldoTableCreateCompanionBuilder,
      $$LocalTopupSaldoTableUpdateCompanionBuilder,
      (
        LocalTopupSaldoData,
        BaseReferences<
          _$AppDatabase,
          $LocalTopupSaldoTable,
          LocalTopupSaldoData
        >,
      ),
      LocalTopupSaldoData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalPenjualTableTableManager get localPenjual =>
      $$LocalPenjualTableTableManager(_db, _db.localPenjual);
  $$LocalJenisBuahTableTableManager get localJenisBuah =>
      $$LocalJenisBuahTableTableManager(_db, _db.localJenisBuah);
  $$LocalTransaksiTableTableManager get localTransaksi =>
      $$LocalTransaksiTableTableManager(_db, _db.localTransaksi);
  $$LocalTransaksiItemTableTableManager get localTransaksiItem =>
      $$LocalTransaksiItemTableTableManager(_db, _db.localTransaksiItem);
  $$LocalPabrikTableTableManager get localPabrik =>
      $$LocalPabrikTableTableManager(_db, _db.localPabrik);
  $$LocalPengirimanPabrikTableTableManager get localPengirimanPabrik =>
      $$LocalPengirimanPabrikTableTableManager(_db, _db.localPengirimanPabrik);
  $$LocalJenisPengeluaranTableTableManager get localJenisPengeluaran =>
      $$LocalJenisPengeluaranTableTableManager(_db, _db.localJenisPengeluaran);
  $$LocalPengeluaranTableTableManager get localPengeluaran =>
      $$LocalPengeluaranTableTableManager(_db, _db.localPengeluaran);
  $$LocalTopupSaldoTableTableManager get localTopupSaldo =>
      $$LocalTopupSaldoTableTableManager(_db, _db.localTopupSaldo);
}
