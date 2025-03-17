// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CountryVisitsTable extends CountryVisits
    with TableInfo<$CountryVisitsTable, CountryVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountryVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _daysSpentMeta =
      const VerificationMeta('daysSpent');
  @override
  late final GeneratedColumn<int> daysSpent = GeneratedColumn<int>(
      'days_spent', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [countryCode, entryDate, daysSpent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'country_visits';
  @override
  VerificationContext validateIntegrity(Insertable<CountryVisit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('days_spent')) {
      context.handle(_daysSpentMeta,
          daysSpent.isAcceptableOrUnknown(data['days_spent']!, _daysSpentMeta));
    } else if (isInserting) {
      context.missing(_daysSpentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {countryCode};
  @override
  CountryVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountryVisit(
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      daysSpent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_spent'])!,
    );
  }

  @override
  $CountryVisitsTable createAlias(String alias) {
    return $CountryVisitsTable(attachedDatabase, alias);
  }
}

class CountryVisit extends DataClass implements Insertable<CountryVisit> {
  final String countryCode;
  final DateTime entryDate;
  final int daysSpent;
  const CountryVisit(
      {required this.countryCode,
      required this.entryDate,
      required this.daysSpent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['country_code'] = Variable<String>(countryCode);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['days_spent'] = Variable<int>(daysSpent);
    return map;
  }

  CountryVisitsCompanion toCompanion(bool nullToAbsent) {
    return CountryVisitsCompanion(
      countryCode: Value(countryCode),
      entryDate: Value(entryDate),
      daysSpent: Value(daysSpent),
    );
  }

  factory CountryVisit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountryVisit(
      countryCode: serializer.fromJson<String>(json['countryCode']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      daysSpent: serializer.fromJson<int>(json['daysSpent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'countryCode': serializer.toJson<String>(countryCode),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'daysSpent': serializer.toJson<int>(daysSpent),
    };
  }

  CountryVisit copyWith(
          {String? countryCode, DateTime? entryDate, int? daysSpent}) =>
      CountryVisit(
        countryCode: countryCode ?? this.countryCode,
        entryDate: entryDate ?? this.entryDate,
        daysSpent: daysSpent ?? this.daysSpent,
      );
  CountryVisit copyWithCompanion(CountryVisitsCompanion data) {
    return CountryVisit(
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      daysSpent: data.daysSpent.present ? data.daysSpent.value : this.daysSpent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountryVisit(')
          ..write('countryCode: $countryCode, ')
          ..write('entryDate: $entryDate, ')
          ..write('daysSpent: $daysSpent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(countryCode, entryDate, daysSpent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryVisit &&
          other.countryCode == this.countryCode &&
          other.entryDate == this.entryDate &&
          other.daysSpent == this.daysSpent);
}

class CountryVisitsCompanion extends UpdateCompanion<CountryVisit> {
  final Value<String> countryCode;
  final Value<DateTime> entryDate;
  final Value<int> daysSpent;
  final Value<int> rowid;
  const CountryVisitsCompanion({
    this.countryCode = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.daysSpent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountryVisitsCompanion.insert({
    required String countryCode,
    required DateTime entryDate,
    required int daysSpent,
    this.rowid = const Value.absent(),
  })  : countryCode = Value(countryCode),
        entryDate = Value(entryDate),
        daysSpent = Value(daysSpent);
  static Insertable<CountryVisit> custom({
    Expression<String>? countryCode,
    Expression<DateTime>? entryDate,
    Expression<int>? daysSpent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (countryCode != null) 'country_code': countryCode,
      if (entryDate != null) 'entry_date': entryDate,
      if (daysSpent != null) 'days_spent': daysSpent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountryVisitsCompanion copyWith(
      {Value<String>? countryCode,
      Value<DateTime>? entryDate,
      Value<int>? daysSpent,
      Value<int>? rowid}) {
    return CountryVisitsCompanion(
      countryCode: countryCode ?? this.countryCode,
      entryDate: entryDate ?? this.entryDate,
      daysSpent: daysSpent ?? this.daysSpent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (daysSpent.present) {
      map['days_spent'] = Variable<int>(daysSpent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountryVisitsCompanion(')
          ..write('countryCode: $countryCode, ')
          ..write('entryDate: $entryDate, ')
          ..write('daysSpent: $daysSpent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationLogsTable extends LocationLogs
    with TableInfo<$LocationLogsTable, LocationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _logDateTimeMeta =
      const VerificationMeta('logDateTime');
  @override
  late final GeneratedColumn<DateTime> logDateTime = GeneratedColumn<DateTime>(
      'log_date_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, logDateTime, status, countryCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocationLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('log_date_time')) {
      context.handle(
          _logDateTimeMeta,
          logDateTime.isAcceptableOrUnknown(
              data['log_date_time']!, _logDateTimeMeta));
    } else if (isInserting) {
      context.missing(_logDateTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      logDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}log_date_time'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code']),
    );
  }

  @override
  $LocationLogsTable createAlias(String alias) {
    return $LocationLogsTable(attachedDatabase, alias);
  }
}

class LocationLog extends DataClass implements Insertable<LocationLog> {
  final int id;
  final DateTime logDateTime;
  final String status;
  final String? countryCode;
  const LocationLog(
      {required this.id,
      required this.logDateTime,
      required this.status,
      this.countryCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['log_date_time'] = Variable<DateTime>(logDateTime);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    return map;
  }

  LocationLogsCompanion toCompanion(bool nullToAbsent) {
    return LocationLogsCompanion(
      id: Value(id),
      logDateTime: Value(logDateTime),
      status: Value(status),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
    );
  }

  factory LocationLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationLog(
      id: serializer.fromJson<int>(json['id']),
      logDateTime: serializer.fromJson<DateTime>(json['logDateTime']),
      status: serializer.fromJson<String>(json['status']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'logDateTime': serializer.toJson<DateTime>(logDateTime),
      'status': serializer.toJson<String>(status),
      'countryCode': serializer.toJson<String?>(countryCode),
    };
  }

  LocationLog copyWith(
          {int? id,
          DateTime? logDateTime,
          String? status,
          Value<String?> countryCode = const Value.absent()}) =>
      LocationLog(
        id: id ?? this.id,
        logDateTime: logDateTime ?? this.logDateTime,
        status: status ?? this.status,
        countryCode: countryCode.present ? countryCode.value : this.countryCode,
      );
  LocationLog copyWithCompanion(LocationLogsCompanion data) {
    return LocationLog(
      id: data.id.present ? data.id.value : this.id,
      logDateTime:
          data.logDateTime.present ? data.logDateTime.value : this.logDateTime,
      status: data.status.present ? data.status.value : this.status,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationLog(')
          ..write('id: $id, ')
          ..write('logDateTime: $logDateTime, ')
          ..write('status: $status, ')
          ..write('countryCode: $countryCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, logDateTime, status, countryCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationLog &&
          other.id == this.id &&
          other.logDateTime == this.logDateTime &&
          other.status == this.status &&
          other.countryCode == this.countryCode);
}

class LocationLogsCompanion extends UpdateCompanion<LocationLog> {
  final Value<int> id;
  final Value<DateTime> logDateTime;
  final Value<String> status;
  final Value<String?> countryCode;
  const LocationLogsCompanion({
    this.id = const Value.absent(),
    this.logDateTime = const Value.absent(),
    this.status = const Value.absent(),
    this.countryCode = const Value.absent(),
  });
  LocationLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime logDateTime,
    required String status,
    this.countryCode = const Value.absent(),
  })  : logDateTime = Value(logDateTime),
        status = Value(status);
  static Insertable<LocationLog> custom({
    Expression<int>? id,
    Expression<DateTime>? logDateTime,
    Expression<String>? status,
    Expression<String>? countryCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (logDateTime != null) 'log_date_time': logDateTime,
      if (status != null) 'status': status,
      if (countryCode != null) 'country_code': countryCode,
    });
  }

  LocationLogsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? logDateTime,
      Value<String>? status,
      Value<String?>? countryCode}) {
    return LocationLogsCompanion(
      id: id ?? this.id,
      logDateTime: logDateTime ?? this.logDateTime,
      status: status ?? this.status,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (logDateTime.present) {
      map['log_date_time'] = Variable<DateTime>(logDateTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationLogsCompanion(')
          ..write('id: $id, ')
          ..write('logDateTime: $logDateTime, ')
          ..write('status: $status, ')
          ..write('countryCode: $countryCode')
          ..write(')'))
        .toString();
  }
}

class $LogCountryRelationsTable extends LogCountryRelations
    with TableInfo<$LogCountryRelationsTable, LogCountryRelation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogCountryRelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<int> logId = GeneratedColumn<int>(
      'log_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES location_logs (id)'));
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES country_visits (country_code)'));
  @override
  List<GeneratedColumn> get $columns => [logId, countryCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_country_relations';
  @override
  VerificationContext validateIntegrity(Insertable<LogCountryRelation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
          _logIdMeta, logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta));
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId, countryCode};
  @override
  LogCountryRelation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogCountryRelation(
      logId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}log_id'])!,
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
    );
  }

  @override
  $LogCountryRelationsTable createAlias(String alias) {
    return $LogCountryRelationsTable(attachedDatabase, alias);
  }
}

class LogCountryRelation extends DataClass
    implements Insertable<LogCountryRelation> {
  final int logId;
  final String countryCode;
  const LogCountryRelation({required this.logId, required this.countryCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<int>(logId);
    map['country_code'] = Variable<String>(countryCode);
    return map;
  }

  LogCountryRelationsCompanion toCompanion(bool nullToAbsent) {
    return LogCountryRelationsCompanion(
      logId: Value(logId),
      countryCode: Value(countryCode),
    );
  }

  factory LogCountryRelation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogCountryRelation(
      logId: serializer.fromJson<int>(json['logId']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<int>(logId),
      'countryCode': serializer.toJson<String>(countryCode),
    };
  }

  LogCountryRelation copyWith({int? logId, String? countryCode}) =>
      LogCountryRelation(
        logId: logId ?? this.logId,
        countryCode: countryCode ?? this.countryCode,
      );
  LogCountryRelation copyWithCompanion(LogCountryRelationsCompanion data) {
    return LogCountryRelation(
      logId: data.logId.present ? data.logId.value : this.logId,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogCountryRelation(')
          ..write('logId: $logId, ')
          ..write('countryCode: $countryCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(logId, countryCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogCountryRelation &&
          other.logId == this.logId &&
          other.countryCode == this.countryCode);
}

class LogCountryRelationsCompanion extends UpdateCompanion<LogCountryRelation> {
  final Value<int> logId;
  final Value<String> countryCode;
  final Value<int> rowid;
  const LogCountryRelationsCompanion({
    this.logId = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogCountryRelationsCompanion.insert({
    required int logId,
    required String countryCode,
    this.rowid = const Value.absent(),
  })  : logId = Value(logId),
        countryCode = Value(countryCode);
  static Insertable<LogCountryRelation> custom({
    Expression<int>? logId,
    Expression<String>? countryCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (countryCode != null) 'country_code': countryCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogCountryRelationsCompanion copyWith(
      {Value<int>? logId, Value<String>? countryCode, Value<int>? rowid}) {
    return LogCountryRelationsCompanion(
      logId: logId ?? this.logId,
      countryCode: countryCode ?? this.countryCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<int>(logId.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogCountryRelationsCompanion(')
          ..write('logId: $logId, ')
          ..write('countryCode: $countryCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountryVisitsTable countryVisits = $CountryVisitsTable(this);
  late final $LocationLogsTable locationLogs = $LocationLogsTable(this);
  late final $LogCountryRelationsTable logCountryRelations =
      $LogCountryRelationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [countryVisits, locationLogs, logCountryRelations];
}

typedef $$CountryVisitsTableCreateCompanionBuilder = CountryVisitsCompanion
    Function({
  required String countryCode,
  required DateTime entryDate,
  required int daysSpent,
  Value<int> rowid,
});
typedef $$CountryVisitsTableUpdateCompanionBuilder = CountryVisitsCompanion
    Function({
  Value<String> countryCode,
  Value<DateTime> entryDate,
  Value<int> daysSpent,
  Value<int> rowid,
});

final class $$CountryVisitsTableReferences
    extends BaseReferences<_$AppDatabase, $CountryVisitsTable, CountryVisit> {
  $$CountryVisitsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LogCountryRelationsTable,
      List<LogCountryRelation>> _logCountryRelationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.logCountryRelations,
          aliasName: $_aliasNameGenerator(db.countryVisits.countryCode,
              db.logCountryRelations.countryCode));

  $$LogCountryRelationsTableProcessedTableManager get logCountryRelationsRefs {
    final manager =
        $$LogCountryRelationsTableTableManager($_db, $_db.logCountryRelations)
            .filter((f) => f.countryCode.countryCode
                .sqlEquals($_itemColumn<String>('country_code')!));

    final cache =
        $_typedResult.readTableOrNull(_logCountryRelationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CountryVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $CountryVisitsTable> {
  $$CountryVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysSpent => $composableBuilder(
      column: $table.daysSpent, builder: (column) => ColumnFilters(column));

  Expression<bool> logCountryRelationsRefs(
      Expression<bool> Function($$LogCountryRelationsTableFilterComposer f) f) {
    final $$LogCountryRelationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryCode,
        referencedTable: $db.logCountryRelations,
        getReferencedColumn: (t) => t.countryCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LogCountryRelationsTableFilterComposer(
              $db: $db,
              $table: $db.logCountryRelations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CountryVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CountryVisitsTable> {
  $$CountryVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysSpent => $composableBuilder(
      column: $table.daysSpent, builder: (column) => ColumnOrderings(column));
}

class $$CountryVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountryVisitsTable> {
  $$CountryVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<int> get daysSpent =>
      $composableBuilder(column: $table.daysSpent, builder: (column) => column);

  Expression<T> logCountryRelationsRefs<T extends Object>(
      Expression<T> Function($$LogCountryRelationsTableAnnotationComposer a)
          f) {
    final $$LogCountryRelationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.countryCode,
            referencedTable: $db.logCountryRelations,
            getReferencedColumn: (t) => t.countryCode,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LogCountryRelationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.logCountryRelations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CountryVisitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CountryVisitsTable,
    CountryVisit,
    $$CountryVisitsTableFilterComposer,
    $$CountryVisitsTableOrderingComposer,
    $$CountryVisitsTableAnnotationComposer,
    $$CountryVisitsTableCreateCompanionBuilder,
    $$CountryVisitsTableUpdateCompanionBuilder,
    (CountryVisit, $$CountryVisitsTableReferences),
    CountryVisit,
    PrefetchHooks Function({bool logCountryRelationsRefs})> {
  $$CountryVisitsTableTableManager(_$AppDatabase db, $CountryVisitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountryVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountryVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountryVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> countryCode = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<int> daysSpent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountryVisitsCompanion(
            countryCode: countryCode,
            entryDate: entryDate,
            daysSpent: daysSpent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String countryCode,
            required DateTime entryDate,
            required int daysSpent,
            Value<int> rowid = const Value.absent(),
          }) =>
              CountryVisitsCompanion.insert(
            countryCode: countryCode,
            entryDate: entryDate,
            daysSpent: daysSpent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CountryVisitsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({logCountryRelationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (logCountryRelationsRefs) db.logCountryRelations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (logCountryRelationsRefs)
                    await $_getPrefetchedData<CountryVisit, $CountryVisitsTable,
                            LogCountryRelation>(
                        currentTable: table,
                        referencedTable: $$CountryVisitsTableReferences
                            ._logCountryRelationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CountryVisitsTableReferences(db, table, p0)
                                .logCountryRelationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.countryCode == item.countryCode),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CountryVisitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CountryVisitsTable,
    CountryVisit,
    $$CountryVisitsTableFilterComposer,
    $$CountryVisitsTableOrderingComposer,
    $$CountryVisitsTableAnnotationComposer,
    $$CountryVisitsTableCreateCompanionBuilder,
    $$CountryVisitsTableUpdateCompanionBuilder,
    (CountryVisit, $$CountryVisitsTableReferences),
    CountryVisit,
    PrefetchHooks Function({bool logCountryRelationsRefs})>;
typedef $$LocationLogsTableCreateCompanionBuilder = LocationLogsCompanion
    Function({
  Value<int> id,
  required DateTime logDateTime,
  required String status,
  Value<String?> countryCode,
});
typedef $$LocationLogsTableUpdateCompanionBuilder = LocationLogsCompanion
    Function({
  Value<int> id,
  Value<DateTime> logDateTime,
  Value<String> status,
  Value<String?> countryCode,
});

final class $$LocationLogsTableReferences
    extends BaseReferences<_$AppDatabase, $LocationLogsTable, LocationLog> {
  $$LocationLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LogCountryRelationsTable,
      List<LogCountryRelation>> _logCountryRelationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.logCountryRelations,
          aliasName: $_aliasNameGenerator(
              db.locationLogs.id, db.logCountryRelations.logId));

  $$LogCountryRelationsTableProcessedTableManager get logCountryRelationsRefs {
    final manager =
        $$LogCountryRelationsTableTableManager($_db, $_db.logCountryRelations)
            .filter((f) => f.logId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_logCountryRelationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationLogsTable> {
  $$LocationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDateTime => $composableBuilder(
      column: $table.logDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnFilters(column));

  Expression<bool> logCountryRelationsRefs(
      Expression<bool> Function($$LogCountryRelationsTableFilterComposer f) f) {
    final $$LogCountryRelationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.logCountryRelations,
        getReferencedColumn: (t) => t.logId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LogCountryRelationsTableFilterComposer(
              $db: $db,
              $table: $db.logCountryRelations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationLogsTable> {
  $$LocationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDateTime => $composableBuilder(
      column: $table.logDateTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnOrderings(column));
}

class $$LocationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationLogsTable> {
  $$LocationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get logDateTime => $composableBuilder(
      column: $table.logDateTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => column);

  Expression<T> logCountryRelationsRefs<T extends Object>(
      Expression<T> Function($$LogCountryRelationsTableAnnotationComposer a)
          f) {
    final $$LogCountryRelationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.logCountryRelations,
            getReferencedColumn: (t) => t.logId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LogCountryRelationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.logCountryRelations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LocationLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationLogsTable,
    LocationLog,
    $$LocationLogsTableFilterComposer,
    $$LocationLogsTableOrderingComposer,
    $$LocationLogsTableAnnotationComposer,
    $$LocationLogsTableCreateCompanionBuilder,
    $$LocationLogsTableUpdateCompanionBuilder,
    (LocationLog, $$LocationLogsTableReferences),
    LocationLog,
    PrefetchHooks Function({bool logCountryRelationsRefs})> {
  $$LocationLogsTableTableManager(_$AppDatabase db, $LocationLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> logDateTime = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> countryCode = const Value.absent(),
          }) =>
              LocationLogsCompanion(
            id: id,
            logDateTime: logDateTime,
            status: status,
            countryCode: countryCode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime logDateTime,
            required String status,
            Value<String?> countryCode = const Value.absent(),
          }) =>
              LocationLogsCompanion.insert(
            id: id,
            logDateTime: logDateTime,
            status: status,
            countryCode: countryCode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocationLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({logCountryRelationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (logCountryRelationsRefs) db.logCountryRelations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (logCountryRelationsRefs)
                    await $_getPrefetchedData<LocationLog, $LocationLogsTable,
                            LogCountryRelation>(
                        currentTable: table,
                        referencedTable: $$LocationLogsTableReferences
                            ._logCountryRelationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocationLogsTableReferences(db, table, p0)
                                .logCountryRelationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.logId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocationLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocationLogsTable,
    LocationLog,
    $$LocationLogsTableFilterComposer,
    $$LocationLogsTableOrderingComposer,
    $$LocationLogsTableAnnotationComposer,
    $$LocationLogsTableCreateCompanionBuilder,
    $$LocationLogsTableUpdateCompanionBuilder,
    (LocationLog, $$LocationLogsTableReferences),
    LocationLog,
    PrefetchHooks Function({bool logCountryRelationsRefs})>;
typedef $$LogCountryRelationsTableCreateCompanionBuilder
    = LogCountryRelationsCompanion Function({
  required int logId,
  required String countryCode,
  Value<int> rowid,
});
typedef $$LogCountryRelationsTableUpdateCompanionBuilder
    = LogCountryRelationsCompanion Function({
  Value<int> logId,
  Value<String> countryCode,
  Value<int> rowid,
});

final class $$LogCountryRelationsTableReferences extends BaseReferences<
    _$AppDatabase, $LogCountryRelationsTable, LogCountryRelation> {
  $$LogCountryRelationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LocationLogsTable _logIdTable(_$AppDatabase db) =>
      db.locationLogs.createAlias($_aliasNameGenerator(
          db.logCountryRelations.logId, db.locationLogs.id));

  $$LocationLogsTableProcessedTableManager get logId {
    final $_column = $_itemColumn<int>('log_id')!;

    final manager = $$LocationLogsTableTableManager($_db, $_db.locationLogs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_logIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CountryVisitsTable _countryCodeTable(_$AppDatabase db) =>
      db.countryVisits.createAlias($_aliasNameGenerator(
          db.logCountryRelations.countryCode, db.countryVisits.countryCode));

  $$CountryVisitsTableProcessedTableManager get countryCode {
    final $_column = $_itemColumn<String>('country_code')!;

    final manager = $$CountryVisitsTableTableManager($_db, $_db.countryVisits)
        .filter((f) => f.countryCode.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_countryCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LogCountryRelationsTableFilterComposer
    extends Composer<_$AppDatabase, $LogCountryRelationsTable> {
  $$LogCountryRelationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LocationLogsTableFilterComposer get logId {
    final $$LocationLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.logId,
        referencedTable: $db.locationLogs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationLogsTableFilterComposer(
              $db: $db,
              $table: $db.locationLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CountryVisitsTableFilterComposer get countryCode {
    final $$CountryVisitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryCode,
        referencedTable: $db.countryVisits,
        getReferencedColumn: (t) => t.countryCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountryVisitsTableFilterComposer(
              $db: $db,
              $table: $db.countryVisits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LogCountryRelationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LogCountryRelationsTable> {
  $$LogCountryRelationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LocationLogsTableOrderingComposer get logId {
    final $$LocationLogsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.logId,
        referencedTable: $db.locationLogs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationLogsTableOrderingComposer(
              $db: $db,
              $table: $db.locationLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CountryVisitsTableOrderingComposer get countryCode {
    final $$CountryVisitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryCode,
        referencedTable: $db.countryVisits,
        getReferencedColumn: (t) => t.countryCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountryVisitsTableOrderingComposer(
              $db: $db,
              $table: $db.countryVisits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LogCountryRelationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogCountryRelationsTable> {
  $$LogCountryRelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LocationLogsTableAnnotationComposer get logId {
    final $$LocationLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.logId,
        referencedTable: $db.locationLogs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.locationLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CountryVisitsTableAnnotationComposer get countryCode {
    final $$CountryVisitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryCode,
        referencedTable: $db.countryVisits,
        getReferencedColumn: (t) => t.countryCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountryVisitsTableAnnotationComposer(
              $db: $db,
              $table: $db.countryVisits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LogCountryRelationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LogCountryRelationsTable,
    LogCountryRelation,
    $$LogCountryRelationsTableFilterComposer,
    $$LogCountryRelationsTableOrderingComposer,
    $$LogCountryRelationsTableAnnotationComposer,
    $$LogCountryRelationsTableCreateCompanionBuilder,
    $$LogCountryRelationsTableUpdateCompanionBuilder,
    (LogCountryRelation, $$LogCountryRelationsTableReferences),
    LogCountryRelation,
    PrefetchHooks Function({bool logId, bool countryCode})> {
  $$LogCountryRelationsTableTableManager(
      _$AppDatabase db, $LogCountryRelationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogCountryRelationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogCountryRelationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogCountryRelationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> logId = const Value.absent(),
            Value<String> countryCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LogCountryRelationsCompanion(
            logId: logId,
            countryCode: countryCode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int logId,
            required String countryCode,
            Value<int> rowid = const Value.absent(),
          }) =>
              LogCountryRelationsCompanion.insert(
            logId: logId,
            countryCode: countryCode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LogCountryRelationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({logId = false, countryCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (logId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.logId,
                    referencedTable:
                        $$LogCountryRelationsTableReferences._logIdTable(db),
                    referencedColumn:
                        $$LogCountryRelationsTableReferences._logIdTable(db).id,
                  ) as T;
                }
                if (countryCode) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.countryCode,
                    referencedTable: $$LogCountryRelationsTableReferences
                        ._countryCodeTable(db),
                    referencedColumn: $$LogCountryRelationsTableReferences
                        ._countryCodeTable(db)
                        .countryCode,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LogCountryRelationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LogCountryRelationsTable,
    LogCountryRelation,
    $$LogCountryRelationsTableFilterComposer,
    $$LogCountryRelationsTableOrderingComposer,
    $$LogCountryRelationsTableAnnotationComposer,
    $$LogCountryRelationsTableCreateCompanionBuilder,
    $$LogCountryRelationsTableUpdateCompanionBuilder,
    (LogCountryRelation, $$LogCountryRelationsTableReferences),
    LogCountryRelation,
    PrefetchHooks Function({bool logId, bool countryCode})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountryVisitsTableTableManager get countryVisits =>
      $$CountryVisitsTableTableManager(_db, _db.countryVisits);
  $$LocationLogsTableTableManager get locationLogs =>
      $$LocationLogsTableTableManager(_db, _db.locationLogs);
  $$LogCountryRelationsTableTableManager get logCountryRelations =>
      $$LogCountryRelationsTableTableManager(_db, _db.logCountryRelations);
}
