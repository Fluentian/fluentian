// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedCoursesTable extends CachedCourses
    with TableInfo<$CachedCoursesTable, CachedCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _levelMinMeta = const VerificationMeta(
    'levelMin',
  );
  @override
  late final GeneratedColumn<String> levelMin = GeneratedColumn<String>(
    'level_min',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMaxMeta = const VerificationMeta(
    'levelMax',
  );
  @override
  late final GeneratedColumn<String> levelMax = GeneratedColumn<String>(
    'level_max',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _contentLanguageMeta = const VerificationMeta(
    'contentLanguage',
  );
  @override
  late final GeneratedColumn<String> contentLanguage = GeneratedColumn<String>(
    'content_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    title,
    description,
    levelMin,
    levelMax,
    contentVersion,
    isPublished,
    contentLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCourse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('level_min')) {
      context.handle(
        _levelMinMeta,
        levelMin.isAcceptableOrUnknown(data['level_min']!, _levelMinMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMinMeta);
    }
    if (data.containsKey('level_max')) {
      context.handle(
        _levelMaxMeta,
        levelMax.isAcceptableOrUnknown(data['level_max']!, _levelMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMaxMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('content_language')) {
      context.handle(
        _contentLanguageMeta,
        contentLanguage.isAcceptableOrUnknown(
          data['content_language']!,
          _contentLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCourse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      levelMin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_min'],
      )!,
      levelMax: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_max'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      isPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_published'],
      )!,
      contentLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_language'],
      )!,
    );
  }

  @override
  $CachedCoursesTable createAlias(String alias) {
    return $CachedCoursesTable(attachedDatabase, alias);
  }
}

class CachedCourse extends DataClass implements Insertable<CachedCourse> {
  final String id;
  final String code;
  final String title;
  final String description;
  final String levelMin;
  final String levelMax;
  final int contentVersion;
  final bool isPublished;
  final String contentLanguage;
  const CachedCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.levelMin,
    required this.levelMax,
    required this.contentVersion,
    required this.isPublished,
    required this.contentLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['level_min'] = Variable<String>(levelMin);
    map['level_max'] = Variable<String>(levelMax);
    map['content_version'] = Variable<int>(contentVersion);
    map['is_published'] = Variable<bool>(isPublished);
    map['content_language'] = Variable<String>(contentLanguage);
    return map;
  }

  CachedCoursesCompanion toCompanion(bool nullToAbsent) {
    return CachedCoursesCompanion(
      id: Value(id),
      code: Value(code),
      title: Value(title),
      description: Value(description),
      levelMin: Value(levelMin),
      levelMax: Value(levelMax),
      contentVersion: Value(contentVersion),
      isPublished: Value(isPublished),
      contentLanguage: Value(contentLanguage),
    );
  }

  factory CachedCourse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCourse(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      levelMin: serializer.fromJson<String>(json['levelMin']),
      levelMax: serializer.fromJson<String>(json['levelMax']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      contentLanguage: serializer.fromJson<String>(json['contentLanguage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'levelMin': serializer.toJson<String>(levelMin),
      'levelMax': serializer.toJson<String>(levelMax),
      'contentVersion': serializer.toJson<int>(contentVersion),
      'isPublished': serializer.toJson<bool>(isPublished),
      'contentLanguage': serializer.toJson<String>(contentLanguage),
    };
  }

  CachedCourse copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? levelMin,
    String? levelMax,
    int? contentVersion,
    bool? isPublished,
    String? contentLanguage,
  }) => CachedCourse(
    id: id ?? this.id,
    code: code ?? this.code,
    title: title ?? this.title,
    description: description ?? this.description,
    levelMin: levelMin ?? this.levelMin,
    levelMax: levelMax ?? this.levelMax,
    contentVersion: contentVersion ?? this.contentVersion,
    isPublished: isPublished ?? this.isPublished,
    contentLanguage: contentLanguage ?? this.contentLanguage,
  );
  CachedCourse copyWithCompanion(CachedCoursesCompanion data) {
    return CachedCourse(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      levelMin: data.levelMin.present ? data.levelMin.value : this.levelMin,
      levelMax: data.levelMax.present ? data.levelMax.value : this.levelMax,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      isPublished: data.isPublished.present
          ? data.isPublished.value
          : this.isPublished,
      contentLanguage: data.contentLanguage.present
          ? data.contentLanguage.value
          : this.contentLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCourse(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('levelMin: $levelMin, ')
          ..write('levelMax: $levelMax, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('isPublished: $isPublished, ')
          ..write('contentLanguage: $contentLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    title,
    description,
    levelMin,
    levelMax,
    contentVersion,
    isPublished,
    contentLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCourse &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.levelMin == this.levelMin &&
          other.levelMax == this.levelMax &&
          other.contentVersion == this.contentVersion &&
          other.isPublished == this.isPublished &&
          other.contentLanguage == this.contentLanguage);
}

class CachedCoursesCompanion extends UpdateCompanion<CachedCourse> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> title;
  final Value<String> description;
  final Value<String> levelMin;
  final Value<String> levelMax;
  final Value<int> contentVersion;
  final Value<bool> isPublished;
  final Value<String> contentLanguage;
  final Value<int> rowid;
  const CachedCoursesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.levelMin = const Value.absent(),
    this.levelMax = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCoursesCompanion.insert({
    required String id,
    required String code,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required String levelMin,
    required String levelMax,
    this.contentVersion = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       levelMin = Value(levelMin),
       levelMax = Value(levelMax);
  static Insertable<CachedCourse> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? levelMin,
    Expression<String>? levelMax,
    Expression<int>? contentVersion,
    Expression<bool>? isPublished,
    Expression<String>? contentLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (levelMin != null) 'level_min': levelMin,
      if (levelMax != null) 'level_max': levelMax,
      if (contentVersion != null) 'content_version': contentVersion,
      if (isPublished != null) 'is_published': isPublished,
      if (contentLanguage != null) 'content_language': contentLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCoursesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? title,
    Value<String>? description,
    Value<String>? levelMin,
    Value<String>? levelMax,
    Value<int>? contentVersion,
    Value<bool>? isPublished,
    Value<String>? contentLanguage,
    Value<int>? rowid,
  }) {
    return CachedCoursesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      levelMin: levelMin ?? this.levelMin,
      levelMax: levelMax ?? this.levelMax,
      contentVersion: contentVersion ?? this.contentVersion,
      isPublished: isPublished ?? this.isPublished,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (levelMin.present) {
      map['level_min'] = Variable<String>(levelMin.value);
    }
    if (levelMax.present) {
      map['level_max'] = Variable<String>(levelMax.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (contentLanguage.present) {
      map['content_language'] = Variable<String>(contentLanguage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCoursesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('levelMin: $levelMin, ')
          ..write('levelMax: $levelMax, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('isPublished: $isPublished, ')
          ..write('contentLanguage: $contentLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedUnitsTable extends CachedUnits
    with TableInfo<$CachedUnitsTable, CachedUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitKindMeta = const VerificationMeta(
    'unitKind',
  );
  @override
  late final GeneratedColumn<String> unitKind = GeneratedColumn<String>(
    'unit_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitNoMeta = const VerificationMeta('unitNo');
  @override
  late final GeneratedColumn<int> unitNo = GeneratedColumn<int>(
    'unit_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _contentLanguageMeta = const VerificationMeta(
    'contentLanguage',
  );
  @override
  late final GeneratedColumn<String> contentLanguage = GeneratedColumn<String>(
    'content_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    unitKind,
    unitNo,
    title,
    description,
    contentVersion,
    contentLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('unit_kind')) {
      context.handle(
        _unitKindMeta,
        unitKind.isAcceptableOrUnknown(data['unit_kind']!, _unitKindMeta),
      );
    } else if (isInserting) {
      context.missing(_unitKindMeta);
    }
    if (data.containsKey('unit_no')) {
      context.handle(
        _unitNoMeta,
        unitNo.isAcceptableOrUnknown(data['unit_no']!, _unitNoMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNoMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    }
    if (data.containsKey('content_language')) {
      context.handle(
        _contentLanguageMeta,
        contentLanguage.isAcceptableOrUnknown(
          data['content_language']!,
          _contentLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUnit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      unitKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_kind'],
      )!,
      unitNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_no'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      contentLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_language'],
      )!,
    );
  }

  @override
  $CachedUnitsTable createAlias(String alias) {
    return $CachedUnitsTable(attachedDatabase, alias);
  }
}

class CachedUnit extends DataClass implements Insertable<CachedUnit> {
  final String id;
  final String courseId;
  final String unitKind;
  final int unitNo;
  final String title;
  final String description;
  final int contentVersion;
  final String contentLanguage;
  const CachedUnit({
    required this.id,
    required this.courseId,
    required this.unitKind,
    required this.unitNo,
    required this.title,
    required this.description,
    required this.contentVersion,
    required this.contentLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    map['unit_kind'] = Variable<String>(unitKind);
    map['unit_no'] = Variable<int>(unitNo);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['content_version'] = Variable<int>(contentVersion);
    map['content_language'] = Variable<String>(contentLanguage);
    return map;
  }

  CachedUnitsCompanion toCompanion(bool nullToAbsent) {
    return CachedUnitsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      unitKind: Value(unitKind),
      unitNo: Value(unitNo),
      title: Value(title),
      description: Value(description),
      contentVersion: Value(contentVersion),
      contentLanguage: Value(contentLanguage),
    );
  }

  factory CachedUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUnit(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      unitKind: serializer.fromJson<String>(json['unitKind']),
      unitNo: serializer.fromJson<int>(json['unitNo']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
      contentLanguage: serializer.fromJson<String>(json['contentLanguage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'unitKind': serializer.toJson<String>(unitKind),
      'unitNo': serializer.toJson<int>(unitNo),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'contentVersion': serializer.toJson<int>(contentVersion),
      'contentLanguage': serializer.toJson<String>(contentLanguage),
    };
  }

  CachedUnit copyWith({
    String? id,
    String? courseId,
    String? unitKind,
    int? unitNo,
    String? title,
    String? description,
    int? contentVersion,
    String? contentLanguage,
  }) => CachedUnit(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    unitKind: unitKind ?? this.unitKind,
    unitNo: unitNo ?? this.unitNo,
    title: title ?? this.title,
    description: description ?? this.description,
    contentVersion: contentVersion ?? this.contentVersion,
    contentLanguage: contentLanguage ?? this.contentLanguage,
  );
  CachedUnit copyWithCompanion(CachedUnitsCompanion data) {
    return CachedUnit(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      unitKind: data.unitKind.present ? data.unitKind.value : this.unitKind,
      unitNo: data.unitNo.present ? data.unitNo.value : this.unitNo,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      contentLanguage: data.contentLanguage.present
          ? data.contentLanguage.value
          : this.contentLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUnit(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('unitKind: $unitKind, ')
          ..write('unitNo: $unitNo, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('contentLanguage: $contentLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    unitKind,
    unitNo,
    title,
    description,
    contentVersion,
    contentLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUnit &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.unitKind == this.unitKind &&
          other.unitNo == this.unitNo &&
          other.title == this.title &&
          other.description == this.description &&
          other.contentVersion == this.contentVersion &&
          other.contentLanguage == this.contentLanguage);
}

class CachedUnitsCompanion extends UpdateCompanion<CachedUnit> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> unitKind;
  final Value<int> unitNo;
  final Value<String> title;
  final Value<String> description;
  final Value<int> contentVersion;
  final Value<String> contentLanguage;
  final Value<int> rowid;
  const CachedUnitsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.unitKind = const Value.absent(),
    this.unitNo = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUnitsCompanion.insert({
    required String id,
    required String courseId,
    required String unitKind,
    required int unitNo,
    required String title,
    this.description = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       unitKind = Value(unitKind),
       unitNo = Value(unitNo),
       title = Value(title);
  static Insertable<CachedUnit> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? unitKind,
    Expression<int>? unitNo,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? contentVersion,
    Expression<String>? contentLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (unitKind != null) 'unit_kind': unitKind,
      if (unitNo != null) 'unit_no': unitNo,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (contentVersion != null) 'content_version': contentVersion,
      if (contentLanguage != null) 'content_language': contentLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? courseId,
    Value<String>? unitKind,
    Value<int>? unitNo,
    Value<String>? title,
    Value<String>? description,
    Value<int>? contentVersion,
    Value<String>? contentLanguage,
    Value<int>? rowid,
  }) {
    return CachedUnitsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      unitKind: unitKind ?? this.unitKind,
      unitNo: unitNo ?? this.unitNo,
      title: title ?? this.title,
      description: description ?? this.description,
      contentVersion: contentVersion ?? this.contentVersion,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (unitKind.present) {
      map['unit_kind'] = Variable<String>(unitKind.value);
    }
    if (unitNo.present) {
      map['unit_no'] = Variable<int>(unitNo.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (contentLanguage.present) {
      map['content_language'] = Variable<String>(contentLanguage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUnitsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('unitKind: $unitKind, ')
          ..write('unitNo: $unitNo, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('contentLanguage: $contentLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedLessonsTable extends CachedLessons
    with TableInfo<$CachedLessonsTable, CachedLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedLessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonKindMeta = const VerificationMeta(
    'lessonKind',
  );
  @override
  late final GeneratedColumn<String> lessonKind = GeneratedColumn<String>(
    'lesson_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceNoMeta = const VerificationMeta(
    'sequenceNo',
  );
  @override
  late final GeneratedColumn<int> sequenceNo = GeneratedColumn<int>(
    'sequence_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _detailJsonMeta = const VerificationMeta(
    'detailJson',
  );
  @override
  late final GeneratedColumn<String> detailJson = GeneratedColumn<String>(
    'detail_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailFetchedAtMeta = const VerificationMeta(
    'detailFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detailFetchedAt =
      GeneratedColumn<DateTime>(
        'detail_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _contentLanguageMeta = const VerificationMeta(
    'contentLanguage',
  );
  @override
  late final GeneratedColumn<String> contentLanguage = GeneratedColumn<String>(
    'content_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitId,
    courseId,
    lessonKind,
    sequenceNo,
    title,
    description,
    estimatedMinutes,
    xpReward,
    isPublished,
    contentVersion,
    detailJson,
    detailFetchedAt,
    contentLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedLesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('lesson_kind')) {
      context.handle(
        _lessonKindMeta,
        lessonKind.isAcceptableOrUnknown(data['lesson_kind']!, _lessonKindMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonKindMeta);
    }
    if (data.containsKey('sequence_no')) {
      context.handle(
        _sequenceNoMeta,
        sequenceNo.isAcceptableOrUnknown(data['sequence_no']!, _sequenceNoMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceNoMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    }
    if (data.containsKey('detail_json')) {
      context.handle(
        _detailJsonMeta,
        detailJson.isAcceptableOrUnknown(data['detail_json']!, _detailJsonMeta),
      );
    }
    if (data.containsKey('detail_fetched_at')) {
      context.handle(
        _detailFetchedAtMeta,
        detailFetchedAt.isAcceptableOrUnknown(
          data['detail_fetched_at']!,
          _detailFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('content_language')) {
      context.handle(
        _contentLanguageMeta,
        contentLanguage.isAcceptableOrUnknown(
          data['content_language']!,
          _contentLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedLesson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      lessonKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_kind'],
      )!,
      sequenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_no'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      isPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_published'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      detailJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_json'],
      ),
      detailFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detail_fetched_at'],
      ),
      contentLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_language'],
      )!,
    );
  }

  @override
  $CachedLessonsTable createAlias(String alias) {
    return $CachedLessonsTable(attachedDatabase, alias);
  }
}

class CachedLesson extends DataClass implements Insertable<CachedLesson> {
  final String id;
  final String unitId;
  final String courseId;
  final String lessonKind;
  final int sequenceNo;
  final String title;
  final String description;
  final int estimatedMinutes;
  final int xpReward;
  final bool isPublished;
  final int contentVersion;
  final String? detailJson;
  final DateTime? detailFetchedAt;
  final String contentLanguage;
  const CachedLesson({
    required this.id,
    required this.unitId,
    required this.courseId,
    required this.lessonKind,
    required this.sequenceNo,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.isPublished,
    required this.contentVersion,
    this.detailJson,
    this.detailFetchedAt,
    required this.contentLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['course_id'] = Variable<String>(courseId);
    map['lesson_kind'] = Variable<String>(lessonKind);
    map['sequence_no'] = Variable<int>(sequenceNo);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['xp_reward'] = Variable<int>(xpReward);
    map['is_published'] = Variable<bool>(isPublished);
    map['content_version'] = Variable<int>(contentVersion);
    if (!nullToAbsent || detailJson != null) {
      map['detail_json'] = Variable<String>(detailJson);
    }
    if (!nullToAbsent || detailFetchedAt != null) {
      map['detail_fetched_at'] = Variable<DateTime>(detailFetchedAt);
    }
    map['content_language'] = Variable<String>(contentLanguage);
    return map;
  }

  CachedLessonsCompanion toCompanion(bool nullToAbsent) {
    return CachedLessonsCompanion(
      id: Value(id),
      unitId: Value(unitId),
      courseId: Value(courseId),
      lessonKind: Value(lessonKind),
      sequenceNo: Value(sequenceNo),
      title: Value(title),
      description: Value(description),
      estimatedMinutes: Value(estimatedMinutes),
      xpReward: Value(xpReward),
      isPublished: Value(isPublished),
      contentVersion: Value(contentVersion),
      detailJson: detailJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailJson),
      detailFetchedAt: detailFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(detailFetchedAt),
      contentLanguage: Value(contentLanguage),
    );
  }

  factory CachedLesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedLesson(
      id: serializer.fromJson<String>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      lessonKind: serializer.fromJson<String>(json['lessonKind']),
      sequenceNo: serializer.fromJson<int>(json['sequenceNo']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
      detailJson: serializer.fromJson<String?>(json['detailJson']),
      detailFetchedAt: serializer.fromJson<DateTime?>(json['detailFetchedAt']),
      contentLanguage: serializer.fromJson<String>(json['contentLanguage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unitId': serializer.toJson<String>(unitId),
      'courseId': serializer.toJson<String>(courseId),
      'lessonKind': serializer.toJson<String>(lessonKind),
      'sequenceNo': serializer.toJson<int>(sequenceNo),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'xpReward': serializer.toJson<int>(xpReward),
      'isPublished': serializer.toJson<bool>(isPublished),
      'contentVersion': serializer.toJson<int>(contentVersion),
      'detailJson': serializer.toJson<String?>(detailJson),
      'detailFetchedAt': serializer.toJson<DateTime?>(detailFetchedAt),
      'contentLanguage': serializer.toJson<String>(contentLanguage),
    };
  }

  CachedLesson copyWith({
    String? id,
    String? unitId,
    String? courseId,
    String? lessonKind,
    int? sequenceNo,
    String? title,
    String? description,
    int? estimatedMinutes,
    int? xpReward,
    bool? isPublished,
    int? contentVersion,
    Value<String?> detailJson = const Value.absent(),
    Value<DateTime?> detailFetchedAt = const Value.absent(),
    String? contentLanguage,
  }) => CachedLesson(
    id: id ?? this.id,
    unitId: unitId ?? this.unitId,
    courseId: courseId ?? this.courseId,
    lessonKind: lessonKind ?? this.lessonKind,
    sequenceNo: sequenceNo ?? this.sequenceNo,
    title: title ?? this.title,
    description: description ?? this.description,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    xpReward: xpReward ?? this.xpReward,
    isPublished: isPublished ?? this.isPublished,
    contentVersion: contentVersion ?? this.contentVersion,
    detailJson: detailJson.present ? detailJson.value : this.detailJson,
    detailFetchedAt: detailFetchedAt.present
        ? detailFetchedAt.value
        : this.detailFetchedAt,
    contentLanguage: contentLanguage ?? this.contentLanguage,
  );
  CachedLesson copyWithCompanion(CachedLessonsCompanion data) {
    return CachedLesson(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      lessonKind: data.lessonKind.present
          ? data.lessonKind.value
          : this.lessonKind,
      sequenceNo: data.sequenceNo.present
          ? data.sequenceNo.value
          : this.sequenceNo,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      isPublished: data.isPublished.present
          ? data.isPublished.value
          : this.isPublished,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      detailJson: data.detailJson.present
          ? data.detailJson.value
          : this.detailJson,
      detailFetchedAt: data.detailFetchedAt.present
          ? data.detailFetchedAt.value
          : this.detailFetchedAt,
      contentLanguage: data.contentLanguage.present
          ? data.contentLanguage.value
          : this.contentLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedLesson(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('courseId: $courseId, ')
          ..write('lessonKind: $lessonKind, ')
          ..write('sequenceNo: $sequenceNo, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('xpReward: $xpReward, ')
          ..write('isPublished: $isPublished, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('detailJson: $detailJson, ')
          ..write('detailFetchedAt: $detailFetchedAt, ')
          ..write('contentLanguage: $contentLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unitId,
    courseId,
    lessonKind,
    sequenceNo,
    title,
    description,
    estimatedMinutes,
    xpReward,
    isPublished,
    contentVersion,
    detailJson,
    detailFetchedAt,
    contentLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedLesson &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.courseId == this.courseId &&
          other.lessonKind == this.lessonKind &&
          other.sequenceNo == this.sequenceNo &&
          other.title == this.title &&
          other.description == this.description &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.xpReward == this.xpReward &&
          other.isPublished == this.isPublished &&
          other.contentVersion == this.contentVersion &&
          other.detailJson == this.detailJson &&
          other.detailFetchedAt == this.detailFetchedAt &&
          other.contentLanguage == this.contentLanguage);
}

class CachedLessonsCompanion extends UpdateCompanion<CachedLesson> {
  final Value<String> id;
  final Value<String> unitId;
  final Value<String> courseId;
  final Value<String> lessonKind;
  final Value<int> sequenceNo;
  final Value<String> title;
  final Value<String> description;
  final Value<int> estimatedMinutes;
  final Value<int> xpReward;
  final Value<bool> isPublished;
  final Value<int> contentVersion;
  final Value<String?> detailJson;
  final Value<DateTime?> detailFetchedAt;
  final Value<String> contentLanguage;
  final Value<int> rowid;
  const CachedLessonsCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.lessonKind = const Value.absent(),
    this.sequenceNo = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.detailJson = const Value.absent(),
    this.detailFetchedAt = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedLessonsCompanion.insert({
    required String id,
    required String unitId,
    required String courseId,
    required String lessonKind,
    required int sequenceNo,
    required String title,
    this.description = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.detailJson = const Value.absent(),
    this.detailFetchedAt = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unitId = Value(unitId),
       courseId = Value(courseId),
       lessonKind = Value(lessonKind),
       sequenceNo = Value(sequenceNo),
       title = Value(title);
  static Insertable<CachedLesson> custom({
    Expression<String>? id,
    Expression<String>? unitId,
    Expression<String>? courseId,
    Expression<String>? lessonKind,
    Expression<int>? sequenceNo,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? estimatedMinutes,
    Expression<int>? xpReward,
    Expression<bool>? isPublished,
    Expression<int>? contentVersion,
    Expression<String>? detailJson,
    Expression<DateTime>? detailFetchedAt,
    Expression<String>? contentLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (courseId != null) 'course_id': courseId,
      if (lessonKind != null) 'lesson_kind': lessonKind,
      if (sequenceNo != null) 'sequence_no': sequenceNo,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (xpReward != null) 'xp_reward': xpReward,
      if (isPublished != null) 'is_published': isPublished,
      if (contentVersion != null) 'content_version': contentVersion,
      if (detailJson != null) 'detail_json': detailJson,
      if (detailFetchedAt != null) 'detail_fetched_at': detailFetchedAt,
      if (contentLanguage != null) 'content_language': contentLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedLessonsCompanion copyWith({
    Value<String>? id,
    Value<String>? unitId,
    Value<String>? courseId,
    Value<String>? lessonKind,
    Value<int>? sequenceNo,
    Value<String>? title,
    Value<String>? description,
    Value<int>? estimatedMinutes,
    Value<int>? xpReward,
    Value<bool>? isPublished,
    Value<int>? contentVersion,
    Value<String?>? detailJson,
    Value<DateTime?>? detailFetchedAt,
    Value<String>? contentLanguage,
    Value<int>? rowid,
  }) {
    return CachedLessonsCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      courseId: courseId ?? this.courseId,
      lessonKind: lessonKind ?? this.lessonKind,
      sequenceNo: sequenceNo ?? this.sequenceNo,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      xpReward: xpReward ?? this.xpReward,
      isPublished: isPublished ?? this.isPublished,
      contentVersion: contentVersion ?? this.contentVersion,
      detailJson: detailJson ?? this.detailJson,
      detailFetchedAt: detailFetchedAt ?? this.detailFetchedAt,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (lessonKind.present) {
      map['lesson_kind'] = Variable<String>(lessonKind.value);
    }
    if (sequenceNo.present) {
      map['sequence_no'] = Variable<int>(sequenceNo.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (detailJson.present) {
      map['detail_json'] = Variable<String>(detailJson.value);
    }
    if (detailFetchedAt.present) {
      map['detail_fetched_at'] = Variable<DateTime>(detailFetchedAt.value);
    }
    if (contentLanguage.present) {
      map['content_language'] = Variable<String>(contentLanguage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedLessonsCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('courseId: $courseId, ')
          ..write('lessonKind: $lessonKind, ')
          ..write('sequenceNo: $sequenceNo, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('xpReward: $xpReward, ')
          ..write('isPublished: $isPublished, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('detailJson: $detailJson, ')
          ..write('detailFetchedAt: $detailFetchedAt, ')
          ..write('contentLanguage: $contentLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSyncedGlobalVersionMeta =
      const VerificationMeta('lastSyncedGlobalVersion');
  @override
  late final GeneratedColumn<int> lastSyncedGlobalVersion =
      GeneratedColumn<int>(
        'last_synced_global_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentLanguageMeta = const VerificationMeta(
    'contentLanguage',
  );
  @override
  late final GeneratedColumn<String> contentLanguage = GeneratedColumn<String>(
    'content_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastSyncedGlobalVersion,
    lastSyncedAt,
    contentLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_synced_global_version')) {
      context.handle(
        _lastSyncedGlobalVersionMeta,
        lastSyncedGlobalVersion.isAcceptableOrUnknown(
          data['last_synced_global_version']!,
          _lastSyncedGlobalVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('content_language')) {
      context.handle(
        _contentLanguageMeta,
        contentLanguage.isAcceptableOrUnknown(
          data['content_language']!,
          _contentLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastSyncedGlobalVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_global_version'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      contentLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_language'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int id;
  final int lastSyncedGlobalVersion;
  final DateTime? lastSyncedAt;
  final String contentLanguage;
  const SyncStateData({
    required this.id,
    required this.lastSyncedGlobalVersion,
    this.lastSyncedAt,
    required this.contentLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_synced_global_version'] = Variable<int>(lastSyncedGlobalVersion);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['content_language'] = Variable<String>(contentLanguage);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      lastSyncedGlobalVersion: Value(lastSyncedGlobalVersion),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      contentLanguage: Value(contentLanguage),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<int>(json['id']),
      lastSyncedGlobalVersion: serializer.fromJson<int>(
        json['lastSyncedGlobalVersion'],
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      contentLanguage: serializer.fromJson<String>(json['contentLanguage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSyncedGlobalVersion': serializer.toJson<int>(
        lastSyncedGlobalVersion,
      ),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'contentLanguage': serializer.toJson<String>(contentLanguage),
    };
  }

  SyncStateData copyWith({
    int? id,
    int? lastSyncedGlobalVersion,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? contentLanguage,
  }) => SyncStateData(
    id: id ?? this.id,
    lastSyncedGlobalVersion:
        lastSyncedGlobalVersion ?? this.lastSyncedGlobalVersion,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    contentLanguage: contentLanguage ?? this.contentLanguage,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      lastSyncedGlobalVersion: data.lastSyncedGlobalVersion.present
          ? data.lastSyncedGlobalVersion.value
          : this.lastSyncedGlobalVersion,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      contentLanguage: data.contentLanguage.present
          ? data.contentLanguage.value
          : this.contentLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('lastSyncedGlobalVersion: $lastSyncedGlobalVersion, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('contentLanguage: $contentLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lastSyncedGlobalVersion, lastSyncedAt, contentLanguage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.lastSyncedGlobalVersion == this.lastSyncedGlobalVersion &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.contentLanguage == this.contentLanguage);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> id;
  final Value<int> lastSyncedGlobalVersion;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> contentLanguage;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.lastSyncedGlobalVersion = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.contentLanguage = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.id = const Value.absent(),
    this.lastSyncedGlobalVersion = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.contentLanguage = const Value.absent(),
  });
  static Insertable<SyncStateData> custom({
    Expression<int>? id,
    Expression<int>? lastSyncedGlobalVersion,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? contentLanguage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncedGlobalVersion != null)
        'last_synced_global_version': lastSyncedGlobalVersion,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (contentLanguage != null) 'content_language': contentLanguage,
    });
  }

  SyncStateCompanion copyWith({
    Value<int>? id,
    Value<int>? lastSyncedGlobalVersion,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? contentLanguage,
  }) {
    return SyncStateCompanion(
      id: id ?? this.id,
      lastSyncedGlobalVersion:
          lastSyncedGlobalVersion ?? this.lastSyncedGlobalVersion,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      contentLanguage: contentLanguage ?? this.contentLanguage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSyncedGlobalVersion.present) {
      map['last_synced_global_version'] = Variable<int>(
        lastSyncedGlobalVersion.value,
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (contentLanguage.present) {
      map['content_language'] = Variable<String>(contentLanguage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncedGlobalVersion: $lastSyncedGlobalVersion, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('contentLanguage: $contentLanguage')
          ..write(')'))
        .toString();
  }
}

class $ProgressOutboxEntriesTable extends ProgressOutboxEntries
    with TableInfo<$ProgressOutboxEntriesTable, ProgressOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressOutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('complete_lesson'),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestPayloadJsonMeta =
      const VerificationMeta('requestPayloadJson');
  @override
  late final GeneratedColumn<String> requestPayloadJson =
      GeneratedColumn<String>(
        'request_payload_json',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    operation,
    lessonId,
    idempotencyKey,
    requestPayloadJson,
    createdAt,
    status,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_payload_json')) {
      context.handle(
        _requestPayloadJsonMeta,
        requestPayloadJson.isAcceptableOrUnknown(
          data['request_payload_json']!,
          _requestPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestPayloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ProgressOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressOutboxEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $ProgressOutboxEntriesTable createAlias(String alias) {
    return $ProgressOutboxEntriesTable(attachedDatabase, alias);
  }
}

class ProgressOutboxEntry extends DataClass
    implements Insertable<ProgressOutboxEntry> {
  final int localId;
  final String operation;
  final String lessonId;
  final String idempotencyKey;
  final String requestPayloadJson;
  final DateTime createdAt;
  final String status;
  final int retryCount;
  final String? lastError;
  const ProgressOutboxEntry({
    required this.localId,
    required this.operation,
    required this.lessonId,
    required this.idempotencyKey,
    required this.requestPayloadJson,
    required this.createdAt,
    required this.status,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['operation'] = Variable<String>(operation);
    map['lesson_id'] = Variable<String>(lessonId);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_payload_json'] = Variable<String>(requestPayloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  ProgressOutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProgressOutboxEntriesCompanion(
      localId: Value(localId),
      operation: Value(operation),
      lessonId: Value(lessonId),
      idempotencyKey: Value(idempotencyKey),
      requestPayloadJson: Value(requestPayloadJson),
      createdAt: Value(createdAt),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory ProgressOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressOutboxEntry(
      localId: serializer.fromJson<int>(json['localId']),
      operation: serializer.fromJson<String>(json['operation']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestPayloadJson: serializer.fromJson<String>(
        json['requestPayloadJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'operation': serializer.toJson<String>(operation),
      'lessonId': serializer.toJson<String>(lessonId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestPayloadJson': serializer.toJson<String>(requestPayloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  ProgressOutboxEntry copyWith({
    int? localId,
    String? operation,
    String? lessonId,
    String? idempotencyKey,
    String? requestPayloadJson,
    DateTime? createdAt,
    String? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => ProgressOutboxEntry(
    localId: localId ?? this.localId,
    operation: operation ?? this.operation,
    lessonId: lessonId ?? this.lessonId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestPayloadJson: requestPayloadJson ?? this.requestPayloadJson,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  ProgressOutboxEntry copyWithCompanion(ProgressOutboxEntriesCompanion data) {
    return ProgressOutboxEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      operation: data.operation.present ? data.operation.value : this.operation,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestPayloadJson: data.requestPayloadJson.present
          ? data.requestPayloadJson.value
          : this.requestPayloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressOutboxEntry(')
          ..write('localId: $localId, ')
          ..write('operation: $operation, ')
          ..write('lessonId: $lessonId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayloadJson: $requestPayloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    operation,
    lessonId,
    idempotencyKey,
    requestPayloadJson,
    createdAt,
    status,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressOutboxEntry &&
          other.localId == this.localId &&
          other.operation == this.operation &&
          other.lessonId == this.lessonId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestPayloadJson == this.requestPayloadJson &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class ProgressOutboxEntriesCompanion
    extends UpdateCompanion<ProgressOutboxEntry> {
  final Value<int> localId;
  final Value<String> operation;
  final Value<String> lessonId;
  final Value<String> idempotencyKey;
  final Value<String> requestPayloadJson;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const ProgressOutboxEntriesCompanion({
    this.localId = const Value.absent(),
    this.operation = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestPayloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  ProgressOutboxEntriesCompanion.insert({
    this.localId = const Value.absent(),
    this.operation = const Value.absent(),
    required String lessonId,
    required String idempotencyKey,
    required String requestPayloadJson,
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : lessonId = Value(lessonId),
       idempotencyKey = Value(idempotencyKey),
       requestPayloadJson = Value(requestPayloadJson);
  static Insertable<ProgressOutboxEntry> custom({
    Expression<int>? localId,
    Expression<String>? operation,
    Expression<String>? lessonId,
    Expression<String>? idempotencyKey,
    Expression<String>? requestPayloadJson,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (operation != null) 'operation': operation,
      if (lessonId != null) 'lesson_id': lessonId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestPayloadJson != null)
        'request_payload_json': requestPayloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  ProgressOutboxEntriesCompanion copyWith({
    Value<int>? localId,
    Value<String>? operation,
    Value<String>? lessonId,
    Value<String>? idempotencyKey,
    Value<String>? requestPayloadJson,
    Value<DateTime>? createdAt,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
  }) {
    return ProgressOutboxEntriesCompanion(
      localId: localId ?? this.localId,
      operation: operation ?? this.operation,
      lessonId: lessonId ?? this.lessonId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestPayloadJson: requestPayloadJson ?? this.requestPayloadJson,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestPayloadJson.present) {
      map['request_payload_json'] = Variable<String>(requestPayloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressOutboxEntriesCompanion(')
          ..write('localId: $localId, ')
          ..write('operation: $operation, ')
          ..write('lessonId: $lessonId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayloadJson: $requestPayloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $MediaCacheEntriesTable extends MediaCacheEntries
    with TableInfo<$MediaCacheEntriesTable, MediaCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    localPath,
    sizeBytes,
    lastAccessedAt,
    lessonId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  MediaCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaCacheEntry(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      ),
    );
  }

  @override
  $MediaCacheEntriesTable createAlias(String alias) {
    return $MediaCacheEntriesTable(attachedDatabase, alias);
  }
}

class MediaCacheEntry extends DataClass implements Insertable<MediaCacheEntry> {
  final String url;
  final String localPath;
  final int sizeBytes;
  final DateTime lastAccessedAt;
  final String? lessonId;
  const MediaCacheEntry({
    required this.url,
    required this.localPath,
    required this.sizeBytes,
    required this.lastAccessedAt,
    this.lessonId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<String>(lessonId);
    }
    return map;
  }

  MediaCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return MediaCacheEntriesCompanion(
      url: Value(url),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      lastAccessedAt: Value(lastAccessedAt),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
    );
  }

  factory MediaCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaCacheEntry(
      url: serializer.fromJson<String>(json['url']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
      lessonId: serializer.fromJson<String?>(json['lessonId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
      'lessonId': serializer.toJson<String?>(lessonId),
    };
  }

  MediaCacheEntry copyWith({
    String? url,
    String? localPath,
    int? sizeBytes,
    DateTime? lastAccessedAt,
    Value<String?> lessonId = const Value.absent(),
  }) => MediaCacheEntry(
    url: url ?? this.url,
    localPath: localPath ?? this.localPath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
  );
  MediaCacheEntry copyWithCompanion(MediaCacheEntriesCompanion data) {
    return MediaCacheEntry(
      url: data.url.present ? data.url.value : this.url,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaCacheEntry(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('lessonId: $lessonId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(url, localPath, sizeBytes, lastAccessedAt, lessonId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaCacheEntry &&
          other.url == this.url &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.lessonId == this.lessonId);
}

class MediaCacheEntriesCompanion extends UpdateCompanion<MediaCacheEntry> {
  final Value<String> url;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<DateTime> lastAccessedAt;
  final Value<String?> lessonId;
  final Value<int> rowid;
  const MediaCacheEntriesCompanion({
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCacheEntriesCompanion.insert({
    required String url,
    required String localPath,
    this.sizeBytes = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       localPath = Value(localPath);
  static Insertable<MediaCacheEntry> custom({
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<DateTime>? lastAccessedAt,
    Expression<String>? lessonId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (lessonId != null) 'lesson_id': lessonId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCacheEntriesCompanion copyWith({
    Value<String>? url,
    Value<String>? localPath,
    Value<int>? sizeBytes,
    Value<DateTime>? lastAccessedAt,
    Value<String?>? lessonId,
    Value<int>? rowid,
  }) {
    return MediaCacheEntriesCompanion(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      lessonId: lessonId ?? this.lessonId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCacheEntriesCompanion(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('lessonId: $lessonId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitDownloadsTable extends UnitDownloads
    with TableInfo<$UnitDownloadsTable, UnitDownload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitDownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [unitId, downloadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitDownload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {unitId};
  @override
  UnitDownload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitDownload(
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $UnitDownloadsTable createAlias(String alias) {
    return $UnitDownloadsTable(attachedDatabase, alias);
  }
}

class UnitDownload extends DataClass implements Insertable<UnitDownload> {
  final String unitId;
  final DateTime downloadedAt;
  const UnitDownload({required this.unitId, required this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['unit_id'] = Variable<String>(unitId);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  UnitDownloadsCompanion toCompanion(bool nullToAbsent) {
    return UnitDownloadsCompanion(
      unitId: Value(unitId),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory UnitDownload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitDownload(
      unitId: serializer.fromJson<String>(json['unitId']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'unitId': serializer.toJson<String>(unitId),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  UnitDownload copyWith({String? unitId, DateTime? downloadedAt}) =>
      UnitDownload(
        unitId: unitId ?? this.unitId,
        downloadedAt: downloadedAt ?? this.downloadedAt,
      );
  UnitDownload copyWithCompanion(UnitDownloadsCompanion data) {
    return UnitDownload(
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitDownload(')
          ..write('unitId: $unitId, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(unitId, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitDownload &&
          other.unitId == this.unitId &&
          other.downloadedAt == this.downloadedAt);
}

class UnitDownloadsCompanion extends UpdateCompanion<UnitDownload> {
  final Value<String> unitId;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const UnitDownloadsCompanion({
    this.unitId = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitDownloadsCompanion.insert({
    required String unitId,
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : unitId = Value(unitId);
  static Insertable<UnitDownload> custom({
    Expression<String>? unitId,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (unitId != null) 'unit_id': unitId,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitDownloadsCompanion copyWith({
    Value<String>? unitId,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return UnitDownloadsCompanion(
      unitId: unitId ?? this.unitId,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitDownloadsCompanion(')
          ..write('unitId: $unitId, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentTombstonesTable extends ContentTombstones
    with TableInfo<$ContentTombstonesTable, ContentTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entityId, entityType, contentVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, entityType};
  @override
  ContentTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentTombstone(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
    );
  }

  @override
  $ContentTombstonesTable createAlias(String alias) {
    return $ContentTombstonesTable(attachedDatabase, alias);
  }
}

class ContentTombstone extends DataClass
    implements Insertable<ContentTombstone> {
  final String entityId;
  final String entityType;
  final int contentVersion;
  const ContentTombstone({
    required this.entityId,
    required this.entityType,
    required this.contentVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['content_version'] = Variable<int>(contentVersion);
    return map;
  }

  ContentTombstonesCompanion toCompanion(bool nullToAbsent) {
    return ContentTombstonesCompanion(
      entityId: Value(entityId),
      entityType: Value(entityType),
      contentVersion: Value(contentVersion),
    );
  }

  factory ContentTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentTombstone(
      entityId: serializer.fromJson<String>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'contentVersion': serializer.toJson<int>(contentVersion),
    };
  }

  ContentTombstone copyWith({
    String? entityId,
    String? entityType,
    int? contentVersion,
  }) => ContentTombstone(
    entityId: entityId ?? this.entityId,
    entityType: entityType ?? this.entityType,
    contentVersion: contentVersion ?? this.contentVersion,
  );
  ContentTombstone copyWithCompanion(ContentTombstonesCompanion data) {
    return ContentTombstone(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentTombstone(')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('contentVersion: $contentVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityId, entityType, contentVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentTombstone &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.contentVersion == this.contentVersion);
}

class ContentTombstonesCompanion extends UpdateCompanion<ContentTombstone> {
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<int> contentVersion;
  final Value<int> rowid;
  const ContentTombstonesCompanion({
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentTombstonesCompanion.insert({
    required String entityId,
    required String entityType,
    required int contentVersion,
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       entityType = Value(entityType),
       contentVersion = Value(contentVersion);
  static Insertable<ContentTombstone> custom({
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<int>? contentVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (contentVersion != null) 'content_version': contentVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentTombstonesCompanion copyWith({
    Value<String>? entityId,
    Value<String>? entityType,
    Value<int>? contentVersion,
    Value<int>? rowid,
  }) {
    return ContentTombstonesCompanion(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      contentVersion: contentVersion ?? this.contentVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentTombstonesCompanion(')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiCacheEntriesTable extends ApiCacheEntries
    with TableInfo<$ApiCacheEntriesTable, ApiCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonValueMeta = const VerificationMeta(
    'jsonValue',
  );
  @override
  late final GeneratedColumn<String> jsonValue = GeneratedColumn<String>(
    'json_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    jsonValue,
    cachedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('json_value')) {
      context.handle(
        _jsonValueMeta,
        jsonValue.isAcceptableOrUnknown(data['json_value']!, _jsonValueMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonValueMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  ApiCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiCacheEntry(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      jsonValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_value'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $ApiCacheEntriesTable createAlias(String alias) {
    return $ApiCacheEntriesTable(attachedDatabase, alias);
  }
}

class ApiCacheEntry extends DataClass implements Insertable<ApiCacheEntry> {
  final String cacheKey;
  final String jsonValue;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  const ApiCacheEntry({
    required this.cacheKey,
    required this.jsonValue,
    required this.cachedAt,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['json_value'] = Variable<String>(jsonValue);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  ApiCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ApiCacheEntriesCompanion(
      cacheKey: Value(cacheKey),
      jsonValue: Value(jsonValue),
      cachedAt: Value(cachedAt),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory ApiCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiCacheEntry(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      jsonValue: serializer.fromJson<String>(json['jsonValue']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'jsonValue': serializer.toJson<String>(jsonValue),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  ApiCacheEntry copyWith({
    String? cacheKey,
    String? jsonValue,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
  }) => ApiCacheEntry(
    cacheKey: cacheKey ?? this.cacheKey,
    jsonValue: jsonValue ?? this.jsonValue,
    cachedAt: cachedAt ?? this.cachedAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  ApiCacheEntry copyWithCompanion(ApiCacheEntriesCompanion data) {
    return ApiCacheEntry(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      jsonValue: data.jsonValue.present ? data.jsonValue.value : this.jsonValue,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheEntry(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cacheKey, jsonValue, cachedAt, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiCacheEntry &&
          other.cacheKey == this.cacheKey &&
          other.jsonValue == this.jsonValue &&
          other.cachedAt == this.cachedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class ApiCacheEntriesCompanion extends UpdateCompanion<ApiCacheEntry> {
  final Value<String> cacheKey;
  final Value<String> jsonValue;
  final Value<DateTime> cachedAt;
  final Value<DateTime> lastAccessedAt;
  final Value<int> rowid;
  const ApiCacheEntriesCompanion({
    this.cacheKey = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiCacheEntriesCompanion.insert({
    required String cacheKey,
    required String jsonValue,
    required DateTime cachedAt,
    required DateTime lastAccessedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       jsonValue = Value(jsonValue),
       cachedAt = Value(cachedAt),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<ApiCacheEntry> custom({
    Expression<String>? cacheKey,
    Expression<String>? jsonValue,
    Expression<DateTime>? cachedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (jsonValue != null) 'json_value': jsonValue,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiCacheEntriesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? jsonValue,
    Value<DateTime>? cachedAt,
    Value<DateTime>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return ApiCacheEntriesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      jsonValue: jsonValue ?? this.jsonValue,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (jsonValue.present) {
      map['json_value'] = Variable<String>(jsonValue.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheEntriesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedCoursesTable cachedCourses = $CachedCoursesTable(this);
  late final $CachedUnitsTable cachedUnits = $CachedUnitsTable(this);
  late final $CachedLessonsTable cachedLessons = $CachedLessonsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ProgressOutboxEntriesTable progressOutboxEntries =
      $ProgressOutboxEntriesTable(this);
  late final $MediaCacheEntriesTable mediaCacheEntries =
      $MediaCacheEntriesTable(this);
  late final $UnitDownloadsTable unitDownloads = $UnitDownloadsTable(this);
  late final $ContentTombstonesTable contentTombstones =
      $ContentTombstonesTable(this);
  late final $ApiCacheEntriesTable apiCacheEntries = $ApiCacheEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedCourses,
    cachedUnits,
    cachedLessons,
    syncState,
    progressOutboxEntries,
    mediaCacheEntries,
    unitDownloads,
    contentTombstones,
    apiCacheEntries,
  ];
}

typedef $$CachedCoursesTableCreateCompanionBuilder =
    CachedCoursesCompanion Function({
      required String id,
      required String code,
      Value<String> title,
      Value<String> description,
      required String levelMin,
      required String levelMax,
      Value<int> contentVersion,
      Value<bool> isPublished,
      Value<String> contentLanguage,
      Value<int> rowid,
    });
typedef $$CachedCoursesTableUpdateCompanionBuilder =
    CachedCoursesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> title,
      Value<String> description,
      Value<String> levelMin,
      Value<String> levelMax,
      Value<int> contentVersion,
      Value<bool> isPublished,
      Value<String> contentLanguage,
      Value<int> rowid,
    });

class $$CachedCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCoursesTable> {
  $$CachedCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelMin => $composableBuilder(
    column: $table.levelMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelMax => $composableBuilder(
    column: $table.levelMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCoursesTable> {
  $$CachedCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelMin => $composableBuilder(
    column: $table.levelMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelMax => $composableBuilder(
    column: $table.levelMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCoursesTable> {
  $$CachedCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get levelMin =>
      $composableBuilder(column: $table.levelMin, builder: (column) => column);

  GeneratedColumn<String> get levelMax =>
      $composableBuilder(column: $table.levelMax, builder: (column) => column);

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => column,
  );
}

class $$CachedCoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCoursesTable,
          CachedCourse,
          $$CachedCoursesTableFilterComposer,
          $$CachedCoursesTableOrderingComposer,
          $$CachedCoursesTableAnnotationComposer,
          $$CachedCoursesTableCreateCompanionBuilder,
          $$CachedCoursesTableUpdateCompanionBuilder,
          (
            CachedCourse,
            BaseReferences<_$AppDatabase, $CachedCoursesTable, CachedCourse>,
          ),
          CachedCourse,
          PrefetchHooks Function()
        > {
  $$CachedCoursesTableTableManager(_$AppDatabase db, $CachedCoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> levelMin = const Value.absent(),
                Value<String> levelMax = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCoursesCompanion(
                id: id,
                code: code,
                title: title,
                description: description,
                levelMin: levelMin,
                levelMax: levelMax,
                contentVersion: contentVersion,
                isPublished: isPublished,
                contentLanguage: contentLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                required String levelMin,
                required String levelMax,
                Value<int> contentVersion = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCoursesCompanion.insert(
                id: id,
                code: code,
                title: title,
                description: description,
                levelMin: levelMin,
                levelMax: levelMax,
                contentVersion: contentVersion,
                isPublished: isPublished,
                contentLanguage: contentLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedCoursesTable,
      CachedCourse,
      $$CachedCoursesTableFilterComposer,
      $$CachedCoursesTableOrderingComposer,
      $$CachedCoursesTableAnnotationComposer,
      $$CachedCoursesTableCreateCompanionBuilder,
      $$CachedCoursesTableUpdateCompanionBuilder,
      (
        CachedCourse,
        BaseReferences<_$AppDatabase, $CachedCoursesTable, CachedCourse>,
      ),
      CachedCourse,
      PrefetchHooks Function()
    >;
typedef $$CachedUnitsTableCreateCompanionBuilder =
    CachedUnitsCompanion Function({
      required String id,
      required String courseId,
      required String unitKind,
      required int unitNo,
      required String title,
      Value<String> description,
      Value<int> contentVersion,
      Value<String> contentLanguage,
      Value<int> rowid,
    });
typedef $$CachedUnitsTableUpdateCompanionBuilder =
    CachedUnitsCompanion Function({
      Value<String> id,
      Value<String> courseId,
      Value<String> unitKind,
      Value<int> unitNo,
      Value<String> title,
      Value<String> description,
      Value<int> contentVersion,
      Value<String> contentLanguage,
      Value<int> rowid,
    });

class $$CachedUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitKind => $composableBuilder(
    column: $table.unitKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitNo => $composableBuilder(
    column: $table.unitNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitKind => $composableBuilder(
    column: $table.unitKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitNo => $composableBuilder(
    column: $table.unitNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get unitKind =>
      $composableBuilder(column: $table.unitKind, builder: (column) => column);

  GeneratedColumn<int> get unitNo =>
      $composableBuilder(column: $table.unitNo, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => column,
  );
}

class $$CachedUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedUnitsTable,
          CachedUnit,
          $$CachedUnitsTableFilterComposer,
          $$CachedUnitsTableOrderingComposer,
          $$CachedUnitsTableAnnotationComposer,
          $$CachedUnitsTableCreateCompanionBuilder,
          $$CachedUnitsTableUpdateCompanionBuilder,
          (
            CachedUnit,
            BaseReferences<_$AppDatabase, $CachedUnitsTable, CachedUnit>,
          ),
          CachedUnit,
          PrefetchHooks Function()
        > {
  $$CachedUnitsTableTableManager(_$AppDatabase db, $CachedUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> unitKind = const Value.absent(),
                Value<int> unitNo = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUnitsCompanion(
                id: id,
                courseId: courseId,
                unitKind: unitKind,
                unitNo: unitNo,
                title: title,
                description: description,
                contentVersion: contentVersion,
                contentLanguage: contentLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseId,
                required String unitKind,
                required int unitNo,
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUnitsCompanion.insert(
                id: id,
                courseId: courseId,
                unitKind: unitKind,
                unitNo: unitNo,
                title: title,
                description: description,
                contentVersion: contentVersion,
                contentLanguage: contentLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedUnitsTable,
      CachedUnit,
      $$CachedUnitsTableFilterComposer,
      $$CachedUnitsTableOrderingComposer,
      $$CachedUnitsTableAnnotationComposer,
      $$CachedUnitsTableCreateCompanionBuilder,
      $$CachedUnitsTableUpdateCompanionBuilder,
      (
        CachedUnit,
        BaseReferences<_$AppDatabase, $CachedUnitsTable, CachedUnit>,
      ),
      CachedUnit,
      PrefetchHooks Function()
    >;
typedef $$CachedLessonsTableCreateCompanionBuilder =
    CachedLessonsCompanion Function({
      required String id,
      required String unitId,
      required String courseId,
      required String lessonKind,
      required int sequenceNo,
      required String title,
      Value<String> description,
      Value<int> estimatedMinutes,
      Value<int> xpReward,
      Value<bool> isPublished,
      Value<int> contentVersion,
      Value<String?> detailJson,
      Value<DateTime?> detailFetchedAt,
      Value<String> contentLanguage,
      Value<int> rowid,
    });
typedef $$CachedLessonsTableUpdateCompanionBuilder =
    CachedLessonsCompanion Function({
      Value<String> id,
      Value<String> unitId,
      Value<String> courseId,
      Value<String> lessonKind,
      Value<int> sequenceNo,
      Value<String> title,
      Value<String> description,
      Value<int> estimatedMinutes,
      Value<int> xpReward,
      Value<bool> isPublished,
      Value<int> contentVersion,
      Value<String?> detailJson,
      Value<DateTime?> detailFetchedAt,
      Value<String> contentLanguage,
      Value<int> rowid,
    });

class $$CachedLessonsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedLessonsTable> {
  $$CachedLessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonKind => $composableBuilder(
    column: $table.lessonKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detailFetchedAt => $composableBuilder(
    column: $table.detailFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedLessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedLessonsTable> {
  $$CachedLessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonKind => $composableBuilder(
    column: $table.lessonKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detailFetchedAt => $composableBuilder(
    column: $table.detailFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedLessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedLessonsTable> {
  $$CachedLessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get lessonKind => $composableBuilder(
    column: $table.lessonKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNo => $composableBuilder(
    column: $table.sequenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detailFetchedAt => $composableBuilder(
    column: $table.detailFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => column,
  );
}

class $$CachedLessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedLessonsTable,
          CachedLesson,
          $$CachedLessonsTableFilterComposer,
          $$CachedLessonsTableOrderingComposer,
          $$CachedLessonsTableAnnotationComposer,
          $$CachedLessonsTableCreateCompanionBuilder,
          $$CachedLessonsTableUpdateCompanionBuilder,
          (
            CachedLesson,
            BaseReferences<_$AppDatabase, $CachedLessonsTable, CachedLesson>,
          ),
          CachedLesson,
          PrefetchHooks Function()
        > {
  $$CachedLessonsTableTableManager(_$AppDatabase db, $CachedLessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedLessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedLessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedLessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> unitId = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> lessonKind = const Value.absent(),
                Value<int> sequenceNo = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String?> detailJson = const Value.absent(),
                Value<DateTime?> detailFetchedAt = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLessonsCompanion(
                id: id,
                unitId: unitId,
                courseId: courseId,
                lessonKind: lessonKind,
                sequenceNo: sequenceNo,
                title: title,
                description: description,
                estimatedMinutes: estimatedMinutes,
                xpReward: xpReward,
                isPublished: isPublished,
                contentVersion: contentVersion,
                detailJson: detailJson,
                detailFetchedAt: detailFetchedAt,
                contentLanguage: contentLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String unitId,
                required String courseId,
                required String lessonKind,
                required int sequenceNo,
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String?> detailJson = const Value.absent(),
                Value<DateTime?> detailFetchedAt = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLessonsCompanion.insert(
                id: id,
                unitId: unitId,
                courseId: courseId,
                lessonKind: lessonKind,
                sequenceNo: sequenceNo,
                title: title,
                description: description,
                estimatedMinutes: estimatedMinutes,
                xpReward: xpReward,
                isPublished: isPublished,
                contentVersion: contentVersion,
                detailJson: detailJson,
                detailFetchedAt: detailFetchedAt,
                contentLanguage: contentLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedLessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedLessonsTable,
      CachedLesson,
      $$CachedLessonsTableFilterComposer,
      $$CachedLessonsTableOrderingComposer,
      $$CachedLessonsTableAnnotationComposer,
      $$CachedLessonsTableCreateCompanionBuilder,
      $$CachedLessonsTableUpdateCompanionBuilder,
      (
        CachedLesson,
        BaseReferences<_$AppDatabase, $CachedLessonsTable, CachedLesson>,
      ),
      CachedLesson,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<int> lastSyncedGlobalVersion,
      Value<DateTime?> lastSyncedAt,
      Value<String> contentLanguage,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<int> lastSyncedGlobalVersion,
      Value<DateTime?> lastSyncedAt,
      Value<String> contentLanguage,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedGlobalVersion => $composableBuilder(
    column: $table.lastSyncedGlobalVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedGlobalVersion => $composableBuilder(
    column: $table.lastSyncedGlobalVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedGlobalVersion => $composableBuilder(
    column: $table.lastSyncedGlobalVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lastSyncedGlobalVersion = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
              }) => SyncStateCompanion(
                id: id,
                lastSyncedGlobalVersion: lastSyncedGlobalVersion,
                lastSyncedAt: lastSyncedAt,
                contentLanguage: contentLanguage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lastSyncedGlobalVersion = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
              }) => SyncStateCompanion.insert(
                id: id,
                lastSyncedGlobalVersion: lastSyncedGlobalVersion,
                lastSyncedAt: lastSyncedAt,
                contentLanguage: contentLanguage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ProgressOutboxEntriesTableCreateCompanionBuilder =
    ProgressOutboxEntriesCompanion Function({
      Value<int> localId,
      Value<String> operation,
      required String lessonId,
      required String idempotencyKey,
      required String requestPayloadJson,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
    });
typedef $$ProgressOutboxEntriesTableUpdateCompanionBuilder =
    ProgressOutboxEntriesCompanion Function({
      Value<int> localId,
      Value<String> operation,
      Value<String> lessonId,
      Value<String> idempotencyKey,
      Value<String> requestPayloadJson,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
    });

class $$ProgressOutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressOutboxEntriesTable> {
  $$ProgressOutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestPayloadJson => $composableBuilder(
    column: $table.requestPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressOutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressOutboxEntriesTable> {
  $$ProgressOutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestPayloadJson => $composableBuilder(
    column: $table.requestPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressOutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressOutboxEntriesTable> {
  $$ProgressOutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestPayloadJson => $composableBuilder(
    column: $table.requestPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$ProgressOutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressOutboxEntriesTable,
          ProgressOutboxEntry,
          $$ProgressOutboxEntriesTableFilterComposer,
          $$ProgressOutboxEntriesTableOrderingComposer,
          $$ProgressOutboxEntriesTableAnnotationComposer,
          $$ProgressOutboxEntriesTableCreateCompanionBuilder,
          $$ProgressOutboxEntriesTableUpdateCompanionBuilder,
          (
            ProgressOutboxEntry,
            BaseReferences<
              _$AppDatabase,
              $ProgressOutboxEntriesTable,
              ProgressOutboxEntry
            >,
          ),
          ProgressOutboxEntry,
          PrefetchHooks Function()
        > {
  $$ProgressOutboxEntriesTableTableManager(
    _$AppDatabase db,
    $ProgressOutboxEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressOutboxEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProgressOutboxEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProgressOutboxEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestPayloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => ProgressOutboxEntriesCompanion(
                localId: localId,
                operation: operation,
                lessonId: lessonId,
                idempotencyKey: idempotencyKey,
                requestPayloadJson: requestPayloadJson,
                createdAt: createdAt,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                required String lessonId,
                required String idempotencyKey,
                required String requestPayloadJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => ProgressOutboxEntriesCompanion.insert(
                localId: localId,
                operation: operation,
                lessonId: lessonId,
                idempotencyKey: idempotencyKey,
                requestPayloadJson: requestPayloadJson,
                createdAt: createdAt,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressOutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressOutboxEntriesTable,
      ProgressOutboxEntry,
      $$ProgressOutboxEntriesTableFilterComposer,
      $$ProgressOutboxEntriesTableOrderingComposer,
      $$ProgressOutboxEntriesTableAnnotationComposer,
      $$ProgressOutboxEntriesTableCreateCompanionBuilder,
      $$ProgressOutboxEntriesTableUpdateCompanionBuilder,
      (
        ProgressOutboxEntry,
        BaseReferences<
          _$AppDatabase,
          $ProgressOutboxEntriesTable,
          ProgressOutboxEntry
        >,
      ),
      ProgressOutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$MediaCacheEntriesTableCreateCompanionBuilder =
    MediaCacheEntriesCompanion Function({
      required String url,
      required String localPath,
      Value<int> sizeBytes,
      Value<DateTime> lastAccessedAt,
      Value<String?> lessonId,
      Value<int> rowid,
    });
typedef $$MediaCacheEntriesTableUpdateCompanionBuilder =
    MediaCacheEntriesCompanion Function({
      Value<String> url,
      Value<String> localPath,
      Value<int> sizeBytes,
      Value<DateTime> lastAccessedAt,
      Value<String?> lessonId,
      Value<int> rowid,
    });

class $$MediaCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaCacheEntriesTable> {
  $$MediaCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaCacheEntriesTable> {
  $$MediaCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaCacheEntriesTable> {
  $$MediaCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);
}

class $$MediaCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaCacheEntriesTable,
          MediaCacheEntry,
          $$MediaCacheEntriesTableFilterComposer,
          $$MediaCacheEntriesTableOrderingComposer,
          $$MediaCacheEntriesTableAnnotationComposer,
          $$MediaCacheEntriesTableCreateCompanionBuilder,
          $$MediaCacheEntriesTableUpdateCompanionBuilder,
          (
            MediaCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $MediaCacheEntriesTable,
              MediaCacheEntry
            >,
          ),
          MediaCacheEntry,
          PrefetchHooks Function()
        > {
  $$MediaCacheEntriesTableTableManager(
    _$AppDatabase db,
    $MediaCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<String?> lessonId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCacheEntriesCompanion(
                url: url,
                localPath: localPath,
                sizeBytes: sizeBytes,
                lastAccessedAt: lastAccessedAt,
                lessonId: lessonId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required String localPath,
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<String?> lessonId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCacheEntriesCompanion.insert(
                url: url,
                localPath: localPath,
                sizeBytes: sizeBytes,
                lastAccessedAt: lastAccessedAt,
                lessonId: lessonId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaCacheEntriesTable,
      MediaCacheEntry,
      $$MediaCacheEntriesTableFilterComposer,
      $$MediaCacheEntriesTableOrderingComposer,
      $$MediaCacheEntriesTableAnnotationComposer,
      $$MediaCacheEntriesTableCreateCompanionBuilder,
      $$MediaCacheEntriesTableUpdateCompanionBuilder,
      (
        MediaCacheEntry,
        BaseReferences<_$AppDatabase, $MediaCacheEntriesTable, MediaCacheEntry>,
      ),
      MediaCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$UnitDownloadsTableCreateCompanionBuilder =
    UnitDownloadsCompanion Function({
      required String unitId,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });
typedef $$UnitDownloadsTableUpdateCompanionBuilder =
    UnitDownloadsCompanion Function({
      Value<String> unitId,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$UnitDownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $UnitDownloadsTable> {
  $$UnitDownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitDownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitDownloadsTable> {
  $$UnitDownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitDownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitDownloadsTable> {
  $$UnitDownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$UnitDownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitDownloadsTable,
          UnitDownload,
          $$UnitDownloadsTableFilterComposer,
          $$UnitDownloadsTableOrderingComposer,
          $$UnitDownloadsTableAnnotationComposer,
          $$UnitDownloadsTableCreateCompanionBuilder,
          $$UnitDownloadsTableUpdateCompanionBuilder,
          (
            UnitDownload,
            BaseReferences<_$AppDatabase, $UnitDownloadsTable, UnitDownload>,
          ),
          UnitDownload,
          PrefetchHooks Function()
        > {
  $$UnitDownloadsTableTableManager(_$AppDatabase db, $UnitDownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitDownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitDownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitDownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> unitId = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitDownloadsCompanion(
                unitId: unitId,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String unitId,
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitDownloadsCompanion.insert(
                unitId: unitId,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitDownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitDownloadsTable,
      UnitDownload,
      $$UnitDownloadsTableFilterComposer,
      $$UnitDownloadsTableOrderingComposer,
      $$UnitDownloadsTableAnnotationComposer,
      $$UnitDownloadsTableCreateCompanionBuilder,
      $$UnitDownloadsTableUpdateCompanionBuilder,
      (
        UnitDownload,
        BaseReferences<_$AppDatabase, $UnitDownloadsTable, UnitDownload>,
      ),
      UnitDownload,
      PrefetchHooks Function()
    >;
typedef $$ContentTombstonesTableCreateCompanionBuilder =
    ContentTombstonesCompanion Function({
      required String entityId,
      required String entityType,
      required int contentVersion,
      Value<int> rowid,
    });
typedef $$ContentTombstonesTableUpdateCompanionBuilder =
    ContentTombstonesCompanion Function({
      Value<String> entityId,
      Value<String> entityType,
      Value<int> contentVersion,
      Value<int> rowid,
    });

class $$ContentTombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $ContentTombstonesTable> {
  $$ContentTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentTombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentTombstonesTable> {
  $$ContentTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentTombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentTombstonesTable> {
  $$ContentTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );
}

class $$ContentTombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentTombstonesTable,
          ContentTombstone,
          $$ContentTombstonesTableFilterComposer,
          $$ContentTombstonesTableOrderingComposer,
          $$ContentTombstonesTableAnnotationComposer,
          $$ContentTombstonesTableCreateCompanionBuilder,
          $$ContentTombstonesTableUpdateCompanionBuilder,
          (
            ContentTombstone,
            BaseReferences<
              _$AppDatabase,
              $ContentTombstonesTable,
              ContentTombstone
            >,
          ),
          ContentTombstone,
          PrefetchHooks Function()
        > {
  $$ContentTombstonesTableTableManager(
    _$AppDatabase db,
    $ContentTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentTombstonesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentTombstonesCompanion(
                entityId: entityId,
                entityType: entityType,
                contentVersion: contentVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String entityType,
                required int contentVersion,
                Value<int> rowid = const Value.absent(),
              }) => ContentTombstonesCompanion.insert(
                entityId: entityId,
                entityType: entityType,
                contentVersion: contentVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentTombstonesTable,
      ContentTombstone,
      $$ContentTombstonesTableFilterComposer,
      $$ContentTombstonesTableOrderingComposer,
      $$ContentTombstonesTableAnnotationComposer,
      $$ContentTombstonesTableCreateCompanionBuilder,
      $$ContentTombstonesTableUpdateCompanionBuilder,
      (
        ContentTombstone,
        BaseReferences<
          _$AppDatabase,
          $ContentTombstonesTable,
          ContentTombstone
        >,
      ),
      ContentTombstone,
      PrefetchHooks Function()
    >;
typedef $$ApiCacheEntriesTableCreateCompanionBuilder =
    ApiCacheEntriesCompanion Function({
      required String cacheKey,
      required String jsonValue,
      required DateTime cachedAt,
      required DateTime lastAccessedAt,
      Value<int> rowid,
    });
typedef $$ApiCacheEntriesTableUpdateCompanionBuilder =
    ApiCacheEntriesCompanion Function({
      Value<String> cacheKey,
      Value<String> jsonValue,
      Value<DateTime> cachedAt,
      Value<DateTime> lastAccessedAt,
      Value<int> rowid,
    });

class $$ApiCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ApiCacheEntriesTable> {
  $$ApiCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiCacheEntriesTable> {
  $$ApiCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiCacheEntriesTable> {
  $$ApiCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get jsonValue =>
      $composableBuilder(column: $table.jsonValue, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$ApiCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiCacheEntriesTable,
          ApiCacheEntry,
          $$ApiCacheEntriesTableFilterComposer,
          $$ApiCacheEntriesTableOrderingComposer,
          $$ApiCacheEntriesTableAnnotationComposer,
          $$ApiCacheEntriesTableCreateCompanionBuilder,
          $$ApiCacheEntriesTableUpdateCompanionBuilder,
          (
            ApiCacheEntry,
            BaseReferences<_$AppDatabase, $ApiCacheEntriesTable, ApiCacheEntry>,
          ),
          ApiCacheEntry,
          PrefetchHooks Function()
        > {
  $$ApiCacheEntriesTableTableManager(
    _$AppDatabase db,
    $ApiCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> jsonValue = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheEntriesCompanion(
                cacheKey: cacheKey,
                jsonValue: jsonValue,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String jsonValue,
                required DateTime cachedAt,
                required DateTime lastAccessedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheEntriesCompanion.insert(
                cacheKey: cacheKey,
                jsonValue: jsonValue,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiCacheEntriesTable,
      ApiCacheEntry,
      $$ApiCacheEntriesTableFilterComposer,
      $$ApiCacheEntriesTableOrderingComposer,
      $$ApiCacheEntriesTableAnnotationComposer,
      $$ApiCacheEntriesTableCreateCompanionBuilder,
      $$ApiCacheEntriesTableUpdateCompanionBuilder,
      (
        ApiCacheEntry,
        BaseReferences<_$AppDatabase, $ApiCacheEntriesTable, ApiCacheEntry>,
      ),
      ApiCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedCoursesTableTableManager get cachedCourses =>
      $$CachedCoursesTableTableManager(_db, _db.cachedCourses);
  $$CachedUnitsTableTableManager get cachedUnits =>
      $$CachedUnitsTableTableManager(_db, _db.cachedUnits);
  $$CachedLessonsTableTableManager get cachedLessons =>
      $$CachedLessonsTableTableManager(_db, _db.cachedLessons);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ProgressOutboxEntriesTableTableManager get progressOutboxEntries =>
      $$ProgressOutboxEntriesTableTableManager(_db, _db.progressOutboxEntries);
  $$MediaCacheEntriesTableTableManager get mediaCacheEntries =>
      $$MediaCacheEntriesTableTableManager(_db, _db.mediaCacheEntries);
  $$UnitDownloadsTableTableManager get unitDownloads =>
      $$UnitDownloadsTableTableManager(_db, _db.unitDownloads);
  $$ContentTombstonesTableTableManager get contentTombstones =>
      $$ContentTombstonesTableTableManager(_db, _db.contentTombstones);
  $$ApiCacheEntriesTableTableManager get apiCacheEntries =>
      $$ApiCacheEntriesTableTableManager(_db, _db.apiCacheEntries);
}
