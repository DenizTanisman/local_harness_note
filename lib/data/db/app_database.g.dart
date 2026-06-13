// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MetricsTable extends Metrics with TableInfo<$MetricsTable, Metric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES metrics (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _inputTypeMeta = const VerificationMeta(
    'inputType',
  );
  @override
  late final GeneratedColumn<String> inputType = GeneratedColumn<String>(
    'input_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prevInputTypeMeta = const VerificationMeta(
    'prevInputType',
  );
  @override
  late final GeneratedColumn<String> prevInputType = GeneratedColumn<String>(
    'prev_input_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _starredAtMeta = const VerificationMeta(
    'starredAt',
  );
  @override
  late final GeneratedColumn<int> starredAt = GeneratedColumn<int>(
    'starred_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heatmapLabelMeta = const VerificationMeta(
    'heatmapLabel',
  );
  @override
  late final GeneratedColumn<String> heatmapLabel = GeneratedColumn<String>(
    'heatmap_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heatmapRuleMeta = const VerificationMeta(
    'heatmapRule',
  );
  @override
  late final GeneratedColumn<String> heatmapRule = GeneratedColumn<String>(
    'heatmap_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletableMeta = const VerificationMeta(
    'isDeletable',
  );
  @override
  late final GeneratedColumn<bool> isDeletable = GeneratedColumn<bool>(
    'is_deletable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deletable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _groupDisplayMeta = const VerificationMeta(
    'groupDisplay',
  );
  @override
  late final GeneratedColumn<String> groupDisplay = GeneratedColumn<String>(
    'group_display',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sub_names'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    key,
    title,
    inputType,
    prevInputType,
    isStarred,
    starredAt,
    heatmapLabel,
    heatmapRule,
    sortOrder,
    unit,
    isDeletable,
    groupDisplay,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Metric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('input_type')) {
      context.handle(
        _inputTypeMeta,
        inputType.isAcceptableOrUnknown(data['input_type']!, _inputTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_inputTypeMeta);
    }
    if (data.containsKey('prev_input_type')) {
      context.handle(
        _prevInputTypeMeta,
        prevInputType.isAcceptableOrUnknown(
          data['prev_input_type']!,
          _prevInputTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('starred_at')) {
      context.handle(
        _starredAtMeta,
        starredAt.isAcceptableOrUnknown(data['starred_at']!, _starredAtMeta),
      );
    }
    if (data.containsKey('heatmap_label')) {
      context.handle(
        _heatmapLabelMeta,
        heatmapLabel.isAcceptableOrUnknown(
          data['heatmap_label']!,
          _heatmapLabelMeta,
        ),
      );
    }
    if (data.containsKey('heatmap_rule')) {
      context.handle(
        _heatmapRuleMeta,
        heatmapRule.isAcceptableOrUnknown(
          data['heatmap_rule']!,
          _heatmapRuleMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('is_deletable')) {
      context.handle(
        _isDeletableMeta,
        isDeletable.isAcceptableOrUnknown(
          data['is_deletable']!,
          _isDeletableMeta,
        ),
      );
    }
    if (data.containsKey('group_display')) {
      context.handle(
        _groupDisplayMeta,
        groupDisplay.isAcceptableOrUnknown(
          data['group_display']!,
          _groupDisplayMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Metric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Metric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      inputType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_type'],
      )!,
      prevInputType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_input_type'],
      ),
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      starredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starred_at'],
      ),
      heatmapLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heatmap_label'],
      ),
      heatmapRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heatmap_rule'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      isDeletable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deletable'],
      )!,
      groupDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_display'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MetricsTable createAlias(String alias) {
    return $MetricsTable(attachedDatabase, alias);
  }
}

class Metric extends DataClass implements Insertable<Metric> {
  final int id;
  final int? parentId;
  final String key;
  final String title;

  /// 'int' | 'text' | 'int_text' | 'checkbox' | 'composite' | 'money'
  final String inputType;

  /// Original input type of a leaf that was auto-promoted to composite by
  /// a drop; restored when its last child detaches. NULL for natural
  /// composites (Development) and never-promoted cards.
  final String? prevInputType;
  final bool isStarred;

  /// Epoch ms of the star action — later-starred metrics append below the
  /// fixed core rows in star order (spec 5.3).
  final int? starredAt;
  final String? heatmapLabel;

  /// JSON bucket rule, see HeatmapRule.
  final String? heatmapRule;
  final int sortOrder;
  final String? unit;
  final bool isDeletable;

  /// 'sub_names' | 'own_value' — composite breakdown display (spec 6.3).
  final String groupDisplay;
  final int createdAt;
  final int updatedAt;
  const Metric({
    required this.id,
    this.parentId,
    required this.key,
    required this.title,
    required this.inputType,
    this.prevInputType,
    required this.isStarred,
    this.starredAt,
    this.heatmapLabel,
    this.heatmapRule,
    required this.sortOrder,
    this.unit,
    required this.isDeletable,
    required this.groupDisplay,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['input_type'] = Variable<String>(inputType);
    if (!nullToAbsent || prevInputType != null) {
      map['prev_input_type'] = Variable<String>(prevInputType);
    }
    map['is_starred'] = Variable<bool>(isStarred);
    if (!nullToAbsent || starredAt != null) {
      map['starred_at'] = Variable<int>(starredAt);
    }
    if (!nullToAbsent || heatmapLabel != null) {
      map['heatmap_label'] = Variable<String>(heatmapLabel);
    }
    if (!nullToAbsent || heatmapRule != null) {
      map['heatmap_rule'] = Variable<String>(heatmapRule);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['is_deletable'] = Variable<bool>(isDeletable);
    map['group_display'] = Variable<String>(groupDisplay);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MetricsCompanion toCompanion(bool nullToAbsent) {
    return MetricsCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      key: Value(key),
      title: Value(title),
      inputType: Value(inputType),
      prevInputType: prevInputType == null && nullToAbsent
          ? const Value.absent()
          : Value(prevInputType),
      isStarred: Value(isStarred),
      starredAt: starredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(starredAt),
      heatmapLabel: heatmapLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(heatmapLabel),
      heatmapRule: heatmapRule == null && nullToAbsent
          ? const Value.absent()
          : Value(heatmapRule),
      sortOrder: Value(sortOrder),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      isDeletable: Value(isDeletable),
      groupDisplay: Value(groupDisplay),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Metric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Metric(
      id: serializer.fromJson<int>(json['id']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      inputType: serializer.fromJson<String>(json['inputType']),
      prevInputType: serializer.fromJson<String?>(json['prevInputType']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      starredAt: serializer.fromJson<int?>(json['starredAt']),
      heatmapLabel: serializer.fromJson<String?>(json['heatmapLabel']),
      heatmapRule: serializer.fromJson<String?>(json['heatmapRule']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      unit: serializer.fromJson<String?>(json['unit']),
      isDeletable: serializer.fromJson<bool>(json['isDeletable']),
      groupDisplay: serializer.fromJson<String>(json['groupDisplay']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parentId': serializer.toJson<int?>(parentId),
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'inputType': serializer.toJson<String>(inputType),
      'prevInputType': serializer.toJson<String?>(prevInputType),
      'isStarred': serializer.toJson<bool>(isStarred),
      'starredAt': serializer.toJson<int?>(starredAt),
      'heatmapLabel': serializer.toJson<String?>(heatmapLabel),
      'heatmapRule': serializer.toJson<String?>(heatmapRule),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'unit': serializer.toJson<String?>(unit),
      'isDeletable': serializer.toJson<bool>(isDeletable),
      'groupDisplay': serializer.toJson<String>(groupDisplay),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Metric copyWith({
    int? id,
    Value<int?> parentId = const Value.absent(),
    String? key,
    String? title,
    String? inputType,
    Value<String?> prevInputType = const Value.absent(),
    bool? isStarred,
    Value<int?> starredAt = const Value.absent(),
    Value<String?> heatmapLabel = const Value.absent(),
    Value<String?> heatmapRule = const Value.absent(),
    int? sortOrder,
    Value<String?> unit = const Value.absent(),
    bool? isDeletable,
    String? groupDisplay,
    int? createdAt,
    int? updatedAt,
  }) => Metric(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    key: key ?? this.key,
    title: title ?? this.title,
    inputType: inputType ?? this.inputType,
    prevInputType: prevInputType.present
        ? prevInputType.value
        : this.prevInputType,
    isStarred: isStarred ?? this.isStarred,
    starredAt: starredAt.present ? starredAt.value : this.starredAt,
    heatmapLabel: heatmapLabel.present ? heatmapLabel.value : this.heatmapLabel,
    heatmapRule: heatmapRule.present ? heatmapRule.value : this.heatmapRule,
    sortOrder: sortOrder ?? this.sortOrder,
    unit: unit.present ? unit.value : this.unit,
    isDeletable: isDeletable ?? this.isDeletable,
    groupDisplay: groupDisplay ?? this.groupDisplay,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Metric copyWithCompanion(MetricsCompanion data) {
    return Metric(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      inputType: data.inputType.present ? data.inputType.value : this.inputType,
      prevInputType: data.prevInputType.present
          ? data.prevInputType.value
          : this.prevInputType,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      starredAt: data.starredAt.present ? data.starredAt.value : this.starredAt,
      heatmapLabel: data.heatmapLabel.present
          ? data.heatmapLabel.value
          : this.heatmapLabel,
      heatmapRule: data.heatmapRule.present
          ? data.heatmapRule.value
          : this.heatmapRule,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      unit: data.unit.present ? data.unit.value : this.unit,
      isDeletable: data.isDeletable.present
          ? data.isDeletable.value
          : this.isDeletable,
      groupDisplay: data.groupDisplay.present
          ? data.groupDisplay.value
          : this.groupDisplay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Metric(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('inputType: $inputType, ')
          ..write('prevInputType: $prevInputType, ')
          ..write('isStarred: $isStarred, ')
          ..write('starredAt: $starredAt, ')
          ..write('heatmapLabel: $heatmapLabel, ')
          ..write('heatmapRule: $heatmapRule, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('unit: $unit, ')
          ..write('isDeletable: $isDeletable, ')
          ..write('groupDisplay: $groupDisplay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    key,
    title,
    inputType,
    prevInputType,
    isStarred,
    starredAt,
    heatmapLabel,
    heatmapRule,
    sortOrder,
    unit,
    isDeletable,
    groupDisplay,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Metric &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.key == this.key &&
          other.title == this.title &&
          other.inputType == this.inputType &&
          other.prevInputType == this.prevInputType &&
          other.isStarred == this.isStarred &&
          other.starredAt == this.starredAt &&
          other.heatmapLabel == this.heatmapLabel &&
          other.heatmapRule == this.heatmapRule &&
          other.sortOrder == this.sortOrder &&
          other.unit == this.unit &&
          other.isDeletable == this.isDeletable &&
          other.groupDisplay == this.groupDisplay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MetricsCompanion extends UpdateCompanion<Metric> {
  final Value<int> id;
  final Value<int?> parentId;
  final Value<String> key;
  final Value<String> title;
  final Value<String> inputType;
  final Value<String?> prevInputType;
  final Value<bool> isStarred;
  final Value<int?> starredAt;
  final Value<String?> heatmapLabel;
  final Value<String?> heatmapRule;
  final Value<int> sortOrder;
  final Value<String?> unit;
  final Value<bool> isDeletable;
  final Value<String> groupDisplay;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const MetricsCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.inputType = const Value.absent(),
    this.prevInputType = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.heatmapLabel = const Value.absent(),
    this.heatmapRule = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.unit = const Value.absent(),
    this.isDeletable = const Value.absent(),
    this.groupDisplay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MetricsCompanion.insert({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    required String key,
    required String title,
    required String inputType,
    this.prevInputType = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.starredAt = const Value.absent(),
    this.heatmapLabel = const Value.absent(),
    this.heatmapRule = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.unit = const Value.absent(),
    this.isDeletable = const Value.absent(),
    this.groupDisplay = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : key = Value(key),
       title = Value(title),
       inputType = Value(inputType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Metric> custom({
    Expression<int>? id,
    Expression<int>? parentId,
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? inputType,
    Expression<String>? prevInputType,
    Expression<bool>? isStarred,
    Expression<int>? starredAt,
    Expression<String>? heatmapLabel,
    Expression<String>? heatmapRule,
    Expression<int>? sortOrder,
    Expression<String>? unit,
    Expression<bool>? isDeletable,
    Expression<String>? groupDisplay,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (inputType != null) 'input_type': inputType,
      if (prevInputType != null) 'prev_input_type': prevInputType,
      if (isStarred != null) 'is_starred': isStarred,
      if (starredAt != null) 'starred_at': starredAt,
      if (heatmapLabel != null) 'heatmap_label': heatmapLabel,
      if (heatmapRule != null) 'heatmap_rule': heatmapRule,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (unit != null) 'unit': unit,
      if (isDeletable != null) 'is_deletable': isDeletable,
      if (groupDisplay != null) 'group_display': groupDisplay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MetricsCompanion copyWith({
    Value<int>? id,
    Value<int?>? parentId,
    Value<String>? key,
    Value<String>? title,
    Value<String>? inputType,
    Value<String?>? prevInputType,
    Value<bool>? isStarred,
    Value<int?>? starredAt,
    Value<String?>? heatmapLabel,
    Value<String?>? heatmapRule,
    Value<int>? sortOrder,
    Value<String?>? unit,
    Value<bool>? isDeletable,
    Value<String>? groupDisplay,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return MetricsCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      key: key ?? this.key,
      title: title ?? this.title,
      inputType: inputType ?? this.inputType,
      prevInputType: prevInputType ?? this.prevInputType,
      isStarred: isStarred ?? this.isStarred,
      starredAt: starredAt ?? this.starredAt,
      heatmapLabel: heatmapLabel ?? this.heatmapLabel,
      heatmapRule: heatmapRule ?? this.heatmapRule,
      sortOrder: sortOrder ?? this.sortOrder,
      unit: unit ?? this.unit,
      isDeletable: isDeletable ?? this.isDeletable,
      groupDisplay: groupDisplay ?? this.groupDisplay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (inputType.present) {
      map['input_type'] = Variable<String>(inputType.value);
    }
    if (prevInputType.present) {
      map['prev_input_type'] = Variable<String>(prevInputType.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (starredAt.present) {
      map['starred_at'] = Variable<int>(starredAt.value);
    }
    if (heatmapLabel.present) {
      map['heatmap_label'] = Variable<String>(heatmapLabel.value);
    }
    if (heatmapRule.present) {
      map['heatmap_rule'] = Variable<String>(heatmapRule.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isDeletable.present) {
      map['is_deletable'] = Variable<bool>(isDeletable.value);
    }
    if (groupDisplay.present) {
      map['group_display'] = Variable<String>(groupDisplay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricsCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('inputType: $inputType, ')
          ..write('prevInputType: $prevInputType, ')
          ..write('isStarred: $isStarred, ')
          ..write('starredAt: $starredAt, ')
          ..write('heatmapLabel: $heatmapLabel, ')
          ..write('heatmapRule: $heatmapRule, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('unit: $unit, ')
          ..write('isDeletable: $isDeletable, ')
          ..write('groupDisplay: $groupDisplay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MetricOptionsTable extends MetricOptions
    with TableInfo<$MetricOptionsTable, MetricOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetricOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _metricIdMeta = const VerificationMeta(
    'metricId',
  );
  @override
  late final GeneratedColumn<int> metricId = GeneratedColumn<int>(
    'metric_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES metrics (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, metricId, label, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metric_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetricOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('metric_id')) {
      context.handle(
        _metricIdMeta,
        metricId.isAcceptableOrUnknown(data['metric_id']!, _metricIdMeta),
      );
    } else if (isInserting) {
      context.missing(_metricIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetricOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetricOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      metricId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metric_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MetricOptionsTable createAlias(String alias) {
    return $MetricOptionsTable(attachedDatabase, alias);
  }
}

class MetricOption extends DataClass implements Insertable<MetricOption> {
  final int id;
  final int metricId;
  final String label;
  final int sortOrder;
  const MetricOption({
    required this.id,
    required this.metricId,
    required this.label,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['metric_id'] = Variable<int>(metricId);
    map['label'] = Variable<String>(label);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MetricOptionsCompanion toCompanion(bool nullToAbsent) {
    return MetricOptionsCompanion(
      id: Value(id),
      metricId: Value(metricId),
      label: Value(label),
      sortOrder: Value(sortOrder),
    );
  }

  factory MetricOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetricOption(
      id: serializer.fromJson<int>(json['id']),
      metricId: serializer.fromJson<int>(json['metricId']),
      label: serializer.fromJson<String>(json['label']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'metricId': serializer.toJson<int>(metricId),
      'label': serializer.toJson<String>(label),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MetricOption copyWith({
    int? id,
    int? metricId,
    String? label,
    int? sortOrder,
  }) => MetricOption(
    id: id ?? this.id,
    metricId: metricId ?? this.metricId,
    label: label ?? this.label,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MetricOption copyWithCompanion(MetricOptionsCompanion data) {
    return MetricOption(
      id: data.id.present ? data.id.value : this.id,
      metricId: data.metricId.present ? data.metricId.value : this.metricId,
      label: data.label.present ? data.label.value : this.label,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetricOption(')
          ..write('id: $id, ')
          ..write('metricId: $metricId, ')
          ..write('label: $label, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, metricId, label, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetricOption &&
          other.id == this.id &&
          other.metricId == this.metricId &&
          other.label == this.label &&
          other.sortOrder == this.sortOrder);
}

class MetricOptionsCompanion extends UpdateCompanion<MetricOption> {
  final Value<int> id;
  final Value<int> metricId;
  final Value<String> label;
  final Value<int> sortOrder;
  const MetricOptionsCompanion({
    this.id = const Value.absent(),
    this.metricId = const Value.absent(),
    this.label = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  MetricOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int metricId,
    required String label,
    this.sortOrder = const Value.absent(),
  }) : metricId = Value(metricId),
       label = Value(label);
  static Insertable<MetricOption> custom({
    Expression<int>? id,
    Expression<int>? metricId,
    Expression<String>? label,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricId != null) 'metric_id': metricId,
      if (label != null) 'label': label,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  MetricOptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? metricId,
    Value<String>? label,
    Value<int>? sortOrder,
  }) {
    return MetricOptionsCompanion(
      id: id ?? this.id,
      metricId: metricId ?? this.metricId,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (metricId.present) {
      map['metric_id'] = Variable<int>(metricId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricOptionsCompanion(')
          ..write('id: $id, ')
          ..write('metricId: $metricId, ')
          ..write('label: $label, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _metricIdMeta = const VerificationMeta(
    'metricId',
  );
  @override
  late final GeneratedColumn<int> metricId = GeneratedColumn<int>(
    'metric_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES metrics (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numValueMeta = const VerificationMeta(
    'numValue',
  );
  @override
  late final GeneratedColumn<double> numValue = GeneratedColumn<double>(
    'num_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueSourceMeta = const VerificationMeta(
    'valueSource',
  );
  @override
  late final GeneratedColumn<String> valueSource = GeneratedColumn<String>(
    'value_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    metricId,
    date,
    numValue,
    textValue,
    valueSource,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('metric_id')) {
      context.handle(
        _metricIdMeta,
        metricId.isAcceptableOrUnknown(data['metric_id']!, _metricIdMeta),
      );
    } else if (isInserting) {
      context.missing(_metricIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('num_value')) {
      context.handle(
        _numValueMeta,
        numValue.isAcceptableOrUnknown(data['num_value']!, _numValueMeta),
      );
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('value_source')) {
      context.handle(
        _valueSourceMeta,
        valueSource.isAcceptableOrUnknown(
          data['value_source']!,
          _valueSourceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {metricId, date},
  ];
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      metricId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metric_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      numValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}num_value'],
      ),
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      valueSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final int id;
  final int metricId;

  /// 'YYYY-MM-DD' local time.
  final String date;
  final double? numValue;
  final String? textValue;

  /// 'manual' | 'auto' (CR-4 §3.3): a manual edit pins the day so
  /// screen-time auto-fill never overwrites it again.
  final String valueSource;
  final int createdAt;
  final int updatedAt;
  const Entry({
    required this.id,
    required this.metricId,
    required this.date,
    this.numValue,
    this.textValue,
    required this.valueSource,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['metric_id'] = Variable<int>(metricId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || numValue != null) {
      map['num_value'] = Variable<double>(numValue);
    }
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    map['value_source'] = Variable<String>(valueSource);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      metricId: Value(metricId),
      date: Value(date),
      numValue: numValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numValue),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      valueSource: Value(valueSource),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<int>(json['id']),
      metricId: serializer.fromJson<int>(json['metricId']),
      date: serializer.fromJson<String>(json['date']),
      numValue: serializer.fromJson<double?>(json['numValue']),
      textValue: serializer.fromJson<String?>(json['textValue']),
      valueSource: serializer.fromJson<String>(json['valueSource']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'metricId': serializer.toJson<int>(metricId),
      'date': serializer.toJson<String>(date),
      'numValue': serializer.toJson<double?>(numValue),
      'textValue': serializer.toJson<String?>(textValue),
      'valueSource': serializer.toJson<String>(valueSource),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Entry copyWith({
    int? id,
    int? metricId,
    String? date,
    Value<double?> numValue = const Value.absent(),
    Value<String?> textValue = const Value.absent(),
    String? valueSource,
    int? createdAt,
    int? updatedAt,
  }) => Entry(
    id: id ?? this.id,
    metricId: metricId ?? this.metricId,
    date: date ?? this.date,
    numValue: numValue.present ? numValue.value : this.numValue,
    textValue: textValue.present ? textValue.value : this.textValue,
    valueSource: valueSource ?? this.valueSource,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      metricId: data.metricId.present ? data.metricId.value : this.metricId,
      date: data.date.present ? data.date.value : this.date,
      numValue: data.numValue.present ? data.numValue.value : this.numValue,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      valueSource: data.valueSource.present
          ? data.valueSource.value
          : this.valueSource,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('metricId: $metricId, ')
          ..write('date: $date, ')
          ..write('numValue: $numValue, ')
          ..write('textValue: $textValue, ')
          ..write('valueSource: $valueSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    metricId,
    date,
    numValue,
    textValue,
    valueSource,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.metricId == this.metricId &&
          other.date == this.date &&
          other.numValue == this.numValue &&
          other.textValue == this.textValue &&
          other.valueSource == this.valueSource &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<int> metricId;
  final Value<String> date;
  final Value<double?> numValue;
  final Value<String?> textValue;
  final Value<String> valueSource;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.metricId = const Value.absent(),
    this.date = const Value.absent(),
    this.numValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.valueSource = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int metricId,
    required String date,
    this.numValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.valueSource = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : metricId = Value(metricId),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Entry> custom({
    Expression<int>? id,
    Expression<int>? metricId,
    Expression<String>? date,
    Expression<double>? numValue,
    Expression<String>? textValue,
    Expression<String>? valueSource,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricId != null) 'metric_id': metricId,
      if (date != null) 'date': date,
      if (numValue != null) 'num_value': numValue,
      if (textValue != null) 'text_value': textValue,
      if (valueSource != null) 'value_source': valueSource,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? metricId,
    Value<String>? date,
    Value<double?>? numValue,
    Value<String?>? textValue,
    Value<String>? valueSource,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      metricId: metricId ?? this.metricId,
      date: date ?? this.date,
      numValue: numValue ?? this.numValue,
      textValue: textValue ?? this.textValue,
      valueSource: valueSource ?? this.valueSource,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (metricId.present) {
      map['metric_id'] = Variable<int>(metricId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (numValue.present) {
      map['num_value'] = Variable<double>(numValue.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (valueSource.present) {
      map['value_source'] = Variable<String>(valueSource.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('metricId: $metricId, ')
          ..write('date: $date, ')
          ..write('numValue: $numValue, ')
          ..write('textValue: $textValue, ')
          ..write('valueSource: $valueSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntryOptionsTable extends EntryOptions
    with TableInfo<$EntryOptionsTable, EntryOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _optionIdMeta = const VerificationMeta(
    'optionId',
  );
  @override
  late final GeneratedColumn<int> optionId = GeneratedColumn<int>(
    'option_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES metric_options (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, optionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('option_id')) {
      context.handle(
        _optionIdMeta,
        optionId.isAcceptableOrUnknown(data['option_id']!, _optionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_optionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, optionId};
  @override
  EntryOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryOption(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      optionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}option_id'],
      )!,
    );
  }

  @override
  $EntryOptionsTable createAlias(String alias) {
    return $EntryOptionsTable(attachedDatabase, alias);
  }
}

class EntryOption extends DataClass implements Insertable<EntryOption> {
  final int entryId;
  final int optionId;
  const EntryOption({required this.entryId, required this.optionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<int>(entryId);
    map['option_id'] = Variable<int>(optionId);
    return map;
  }

  EntryOptionsCompanion toCompanion(bool nullToAbsent) {
    return EntryOptionsCompanion(
      entryId: Value(entryId),
      optionId: Value(optionId),
    );
  }

  factory EntryOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryOption(
      entryId: serializer.fromJson<int>(json['entryId']),
      optionId: serializer.fromJson<int>(json['optionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<int>(entryId),
      'optionId': serializer.toJson<int>(optionId),
    };
  }

  EntryOption copyWith({int? entryId, int? optionId}) => EntryOption(
    entryId: entryId ?? this.entryId,
    optionId: optionId ?? this.optionId,
  );
  EntryOption copyWithCompanion(EntryOptionsCompanion data) {
    return EntryOption(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      optionId: data.optionId.present ? data.optionId.value : this.optionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryOption(')
          ..write('entryId: $entryId, ')
          ..write('optionId: $optionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, optionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryOption &&
          other.entryId == this.entryId &&
          other.optionId == this.optionId);
}

class EntryOptionsCompanion extends UpdateCompanion<EntryOption> {
  final Value<int> entryId;
  final Value<int> optionId;
  final Value<int> rowid;
  const EntryOptionsCompanion({
    this.entryId = const Value.absent(),
    this.optionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryOptionsCompanion.insert({
    required int entryId,
    required int optionId,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       optionId = Value(optionId);
  static Insertable<EntryOption> custom({
    Expression<int>? entryId,
    Expression<int>? optionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (optionId != null) 'option_id': optionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryOptionsCompanion copyWith({
    Value<int>? entryId,
    Value<int>? optionId,
    Value<int>? rowid,
  }) {
    return EntryOptionsCompanion(
      entryId: entryId ?? this.entryId,
      optionId: optionId ?? this.optionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (optionId.present) {
      map['option_id'] = Variable<int>(optionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryOptionsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('optionId: $optionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount >= 0)',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    direction,
    amount,
    category,
    subtype,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String date;

  /// 'income' | 'outcome'
  final String direction;
  final double amount;
  final String category;

  /// NULL → plain category; 'home' → shown as 'Bill (home)'.
  final String? subtype;
  final String? note;
  final int createdAt;
  final int updatedAt;
  const Transaction({
    required this.id,
    required this.date,
    required this.direction,
    required this.amount,
    required this.category,
    this.subtype,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['direction'] = Variable<String>(direction);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      date: Value(date),
      direction: Value(direction),
      amount: Value(amount),
      category: Value(category),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      direction: serializer.fromJson<String>(json['direction']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'direction': serializer.toJson<String>(direction),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'subtype': serializer.toJson<String?>(subtype),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Transaction copyWith({
    int? id,
    String? date,
    String? direction,
    double? amount,
    String? category,
    Value<String?> subtype = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Transaction(
    id: id ?? this.id,
    date: date ?? this.date,
    direction: direction ?? this.direction,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    subtype: subtype.present ? subtype.value : this.subtype,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      direction: data.direction.present ? data.direction.value : this.direction,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('subtype: $subtype, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    direction,
    amount,
    category,
    subtype,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.date == this.date &&
          other.direction == this.direction &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.subtype == this.subtype &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> direction;
  final Value<double> amount;
  final Value<String> category;
  final Value<String?> subtype;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.direction = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.subtype = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String direction,
    required double amount,
    required String category,
    this.subtype = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : date = Value(date),
       direction = Value(direction),
       amount = Value(amount),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? direction,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? subtype,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (direction != null) 'direction': direction,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (subtype != null) 'subtype': subtype,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? direction,
    Value<double>? amount,
    Value<String>? category,
    Value<String?>? subtype,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subtype: subtype ?? this.subtype,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('subtype: $subtype, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MoneyCategoriesTable extends MoneyCategories
    with TableInfo<$MoneyCategoriesTable, MoneyCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEssentialMeta = const VerificationMeta(
    'isEssential',
  );
  @override
  late final GeneratedColumn<bool> isEssential = GeneratedColumn<bool>(
    'is_essential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_essential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _countsInHeatmapMeta = const VerificationMeta(
    'countsInHeatmap',
  );
  @override
  late final GeneratedColumn<bool> countsInHeatmap = GeneratedColumn<bool>(
    'counts_in_heatmap',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("counts_in_heatmap" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    direction,
    name,
    isEssential,
    countsInHeatmap,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_essential')) {
      context.handle(
        _isEssentialMeta,
        isEssential.isAcceptableOrUnknown(
          data['is_essential']!,
          _isEssentialMeta,
        ),
      );
    }
    if (data.containsKey('counts_in_heatmap')) {
      context.handle(
        _countsInHeatmapMeta,
        countsInHeatmap.isAcceptableOrUnknown(
          data['counts_in_heatmap']!,
          _countsInHeatmapMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {direction, name},
  ];
  @override
  MoneyCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isEssential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_essential'],
      )!,
      countsInHeatmap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counts_in_heatmap'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MoneyCategoriesTable createAlias(String alias) {
    return $MoneyCategoriesTable(attachedDatabase, alias);
  }
}

class MoneyCategory extends DataClass implements Insertable<MoneyCategory> {
  final int id;

  /// 'income' | 'outcome'
  final String direction;
  final String name;

  /// 1 → subtracted in the red/green budget formula.
  final bool isEssential;

  /// 1 → included in the Money heatmap daily sum (food + entertainment).
  final bool countsInHeatmap;
  final int sortOrder;
  const MoneyCategory({
    required this.id,
    required this.direction,
    required this.name,
    required this.isEssential,
    required this.countsInHeatmap,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['direction'] = Variable<String>(direction);
    map['name'] = Variable<String>(name);
    map['is_essential'] = Variable<bool>(isEssential);
    map['counts_in_heatmap'] = Variable<bool>(countsInHeatmap);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MoneyCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MoneyCategoriesCompanion(
      id: Value(id),
      direction: Value(direction),
      name: Value(name),
      isEssential: Value(isEssential),
      countsInHeatmap: Value(countsInHeatmap),
      sortOrder: Value(sortOrder),
    );
  }

  factory MoneyCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyCategory(
      id: serializer.fromJson<int>(json['id']),
      direction: serializer.fromJson<String>(json['direction']),
      name: serializer.fromJson<String>(json['name']),
      isEssential: serializer.fromJson<bool>(json['isEssential']),
      countsInHeatmap: serializer.fromJson<bool>(json['countsInHeatmap']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'direction': serializer.toJson<String>(direction),
      'name': serializer.toJson<String>(name),
      'isEssential': serializer.toJson<bool>(isEssential),
      'countsInHeatmap': serializer.toJson<bool>(countsInHeatmap),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MoneyCategory copyWith({
    int? id,
    String? direction,
    String? name,
    bool? isEssential,
    bool? countsInHeatmap,
    int? sortOrder,
  }) => MoneyCategory(
    id: id ?? this.id,
    direction: direction ?? this.direction,
    name: name ?? this.name,
    isEssential: isEssential ?? this.isEssential,
    countsInHeatmap: countsInHeatmap ?? this.countsInHeatmap,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MoneyCategory copyWithCompanion(MoneyCategoriesCompanion data) {
    return MoneyCategory(
      id: data.id.present ? data.id.value : this.id,
      direction: data.direction.present ? data.direction.value : this.direction,
      name: data.name.present ? data.name.value : this.name,
      isEssential: data.isEssential.present
          ? data.isEssential.value
          : this.isEssential,
      countsInHeatmap: data.countsInHeatmap.present
          ? data.countsInHeatmap.value
          : this.countsInHeatmap,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyCategory(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('name: $name, ')
          ..write('isEssential: $isEssential, ')
          ..write('countsInHeatmap: $countsInHeatmap, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, direction, name, isEssential, countsInHeatmap, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyCategory &&
          other.id == this.id &&
          other.direction == this.direction &&
          other.name == this.name &&
          other.isEssential == this.isEssential &&
          other.countsInHeatmap == this.countsInHeatmap &&
          other.sortOrder == this.sortOrder);
}

class MoneyCategoriesCompanion extends UpdateCompanion<MoneyCategory> {
  final Value<int> id;
  final Value<String> direction;
  final Value<String> name;
  final Value<bool> isEssential;
  final Value<bool> countsInHeatmap;
  final Value<int> sortOrder;
  const MoneyCategoriesCompanion({
    this.id = const Value.absent(),
    this.direction = const Value.absent(),
    this.name = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.countsInHeatmap = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  MoneyCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String direction,
    required String name,
    this.isEssential = const Value.absent(),
    this.countsInHeatmap = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : direction = Value(direction),
       name = Value(name);
  static Insertable<MoneyCategory> custom({
    Expression<int>? id,
    Expression<String>? direction,
    Expression<String>? name,
    Expression<bool>? isEssential,
    Expression<bool>? countsInHeatmap,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (direction != null) 'direction': direction,
      if (name != null) 'name': name,
      if (isEssential != null) 'is_essential': isEssential,
      if (countsInHeatmap != null) 'counts_in_heatmap': countsInHeatmap,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  MoneyCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? direction,
    Value<String>? name,
    Value<bool>? isEssential,
    Value<bool>? countsInHeatmap,
    Value<int>? sortOrder,
  }) {
    return MoneyCategoriesCompanion(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      name: name ?? this.name,
      isEssential: isEssential ?? this.isEssential,
      countsInHeatmap: countsInHeatmap ?? this.countsInHeatmap,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isEssential.present) {
      map['is_essential'] = Variable<bool>(isEssential.value);
    }
    if (countsInHeatmap.present) {
      map['counts_in_heatmap'] = Variable<bool>(countsInHeatmap.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('name: $name, ')
          ..write('isEssential: $isEssential, ')
          ..write('countsInHeatmap: $countsInHeatmap, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ExpenseRemindersTable extends ExpenseReminders
    with TableInfo<$ExpenseRemindersTable, ExpenseReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _remindDateMeta = const VerificationMeta(
    'remindDate',
  );
  @override
  late final GeneratedColumn<String> remindDate = GeneratedColumn<String>(
    'remind_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firedMeta = const VerificationMeta('fired');
  @override
  late final GeneratedColumn<bool> fired = GeneratedColumn<bool>(
    'fired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, remindDate, fired];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('remind_date')) {
      context.handle(
        _remindDateMeta,
        remindDate.isAcceptableOrUnknown(data['remind_date']!, _remindDateMeta),
      );
    } else if (isInserting) {
      context.missing(_remindDateMeta);
    }
    if (data.containsKey('fired')) {
      context.handle(
        _firedMeta,
        fired.isAcceptableOrUnknown(data['fired']!, _firedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      remindDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remind_date'],
      )!,
      fired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fired'],
      )!,
    );
  }

  @override
  $ExpenseRemindersTable createAlias(String alias) {
    return $ExpenseRemindersTable(attachedDatabase, alias);
  }
}

class ExpenseReminder extends DataClass implements Insertable<ExpenseReminder> {
  final int id;
  final int transactionId;
  final String remindDate;
  final bool fired;
  const ExpenseReminder({
    required this.id,
    required this.transactionId,
    required this.remindDate,
    required this.fired,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['remind_date'] = Variable<String>(remindDate);
    map['fired'] = Variable<bool>(fired);
    return map;
  }

  ExpenseRemindersCompanion toCompanion(bool nullToAbsent) {
    return ExpenseRemindersCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      remindDate: Value(remindDate),
      fired: Value(fired),
    );
  }

  factory ExpenseReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseReminder(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      remindDate: serializer.fromJson<String>(json['remindDate']),
      fired: serializer.fromJson<bool>(json['fired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'remindDate': serializer.toJson<String>(remindDate),
      'fired': serializer.toJson<bool>(fired),
    };
  }

  ExpenseReminder copyWith({
    int? id,
    int? transactionId,
    String? remindDate,
    bool? fired,
  }) => ExpenseReminder(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    remindDate: remindDate ?? this.remindDate,
    fired: fired ?? this.fired,
  );
  ExpenseReminder copyWithCompanion(ExpenseRemindersCompanion data) {
    return ExpenseReminder(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      remindDate: data.remindDate.present
          ? data.remindDate.value
          : this.remindDate,
      fired: data.fired.present ? data.fired.value : this.fired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseReminder(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('remindDate: $remindDate, ')
          ..write('fired: $fired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, remindDate, fired);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseReminder &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.remindDate == this.remindDate &&
          other.fired == this.fired);
}

class ExpenseRemindersCompanion extends UpdateCompanion<ExpenseReminder> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<String> remindDate;
  final Value<bool> fired;
  const ExpenseRemindersCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.remindDate = const Value.absent(),
    this.fired = const Value.absent(),
  });
  ExpenseRemindersCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required String remindDate,
    this.fired = const Value.absent(),
  }) : transactionId = Value(transactionId),
       remindDate = Value(remindDate);
  static Insertable<ExpenseReminder> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<String>? remindDate,
    Expression<bool>? fired,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (remindDate != null) 'remind_date': remindDate,
      if (fired != null) 'fired': fired,
    });
  }

  ExpenseRemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? transactionId,
    Value<String>? remindDate,
    Value<bool>? fired,
  }) {
    return ExpenseRemindersCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      remindDate: remindDate ?? this.remindDate,
      fired: fired ?? this.fired,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (remindDate.present) {
      map['remind_date'] = Variable<String>(remindDate.value);
    }
    if (fired.present) {
      map['fired'] = Variable<bool>(fired.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRemindersCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('remindDate: $remindDate, ')
          ..write('fired: $fired')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthProfileTable extends HealthProfile
    with TableInfo<$HealthProfileTable, HealthProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthProfileTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    birthDate,
    sex,
    heightCm,
    activityLevel,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HealthProfileTable createAlias(String alias) {
    return $HealthProfileTable(attachedDatabase, alias);
  }
}

class HealthProfileData extends DataClass
    implements Insertable<HealthProfileData> {
  final int id;
  final String? birthDate;
  final String? sex;
  final double? heightCm;

  /// 'sedentary' | 'light' | 'moderate' | 'active' | 'very'
  final String? activityLevel;
  final int updatedAt;
  const HealthProfileData({
    required this.id,
    this.birthDate,
    this.sex,
    this.heightCm,
    this.activityLevel,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  HealthProfileCompanion toCompanion(bool nullToAbsent) {
    return HealthProfileCompanion(
      id: Value(id),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      updatedAt: Value(updatedAt),
    );
  }

  factory HealthProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthProfileData(
      id: serializer.fromJson<int>(json['id']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      sex: serializer.fromJson<String?>(json['sex']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'birthDate': serializer.toJson<String?>(birthDate),
      'sex': serializer.toJson<String?>(sex),
      'heightCm': serializer.toJson<double?>(heightCm),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  HealthProfileData copyWith({
    int? id,
    Value<String?> birthDate = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<String?> activityLevel = const Value.absent(),
    int? updatedAt,
  }) => HealthProfileData(
    id: id ?? this.id,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    sex: sex.present ? sex.value : this.sex,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HealthProfileData copyWithCompanion(HealthProfileCompanion data) {
    return HealthProfileData(
      id: data.id.present ? data.id.value : this.id,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sex: data.sex.present ? data.sex.value : this.sex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthProfileData(')
          ..write('id: $id, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, birthDate, sex, heightCm, activityLevel, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthProfileData &&
          other.id == this.id &&
          other.birthDate == this.birthDate &&
          other.sex == this.sex &&
          other.heightCm == this.heightCm &&
          other.activityLevel == this.activityLevel &&
          other.updatedAt == this.updatedAt);
}

class HealthProfileCompanion extends UpdateCompanion<HealthProfileData> {
  final Value<int> id;
  final Value<String?> birthDate;
  final Value<String?> sex;
  final Value<double?> heightCm;
  final Value<String?> activityLevel;
  final Value<int> updatedAt;
  const HealthProfileCompanion({
    this.id = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HealthProfileCompanion.insert({
    this.id = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    required int updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<HealthProfileData> custom({
    Expression<int>? id,
    Expression<String>? birthDate,
    Expression<String>? sex,
    Expression<double>? heightCm,
    Expression<String>? activityLevel,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (birthDate != null) 'birth_date': birthDate,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HealthProfileCompanion copyWith({
    Value<int>? id,
    Value<String?>? birthDate,
    Value<String?>? sex,
    Value<double?>? heightCm,
    Value<String?>? activityLevel,
    Value<int>? updatedAt,
  }) {
    return HealthProfileCompanion(
      id: id ?? this.id,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthProfileCompanion(')
          ..write('id: $id, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BodyLogTable extends BodyLog with TableInfo<$BodyLogTable, BodyLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyFatPctMeta = const VerificationMeta(
    'bodyFatPct',
  );
  @override
  late final GeneratedColumn<double> bodyFatPct = GeneratedColumn<double>(
    'body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    weightKg,
    bodyFatPct,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('body_fat_pct')) {
      context.handle(
        _bodyFatPctMeta,
        bodyFatPct.isAcceptableOrUnknown(
          data['body_fat_pct']!,
          _bodyFatPctMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date},
  ];
  @override
  BodyLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      bodyFatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat_pct'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BodyLogTable createAlias(String alias) {
    return $BodyLogTable(attachedDatabase, alias);
  }
}

class BodyLogData extends DataClass implements Insertable<BodyLogData> {
  final int id;
  final String date;
  final double? weightKg;
  final double? bodyFatPct;
  final int createdAt;
  final int updatedAt;
  const BodyLogData({
    required this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPct,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || bodyFatPct != null) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BodyLogCompanion toCompanion(bool nullToAbsent) {
    return BodyLogCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      bodyFatPct: bodyFatPct == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPct),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BodyLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyLogData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      bodyFatPct: serializer.fromJson<double?>(json['bodyFatPct']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'weightKg': serializer.toJson<double?>(weightKg),
      'bodyFatPct': serializer.toJson<double?>(bodyFatPct),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BodyLogData copyWith({
    int? id,
    String? date,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> bodyFatPct = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => BodyLogData(
    id: id ?? this.id,
    date: date ?? this.date,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    bodyFatPct: bodyFatPct.present ? bodyFatPct.value : this.bodyFatPct,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BodyLogData copyWithCompanion(BodyLogCompanion data) {
    return BodyLogData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bodyFatPct: data.bodyFatPct.present
          ? data.bodyFatPct.value
          : this.bodyFatPct,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyLogData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, weightKg, bodyFatPct, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyLogData &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.bodyFatPct == this.bodyFatPct &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BodyLogCompanion extends UpdateCompanion<BodyLogData> {
  final Value<int> id;
  final Value<String> date;
  final Value<double?> weightKg;
  final Value<double?> bodyFatPct;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const BodyLogCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BodyLogCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.weightKg = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BodyLogData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<double>? weightKg,
    Expression<double>? bodyFatPct,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BodyLogCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<double?>? weightKg,
    Value<double?>? bodyFatPct,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return BodyLogCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bodyFatPct.present) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyLogCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HealthSamplesTable extends HealthSamples
    with TableInfo<$HealthSamplesTable, HealthSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    kind,
    value,
    valueText,
    source,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, kind};
  @override
  HealthSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthSample(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      ),
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $HealthSamplesTable createAlias(String alias) {
    return $HealthSamplesTable(attachedDatabase, alias);
  }
}

class HealthSample extends DataClass implements Insertable<HealthSample> {
  final String date;

  /// 'rhr'|'hr_day'|'sleep_min'|'sleep_score'|'steps'|'vo2max'|'active_kcal'
  final String kind;
  final double? value;
  final String? valueText;
  final String source;
  final int fetchedAt;
  const HealthSample({
    required this.date,
    required this.kind,
    this.value,
    this.valueText,
    required this.source,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  HealthSamplesCompanion toCompanion(bool nullToAbsent) {
    return HealthSamplesCompanion(
      date: Value(date),
      kind: Value(kind),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory HealthSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthSample(
      date: serializer.fromJson<String>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<double?>(json['value']),
      valueText: serializer.fromJson<String?>(json['valueText']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<double?>(value),
      'valueText': serializer.toJson<String?>(valueText),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  HealthSample copyWith({
    String? date,
    String? kind,
    Value<double?> value = const Value.absent(),
    Value<String?> valueText = const Value.absent(),
    String? source,
    int? fetchedAt,
  }) => HealthSample(
    date: date ?? this.date,
    kind: kind ?? this.kind,
    value: value.present ? value.value : this.value,
    valueText: valueText.present ? valueText.value : this.valueText,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  HealthSample copyWithCompanion(HealthSamplesCompanion data) {
    return HealthSample(
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthSample(')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('valueText: $valueText, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, kind, value, valueText, source, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthSample &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.valueText == this.valueText &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt);
}

class HealthSamplesCompanion extends UpdateCompanion<HealthSample> {
  final Value<String> date;
  final Value<String> kind;
  final Value<double?> value;
  final Value<String?> valueText;
  final Value<String> source;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const HealthSamplesCompanion({
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.valueText = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthSamplesCompanion.insert({
    required String date,
    required String kind,
    this.value = const Value.absent(),
    this.valueText = const Value.absent(),
    required String source,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       kind = Value(kind),
       source = Value(source),
       fetchedAt = Value(fetchedAt);
  static Insertable<HealthSample> custom({
    Expression<String>? date,
    Expression<String>? kind,
    Expression<double>? value,
    Expression<String>? valueText,
    Expression<String>? source,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (valueText != null) 'value_text': valueText,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthSamplesCompanion copyWith({
    Value<String>? date,
    Value<String>? kind,
    Value<double?>? value,
    Value<String?>? valueText,
    Value<String>? source,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return HealthSamplesCompanion(
      date: date ?? this.date,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      valueText: valueText ?? this.valueText,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthSamplesCompanion(')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('valueText: $valueText, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncMeta = const VerificationMeta(
    'lastSync',
  );
  @override
  late final GeneratedColumn<int> lastSync = GeneratedColumn<int>(
    'last_sync',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [source, lastSync];
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
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('last_sync')) {
      context.handle(
        _lastSyncMeta,
        lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      lastSync: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String source;
  final int? lastSync;
  const SyncStateData({required this.source, this.lastSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || lastSync != null) {
      map['last_sync'] = Variable<int>(lastSync);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      source: Value(source),
      lastSync: lastSync == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSync),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      source: serializer.fromJson<String>(json['source']),
      lastSync: serializer.fromJson<int?>(json['lastSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'lastSync': serializer.toJson<int?>(lastSync),
    };
  }

  SyncStateData copyWith({
    String? source,
    Value<int?> lastSync = const Value.absent(),
  }) => SyncStateData(
    source: source ?? this.source,
    lastSync: lastSync.present ? lastSync.value : this.lastSync,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      source: data.source.present ? data.source.value : this.source,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('source: $source, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.source == this.source &&
          other.lastSync == this.lastSync);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> source;
  final Value<int?> lastSync;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.source = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String source,
    this.lastSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source);
  static Insertable<SyncStateData> custom({
    Expression<String>? source,
    Expression<int>? lastSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (lastSync != null) 'last_sync': lastSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? source,
    Value<int?>? lastSync,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      source: source ?? this.source,
      lastSync: lastSync ?? this.lastSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<int>(lastSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('source: $source, ')
          ..write('lastSync: $lastSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedExerciseTitlesTable extends SavedExerciseTitles
    with TableInfo<$SavedExerciseTitlesTable, SavedExerciseTitle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedExerciseTitlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_exercise_titles';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedExerciseTitle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SavedExerciseTitle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedExerciseTitle(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SavedExerciseTitlesTable createAlias(String alias) {
    return $SavedExerciseTitlesTable(attachedDatabase, alias);
  }
}

class SavedExerciseTitle extends DataClass
    implements Insertable<SavedExerciseTitle> {
  final String name;
  const SavedExerciseTitle({required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    return map;
  }

  SavedExerciseTitlesCompanion toCompanion(bool nullToAbsent) {
    return SavedExerciseTitlesCompanion(name: Value(name));
  }

  factory SavedExerciseTitle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedExerciseTitle(name: serializer.fromJson<String>(json['name']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'name': serializer.toJson<String>(name)};
  }

  SavedExerciseTitle copyWith({String? name}) =>
      SavedExerciseTitle(name: name ?? this.name);
  SavedExerciseTitle copyWithCompanion(SavedExerciseTitlesCompanion data) {
    return SavedExerciseTitle(
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedExerciseTitle(')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedExerciseTitle && other.name == this.name);
}

class SavedExerciseTitlesCompanion extends UpdateCompanion<SavedExerciseTitle> {
  final Value<String> name;
  final Value<int> rowid;
  const SavedExerciseTitlesCompanion({
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedExerciseTitlesCompanion.insert({
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SavedExerciseTitle> custom({
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedExerciseTitlesCompanion copyWith({
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return SavedExerciseTitlesCompanion(
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedExerciseTitlesCompanion(')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedFoodTypesTable extends SavedFoodTypes
    with TableInfo<$SavedFoodTypesTable, SavedFoodType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedFoodTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [name, isBuiltin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_food_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedFoodType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SavedFoodType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedFoodType(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
    );
  }

  @override
  $SavedFoodTypesTable createAlias(String alias) {
    return $SavedFoodTypesTable(attachedDatabase, alias);
  }
}

class SavedFoodType extends DataClass implements Insertable<SavedFoodType> {
  final String name;
  final bool isBuiltin;
  const SavedFoodType({required this.name, required this.isBuiltin});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    return map;
  }

  SavedFoodTypesCompanion toCompanion(bool nullToAbsent) {
    return SavedFoodTypesCompanion(
      name: Value(name),
      isBuiltin: Value(isBuiltin),
    );
  }

  factory SavedFoodType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedFoodType(
      name: serializer.fromJson<String>(json['name']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
    };
  }

  SavedFoodType copyWith({String? name, bool? isBuiltin}) => SavedFoodType(
    name: name ?? this.name,
    isBuiltin: isBuiltin ?? this.isBuiltin,
  );
  SavedFoodType copyWithCompanion(SavedFoodTypesCompanion data) {
    return SavedFoodType(
      name: data.name.present ? data.name.value : this.name,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedFoodType(')
          ..write('name: $name, ')
          ..write('isBuiltin: $isBuiltin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, isBuiltin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedFoodType &&
          other.name == this.name &&
          other.isBuiltin == this.isBuiltin);
}

class SavedFoodTypesCompanion extends UpdateCompanion<SavedFoodType> {
  final Value<String> name;
  final Value<bool> isBuiltin;
  final Value<int> rowid;
  const SavedFoodTypesCompanion({
    this.name = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedFoodTypesCompanion.insert({
    required String name,
    this.isBuiltin = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SavedFoodType> custom({
    Expression<String>? name,
    Expression<bool>? isBuiltin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedFoodTypesCompanion copyWith({
    Value<String>? name,
    Value<bool>? isBuiltin,
    Value<int>? rowid,
  }) {
    return SavedFoodTypesCompanion(
      name: name ?? this.name,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedFoodTypesCompanion(')
          ..write('name: $name, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramsTable extends Programs with TableInfo<$ProgramsTable, Program> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Program> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Program map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Program(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ProgramsTable createAlias(String alias) {
    return $ProgramsTable(attachedDatabase, alias);
  }
}

class Program extends DataClass implements Insertable<Program> {
  final int id;
  final String name;
  final int createdAt;
  final int sortOrder;
  const Program({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProgramsCompanion toCompanion(bool nullToAbsent) {
    return ProgramsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Program.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Program(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Program copyWith({int? id, String? name, int? createdAt, int? sortOrder}) =>
      Program(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Program copyWithCompanion(ProgramsCompanion data) {
    return Program(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Program(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Program &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class ProgramsCompanion extends UpdateCompanion<Program> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> sortOrder;
  const ProgramsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ProgramsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int createdAt,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Program> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ProgramsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? sortOrder,
  }) {
    return ProgramsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ProgramExercisesTable extends ProgramExercises
    with TableInfo<$ProgramExercisesTable, ProgramExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<String> sets = GeneratedColumn<String>(
    'sets',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restAfterMeta = const VerificationMeta(
    'restAfter',
  );
  @override
  late final GeneratedColumn<bool> restAfter = GeneratedColumn<bool>(
    'rest_after',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rest_after" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  @override
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersetRoundsMeta = const VerificationMeta(
    'supersetRounds',
  );
  @override
  late final GeneratedColumn<int> supersetRounds = GeneratedColumn<int>(
    'superset_rounds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    programId,
    name,
    sets,
    duration,
    restAfter,
    supersetGroup,
    supersetRounds,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('rest_after')) {
      context.handle(
        _restAfterMeta,
        restAfter.isAcceptableOrUnknown(data['rest_after']!, _restAfterMeta),
      );
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    if (data.containsKey('superset_rounds')) {
      context.handle(
        _supersetRoundsMeta,
        supersetRounds.isAcceptableOrUnknown(
          data['superset_rounds']!,
          _supersetRoundsMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}program_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sets'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      ),
      restAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rest_after'],
      )!,
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
      supersetRounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_rounds'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ProgramExercisesTable createAlias(String alias) {
    return $ProgramExercisesTable(attachedDatabase, alias);
  }
}

class ProgramExercise extends DataClass implements Insertable<ProgramExercise> {
  final int id;
  final int programId;
  final String name;
  final String? sets;
  final String? duration;
  final bool restAfter;
  final int? supersetGroup;
  final int? supersetRounds;
  final int sortOrder;
  const ProgramExercise({
    required this.id,
    required this.programId,
    required this.name,
    this.sets,
    this.duration,
    required this.restAfter,
    this.supersetGroup,
    this.supersetRounds,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program_id'] = Variable<int>(programId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sets != null) {
      map['sets'] = Variable<String>(sets);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<String>(duration);
    }
    map['rest_after'] = Variable<bool>(restAfter);
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    if (!nullToAbsent || supersetRounds != null) {
      map['superset_rounds'] = Variable<int>(supersetRounds);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProgramExercisesCompanion toCompanion(bool nullToAbsent) {
    return ProgramExercisesCompanion(
      id: Value(id),
      programId: Value(programId),
      name: Value(name),
      sets: sets == null && nullToAbsent ? const Value.absent() : Value(sets),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      restAfter: Value(restAfter),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
      supersetRounds: supersetRounds == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetRounds),
      sortOrder: Value(sortOrder),
    );
  }

  factory ProgramExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramExercise(
      id: serializer.fromJson<int>(json['id']),
      programId: serializer.fromJson<int>(json['programId']),
      name: serializer.fromJson<String>(json['name']),
      sets: serializer.fromJson<String?>(json['sets']),
      duration: serializer.fromJson<String?>(json['duration']),
      restAfter: serializer.fromJson<bool>(json['restAfter']),
      supersetGroup: serializer.fromJson<int?>(json['supersetGroup']),
      supersetRounds: serializer.fromJson<int?>(json['supersetRounds']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programId': serializer.toJson<int>(programId),
      'name': serializer.toJson<String>(name),
      'sets': serializer.toJson<String?>(sets),
      'duration': serializer.toJson<String?>(duration),
      'restAfter': serializer.toJson<bool>(restAfter),
      'supersetGroup': serializer.toJson<int?>(supersetGroup),
      'supersetRounds': serializer.toJson<int?>(supersetRounds),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ProgramExercise copyWith({
    int? id,
    int? programId,
    String? name,
    Value<String?> sets = const Value.absent(),
    Value<String?> duration = const Value.absent(),
    bool? restAfter,
    Value<int?> supersetGroup = const Value.absent(),
    Value<int?> supersetRounds = const Value.absent(),
    int? sortOrder,
  }) => ProgramExercise(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    name: name ?? this.name,
    sets: sets.present ? sets.value : this.sets,
    duration: duration.present ? duration.value : this.duration,
    restAfter: restAfter ?? this.restAfter,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
    supersetRounds: supersetRounds.present
        ? supersetRounds.value
        : this.supersetRounds,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ProgramExercise copyWithCompanion(ProgramExercisesCompanion data) {
    return ProgramExercise(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      name: data.name.present ? data.name.value : this.name,
      sets: data.sets.present ? data.sets.value : this.sets,
      duration: data.duration.present ? data.duration.value : this.duration,
      restAfter: data.restAfter.present ? data.restAfter.value : this.restAfter,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
      supersetRounds: data.supersetRounds.present
          ? data.supersetRounds.value
          : this.supersetRounds,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramExercise(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('name: $name, ')
          ..write('sets: $sets, ')
          ..write('duration: $duration, ')
          ..write('restAfter: $restAfter, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('supersetRounds: $supersetRounds, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    programId,
    name,
    sets,
    duration,
    restAfter,
    supersetGroup,
    supersetRounds,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramExercise &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.name == this.name &&
          other.sets == this.sets &&
          other.duration == this.duration &&
          other.restAfter == this.restAfter &&
          other.supersetGroup == this.supersetGroup &&
          other.supersetRounds == this.supersetRounds &&
          other.sortOrder == this.sortOrder);
}

class ProgramExercisesCompanion extends UpdateCompanion<ProgramExercise> {
  final Value<int> id;
  final Value<int> programId;
  final Value<String> name;
  final Value<String?> sets;
  final Value<String?> duration;
  final Value<bool> restAfter;
  final Value<int?> supersetGroup;
  final Value<int?> supersetRounds;
  final Value<int> sortOrder;
  const ProgramExercisesCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.name = const Value.absent(),
    this.sets = const Value.absent(),
    this.duration = const Value.absent(),
    this.restAfter = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.supersetRounds = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ProgramExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int programId,
    required String name,
    this.sets = const Value.absent(),
    this.duration = const Value.absent(),
    this.restAfter = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.supersetRounds = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : programId = Value(programId),
       name = Value(name);
  static Insertable<ProgramExercise> custom({
    Expression<int>? id,
    Expression<int>? programId,
    Expression<String>? name,
    Expression<String>? sets,
    Expression<String>? duration,
    Expression<bool>? restAfter,
    Expression<int>? supersetGroup,
    Expression<int>? supersetRounds,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (name != null) 'name': name,
      if (sets != null) 'sets': sets,
      if (duration != null) 'duration': duration,
      if (restAfter != null) 'rest_after': restAfter,
      if (supersetGroup != null) 'superset_group': supersetGroup,
      if (supersetRounds != null) 'superset_rounds': supersetRounds,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ProgramExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? programId,
    Value<String>? name,
    Value<String?>? sets,
    Value<String?>? duration,
    Value<bool>? restAfter,
    Value<int?>? supersetGroup,
    Value<int?>? supersetRounds,
    Value<int>? sortOrder,
  }) {
    return ProgramExercisesCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      duration: duration ?? this.duration,
      restAfter: restAfter ?? this.restAfter,
      supersetGroup: supersetGroup ?? this.supersetGroup,
      supersetRounds: supersetRounds ?? this.supersetRounds,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sets.present) {
      map['sets'] = Variable<String>(sets.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (restAfter.present) {
      map['rest_after'] = Variable<bool>(restAfter.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    if (supersetRounds.present) {
      map['superset_rounds'] = Variable<int>(supersetRounds.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramExercisesCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('name: $name, ')
          ..write('sets: $sets, ')
          ..write('duration: $duration, ')
          ..write('restAfter: $restAfter, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('supersetRounds: $supersetRounds, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CalorieEntriesTable extends CalorieEntries
    with TableInfo<$CalorieEntriesTable, CalorieEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalorieEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kcal >= 0)',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, meal, kcal, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calorie_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalorieEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalorieEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalorieEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CalorieEntriesTable createAlias(String alias) {
    return $CalorieEntriesTable(attachedDatabase, alias);
  }
}

class CalorieEntry extends DataClass implements Insertable<CalorieEntry> {
  final int id;
  final String date;
  final String? meal;
  final double kcal;
  final String type;
  final int createdAt;
  const CalorieEntry({
    required this.id,
    required this.date,
    this.meal,
    required this.kcal,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || meal != null) {
      map['meal'] = Variable<String>(meal);
    }
    map['kcal'] = Variable<double>(kcal);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CalorieEntriesCompanion toCompanion(bool nullToAbsent) {
    return CalorieEntriesCompanion(
      id: Value(id),
      date: Value(date),
      meal: meal == null && nullToAbsent ? const Value.absent() : Value(meal),
      kcal: Value(kcal),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory CalorieEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalorieEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      meal: serializer.fromJson<String?>(json['meal']),
      kcal: serializer.fromJson<double>(json['kcal']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'meal': serializer.toJson<String?>(meal),
      'kcal': serializer.toJson<double>(kcal),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CalorieEntry copyWith({
    int? id,
    String? date,
    Value<String?> meal = const Value.absent(),
    double? kcal,
    String? type,
    int? createdAt,
  }) => CalorieEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    meal: meal.present ? meal.value : this.meal,
    kcal: kcal ?? this.kcal,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  CalorieEntry copyWithCompanion(CalorieEntriesCompanion data) {
    return CalorieEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      meal: data.meal.present ? data.meal.value : this.meal,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalorieEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('kcal: $kcal, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, meal, kcal, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalorieEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.meal == this.meal &&
          other.kcal == this.kcal &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class CalorieEntriesCompanion extends UpdateCompanion<CalorieEntry> {
  final Value<int> id;
  final Value<String> date;
  final Value<String?> meal;
  final Value<double> kcal;
  final Value<String> type;
  final Value<int> createdAt;
  const CalorieEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.meal = const Value.absent(),
    this.kcal = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CalorieEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.meal = const Value.absent(),
    required double kcal,
    required String type,
    required int createdAt,
  }) : date = Value(date),
       kcal = Value(kcal),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<CalorieEntry> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? meal,
    Expression<double>? kcal,
    Expression<String>? type,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (meal != null) 'meal': meal,
      if (kcal != null) 'kcal': kcal,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CalorieEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String?>? meal,
    Value<double>? kcal,
    Value<String>? type,
    Value<int>? createdAt,
  }) {
    return CalorieEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      meal: meal ?? this.meal,
      kcal: kcal ?? this.kcal,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalorieEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('kcal: $kcal, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CalorieDayTable extends CalorieDay
    with TableInfo<$CalorieDayTable, CalorieDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalorieDayTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intakeMeta = const VerificationMeta('intake');
  @override
  late final GeneratedColumn<double> intake = GeneratedColumn<double>(
    'intake',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetSnapshotMeta = const VerificationMeta(
    'targetSnapshot',
  );
  @override
  late final GeneratedColumn<double> targetSnapshot = GeneratedColumn<double>(
    'target_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [date, intake, targetSnapshot, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calorie_day';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalorieDayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('intake')) {
      context.handle(
        _intakeMeta,
        intake.isAcceptableOrUnknown(data['intake']!, _intakeMeta),
      );
    }
    if (data.containsKey('target_snapshot')) {
      context.handle(
        _targetSnapshotMeta,
        targetSnapshot.isAcceptableOrUnknown(
          data['target_snapshot']!,
          _targetSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  CalorieDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalorieDayData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      intake: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}intake'],
      )!,
      targetSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_snapshot'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $CalorieDayTable createAlias(String alias) {
    return $CalorieDayTable(attachedDatabase, alias);
  }
}

class CalorieDayData extends DataClass implements Insertable<CalorieDayData> {
  final String date;
  final double intake;
  final double? targetSnapshot;
  final String? color;
  const CalorieDayData({
    required this.date,
    required this.intake,
    this.targetSnapshot,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['intake'] = Variable<double>(intake);
    if (!nullToAbsent || targetSnapshot != null) {
      map['target_snapshot'] = Variable<double>(targetSnapshot);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  CalorieDayCompanion toCompanion(bool nullToAbsent) {
    return CalorieDayCompanion(
      date: Value(date),
      intake: Value(intake),
      targetSnapshot: targetSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSnapshot),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory CalorieDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalorieDayData(
      date: serializer.fromJson<String>(json['date']),
      intake: serializer.fromJson<double>(json['intake']),
      targetSnapshot: serializer.fromJson<double?>(json['targetSnapshot']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'intake': serializer.toJson<double>(intake),
      'targetSnapshot': serializer.toJson<double?>(targetSnapshot),
      'color': serializer.toJson<String?>(color),
    };
  }

  CalorieDayData copyWith({
    String? date,
    double? intake,
    Value<double?> targetSnapshot = const Value.absent(),
    Value<String?> color = const Value.absent(),
  }) => CalorieDayData(
    date: date ?? this.date,
    intake: intake ?? this.intake,
    targetSnapshot: targetSnapshot.present
        ? targetSnapshot.value
        : this.targetSnapshot,
    color: color.present ? color.value : this.color,
  );
  CalorieDayData copyWithCompanion(CalorieDayCompanion data) {
    return CalorieDayData(
      date: data.date.present ? data.date.value : this.date,
      intake: data.intake.present ? data.intake.value : this.intake,
      targetSnapshot: data.targetSnapshot.present
          ? data.targetSnapshot.value
          : this.targetSnapshot,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalorieDayData(')
          ..write('date: $date, ')
          ..write('intake: $intake, ')
          ..write('targetSnapshot: $targetSnapshot, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, intake, targetSnapshot, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalorieDayData &&
          other.date == this.date &&
          other.intake == this.intake &&
          other.targetSnapshot == this.targetSnapshot &&
          other.color == this.color);
}

class CalorieDayCompanion extends UpdateCompanion<CalorieDayData> {
  final Value<String> date;
  final Value<double> intake;
  final Value<double?> targetSnapshot;
  final Value<String?> color;
  final Value<int> rowid;
  const CalorieDayCompanion({
    this.date = const Value.absent(),
    this.intake = const Value.absent(),
    this.targetSnapshot = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalorieDayCompanion.insert({
    required String date,
    this.intake = const Value.absent(),
    this.targetSnapshot = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<CalorieDayData> custom({
    Expression<String>? date,
    Expression<double>? intake,
    Expression<double>? targetSnapshot,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (intake != null) 'intake': intake,
      if (targetSnapshot != null) 'target_snapshot': targetSnapshot,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalorieDayCompanion copyWith({
    Value<String>? date,
    Value<double>? intake,
    Value<double?>? targetSnapshot,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return CalorieDayCompanion(
      date: date ?? this.date,
      intake: intake ?? this.intake,
      targetSnapshot: targetSnapshot ?? this.targetSnapshot,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (intake.present) {
      map['intake'] = Variable<double>(intake.value);
    }
    if (targetSnapshot.present) {
      map['target_snapshot'] = Variable<double>(targetSnapshot.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalorieDayCompanion(')
          ..write('date: $date, ')
          ..write('intake: $intake, ')
          ..write('targetSnapshot: $targetSnapshot, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramLogTable extends ProgramLog
    with TableInfo<$ProgramLogTable, ProgramLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, programId, volume];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}program_id'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      )!,
    );
  }

  @override
  $ProgramLogTable createAlias(String alias) {
    return $ProgramLogTable(attachedDatabase, alias);
  }
}

class ProgramLogData extends DataClass implements Insertable<ProgramLogData> {
  final int id;
  final String date;
  final int programId;
  final double volume;
  const ProgramLogData({
    required this.id,
    required this.date,
    required this.programId,
    required this.volume,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['program_id'] = Variable<int>(programId);
    map['volume'] = Variable<double>(volume);
    return map;
  }

  ProgramLogCompanion toCompanion(bool nullToAbsent) {
    return ProgramLogCompanion(
      id: Value(id),
      date: Value(date),
      programId: Value(programId),
      volume: Value(volume),
    );
  }

  factory ProgramLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramLogData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      programId: serializer.fromJson<int>(json['programId']),
      volume: serializer.fromJson<double>(json['volume']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'programId': serializer.toJson<int>(programId),
      'volume': serializer.toJson<double>(volume),
    };
  }

  ProgramLogData copyWith({
    int? id,
    String? date,
    int? programId,
    double? volume,
  }) => ProgramLogData(
    id: id ?? this.id,
    date: date ?? this.date,
    programId: programId ?? this.programId,
    volume: volume ?? this.volume,
  );
  ProgramLogData copyWithCompanion(ProgramLogCompanion data) {
    return ProgramLogData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      programId: data.programId.present ? data.programId.value : this.programId,
      volume: data.volume.present ? data.volume.value : this.volume,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramLogData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('programId: $programId, ')
          ..write('volume: $volume')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, programId, volume);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramLogData &&
          other.id == this.id &&
          other.date == this.date &&
          other.programId == this.programId &&
          other.volume == this.volume);
}

class ProgramLogCompanion extends UpdateCompanion<ProgramLogData> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> programId;
  final Value<double> volume;
  const ProgramLogCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.programId = const Value.absent(),
    this.volume = const Value.absent(),
  });
  ProgramLogCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required int programId,
    this.volume = const Value.absent(),
  }) : date = Value(date),
       programId = Value(programId);
  static Insertable<ProgramLogData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? programId,
    Expression<double>? volume,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (programId != null) 'program_id': programId,
      if (volume != null) 'volume': volume,
    });
  }

  ProgramLogCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? programId,
    Value<double>? volume,
  }) {
    return ProgramLogCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      programId: programId ?? this.programId,
      volume: volume ?? this.volume,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramLogCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('programId: $programId, ')
          ..write('volume: $volume')
          ..write(')'))
        .toString();
  }
}

class $ScreenTimeDayTable extends ScreenTimeDay
    with TableInfo<$ScreenTimeDayTable, ScreenTimeDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenTimeDayTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMinMeta = const VerificationMeta(
    'totalMin',
  );
  @override
  late final GeneratedColumn<int> totalMin = GeneratedColumn<int>(
    'total_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, totalMin, capturedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screen_time_day';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenTimeDayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_min')) {
      context.handle(
        _totalMinMeta,
        totalMin.isAcceptableOrUnknown(data['total_min']!, _totalMinMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  ScreenTimeDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenTimeDayData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      totalMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_min'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $ScreenTimeDayTable createAlias(String alias) {
    return $ScreenTimeDayTable(attachedDatabase, alias);
  }
}

class ScreenTimeDayData extends DataClass
    implements Insertable<ScreenTimeDayData> {
  final String date;
  final int totalMin;
  final int capturedAt;
  const ScreenTimeDayData({
    required this.date,
    required this.totalMin,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['total_min'] = Variable<int>(totalMin);
    map['captured_at'] = Variable<int>(capturedAt);
    return map;
  }

  ScreenTimeDayCompanion toCompanion(bool nullToAbsent) {
    return ScreenTimeDayCompanion(
      date: Value(date),
      totalMin: Value(totalMin),
      capturedAt: Value(capturedAt),
    );
  }

  factory ScreenTimeDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenTimeDayData(
      date: serializer.fromJson<String>(json['date']),
      totalMin: serializer.fromJson<int>(json['totalMin']),
      capturedAt: serializer.fromJson<int>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'totalMin': serializer.toJson<int>(totalMin),
      'capturedAt': serializer.toJson<int>(capturedAt),
    };
  }

  ScreenTimeDayData copyWith({String? date, int? totalMin, int? capturedAt}) =>
      ScreenTimeDayData(
        date: date ?? this.date,
        totalMin: totalMin ?? this.totalMin,
        capturedAt: capturedAt ?? this.capturedAt,
      );
  ScreenTimeDayData copyWithCompanion(ScreenTimeDayCompanion data) {
    return ScreenTimeDayData(
      date: data.date.present ? data.date.value : this.date,
      totalMin: data.totalMin.present ? data.totalMin.value : this.totalMin,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeDayData(')
          ..write('date: $date, ')
          ..write('totalMin: $totalMin, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, totalMin, capturedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenTimeDayData &&
          other.date == this.date &&
          other.totalMin == this.totalMin &&
          other.capturedAt == this.capturedAt);
}

class ScreenTimeDayCompanion extends UpdateCompanion<ScreenTimeDayData> {
  final Value<String> date;
  final Value<int> totalMin;
  final Value<int> capturedAt;
  final Value<int> rowid;
  const ScreenTimeDayCompanion({
    this.date = const Value.absent(),
    this.totalMin = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreenTimeDayCompanion.insert({
    required String date,
    this.totalMin = const Value.absent(),
    required int capturedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       capturedAt = Value(capturedAt);
  static Insertable<ScreenTimeDayData> custom({
    Expression<String>? date,
    Expression<int>? totalMin,
    Expression<int>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (totalMin != null) 'total_min': totalMin,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreenTimeDayCompanion copyWith({
    Value<String>? date,
    Value<int>? totalMin,
    Value<int>? capturedAt,
    Value<int>? rowid,
  }) {
    return ScreenTimeDayCompanion(
      date: date ?? this.date,
      totalMin: totalMin ?? this.totalMin,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (totalMin.present) {
      map['total_min'] = Variable<int>(totalMin.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeDayCompanion(')
          ..write('date: $date, ')
          ..write('totalMin: $totalMin, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreenTimeAppTable extends ScreenTimeApp
    with TableInfo<$ScreenTimeAppTable, ScreenTimeAppData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenTimeAppTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screen_time_day (date) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appLabelMeta = const VerificationMeta(
    'appLabel',
  );
  @override
  late final GeneratedColumn<String> appLabel = GeneratedColumn<String>(
    'app_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foregroundMinMeta = const VerificationMeta(
    'foregroundMin',
  );
  @override
  late final GeneratedColumn<int> foregroundMin = GeneratedColumn<int>(
    'foreground_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    packageName,
    appLabel,
    foregroundMin,
    rank,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screen_time_app';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenTimeAppData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_label')) {
      context.handle(
        _appLabelMeta,
        appLabel.isAcceptableOrUnknown(data['app_label']!, _appLabelMeta),
      );
    }
    if (data.containsKey('foreground_min')) {
      context.handle(
        _foregroundMinMeta,
        foregroundMin.isAcceptableOrUnknown(
          data['foreground_min']!,
          _foregroundMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foregroundMinMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, packageName},
  ];
  @override
  ScreenTimeAppData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenTimeAppData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_label'],
      ),
      foregroundMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreground_min'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
    );
  }

  @override
  $ScreenTimeAppTable createAlias(String alias) {
    return $ScreenTimeAppTable(attachedDatabase, alias);
  }
}

class ScreenTimeAppData extends DataClass
    implements Insertable<ScreenTimeAppData> {
  final int id;
  final String date;
  final String packageName;
  final String? appLabel;
  final int foregroundMin;
  final int rank;
  const ScreenTimeAppData({
    required this.id,
    required this.date,
    required this.packageName,
    this.appLabel,
    required this.foregroundMin,
    required this.rank,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['package_name'] = Variable<String>(packageName);
    if (!nullToAbsent || appLabel != null) {
      map['app_label'] = Variable<String>(appLabel);
    }
    map['foreground_min'] = Variable<int>(foregroundMin);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  ScreenTimeAppCompanion toCompanion(bool nullToAbsent) {
    return ScreenTimeAppCompanion(
      id: Value(id),
      date: Value(date),
      packageName: Value(packageName),
      appLabel: appLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(appLabel),
      foregroundMin: Value(foregroundMin),
      rank: Value(rank),
    );
  }

  factory ScreenTimeAppData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenTimeAppData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appLabel: serializer.fromJson<String?>(json['appLabel']),
      foregroundMin: serializer.fromJson<int>(json['foregroundMin']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'packageName': serializer.toJson<String>(packageName),
      'appLabel': serializer.toJson<String?>(appLabel),
      'foregroundMin': serializer.toJson<int>(foregroundMin),
      'rank': serializer.toJson<int>(rank),
    };
  }

  ScreenTimeAppData copyWith({
    int? id,
    String? date,
    String? packageName,
    Value<String?> appLabel = const Value.absent(),
    int? foregroundMin,
    int? rank,
  }) => ScreenTimeAppData(
    id: id ?? this.id,
    date: date ?? this.date,
    packageName: packageName ?? this.packageName,
    appLabel: appLabel.present ? appLabel.value : this.appLabel,
    foregroundMin: foregroundMin ?? this.foregroundMin,
    rank: rank ?? this.rank,
  );
  ScreenTimeAppData copyWithCompanion(ScreenTimeAppCompanion data) {
    return ScreenTimeAppData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appLabel: data.appLabel.present ? data.appLabel.value : this.appLabel,
      foregroundMin: data.foregroundMin.present
          ? data.foregroundMin.value
          : this.foregroundMin,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeAppData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('packageName: $packageName, ')
          ..write('appLabel: $appLabel, ')
          ..write('foregroundMin: $foregroundMin, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, packageName, appLabel, foregroundMin, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenTimeAppData &&
          other.id == this.id &&
          other.date == this.date &&
          other.packageName == this.packageName &&
          other.appLabel == this.appLabel &&
          other.foregroundMin == this.foregroundMin &&
          other.rank == this.rank);
}

class ScreenTimeAppCompanion extends UpdateCompanion<ScreenTimeAppData> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> packageName;
  final Value<String?> appLabel;
  final Value<int> foregroundMin;
  final Value<int> rank;
  const ScreenTimeAppCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appLabel = const Value.absent(),
    this.foregroundMin = const Value.absent(),
    this.rank = const Value.absent(),
  });
  ScreenTimeAppCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String packageName,
    this.appLabel = const Value.absent(),
    required int foregroundMin,
    required int rank,
  }) : date = Value(date),
       packageName = Value(packageName),
       foregroundMin = Value(foregroundMin),
       rank = Value(rank);
  static Insertable<ScreenTimeAppData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? packageName,
    Expression<String>? appLabel,
    Expression<int>? foregroundMin,
    Expression<int>? rank,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (packageName != null) 'package_name': packageName,
      if (appLabel != null) 'app_label': appLabel,
      if (foregroundMin != null) 'foreground_min': foregroundMin,
      if (rank != null) 'rank': rank,
    });
  }

  ScreenTimeAppCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? packageName,
    Value<String?>? appLabel,
    Value<int>? foregroundMin,
    Value<int>? rank,
  }) {
    return ScreenTimeAppCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      packageName: packageName ?? this.packageName,
      appLabel: appLabel ?? this.appLabel,
      foregroundMin: foregroundMin ?? this.foregroundMin,
      rank: rank ?? this.rank,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appLabel.present) {
      map['app_label'] = Variable<String>(appLabel.value);
    }
    if (foregroundMin.present) {
      map['foreground_min'] = Variable<int>(foregroundMin.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeAppCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('packageName: $packageName, ')
          ..write('appLabel: $appLabel, ')
          ..write('foregroundMin: $foregroundMin, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MetricsTable metrics = $MetricsTable(this);
  late final $MetricOptionsTable metricOptions = $MetricOptionsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $EntryOptionsTable entryOptions = $EntryOptionsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $MoneyCategoriesTable moneyCategories = $MoneyCategoriesTable(
    this,
  );
  late final $ExpenseRemindersTable expenseReminders = $ExpenseRemindersTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $HealthProfileTable healthProfile = $HealthProfileTable(this);
  late final $BodyLogTable bodyLog = $BodyLogTable(this);
  late final $HealthSamplesTable healthSamples = $HealthSamplesTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $SavedExerciseTitlesTable savedExerciseTitles =
      $SavedExerciseTitlesTable(this);
  late final $SavedFoodTypesTable savedFoodTypes = $SavedFoodTypesTable(this);
  late final $ProgramsTable programs = $ProgramsTable(this);
  late final $ProgramExercisesTable programExercises = $ProgramExercisesTable(
    this,
  );
  late final $CalorieEntriesTable calorieEntries = $CalorieEntriesTable(this);
  late final $CalorieDayTable calorieDay = $CalorieDayTable(this);
  late final $ProgramLogTable programLog = $ProgramLogTable(this);
  late final $ScreenTimeDayTable screenTimeDay = $ScreenTimeDayTable(this);
  late final $ScreenTimeAppTable screenTimeApp = $ScreenTimeAppTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    metrics,
    metricOptions,
    entries,
    entryOptions,
    transactions,
    moneyCategories,
    expenseReminders,
    appSettings,
    healthProfile,
    bodyLog,
    healthSamples,
    syncState,
    savedExerciseTitles,
    savedFoodTypes,
    programs,
    programExercises,
    calorieEntries,
    calorieDay,
    programLog,
    screenTimeDay,
    screenTimeApp,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metrics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('metrics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metrics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('metric_options', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metrics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_options', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metric_options',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_options', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expense_reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'programs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('program_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'programs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('program_log', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screen_time_day',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('screen_time_app', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MetricsTableCreateCompanionBuilder =
    MetricsCompanion Function({
      Value<int> id,
      Value<int?> parentId,
      required String key,
      required String title,
      required String inputType,
      Value<String?> prevInputType,
      Value<bool> isStarred,
      Value<int?> starredAt,
      Value<String?> heatmapLabel,
      Value<String?> heatmapRule,
      Value<int> sortOrder,
      Value<String?> unit,
      Value<bool> isDeletable,
      Value<String> groupDisplay,
      required int createdAt,
      required int updatedAt,
    });
typedef $$MetricsTableUpdateCompanionBuilder =
    MetricsCompanion Function({
      Value<int> id,
      Value<int?> parentId,
      Value<String> key,
      Value<String> title,
      Value<String> inputType,
      Value<String?> prevInputType,
      Value<bool> isStarred,
      Value<int?> starredAt,
      Value<String?> heatmapLabel,
      Value<String?> heatmapRule,
      Value<int> sortOrder,
      Value<String?> unit,
      Value<bool> isDeletable,
      Value<String> groupDisplay,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$MetricsTableReferences
    extends BaseReferences<_$AppDatabase, $MetricsTable, Metric> {
  $$MetricsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MetricsTable _parentIdTable(_$AppDatabase db) =>
      db.metrics.createAlias('metrics__parent_id__metrics__id');

  $$MetricsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$MetricsTableTableManager(
      $_db,
      $_db.metrics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MetricOptionsTable, List<MetricOption>>
  _metricOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.metricOptions,
    aliasName: 'metrics__id__metric_options__metric_id',
  );

  $$MetricOptionsTableProcessedTableManager get metricOptionsRefs {
    final manager = $$MetricOptionsTableTableManager(
      $_db,
      $_db.metricOptions,
    ).filter((f) => f.metricId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_metricOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'metrics__id__entries__metric_id',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.metricId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MetricsTableFilterComposer
    extends Composer<_$AppDatabase, $MetricsTable> {
  $$MetricsTableFilterComposer({
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputType => $composableBuilder(
    column: $table.inputType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevInputType => $composableBuilder(
    column: $table.prevInputType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heatmapLabel => $composableBuilder(
    column: $table.heatmapLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heatmapRule => $composableBuilder(
    column: $table.heatmapRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeletable => $composableBuilder(
    column: $table.isDeletable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupDisplay => $composableBuilder(
    column: $table.groupDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MetricsTableFilterComposer get parentId {
    final $$MetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableFilterComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> metricOptionsRefs(
    Expression<bool> Function($$MetricOptionsTableFilterComposer f) f,
  ) {
    final $$MetricOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.metricOptions,
      getReferencedColumn: (t) => t.metricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricOptionsTableFilterComposer(
            $db: $db,
            $table: $db.metricOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.metricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetricsTable> {
  $$MetricsTableOrderingComposer({
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputType => $composableBuilder(
    column: $table.inputType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevInputType => $composableBuilder(
    column: $table.prevInputType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get starredAt => $composableBuilder(
    column: $table.starredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heatmapLabel => $composableBuilder(
    column: $table.heatmapLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heatmapRule => $composableBuilder(
    column: $table.heatmapRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeletable => $composableBuilder(
    column: $table.isDeletable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupDisplay => $composableBuilder(
    column: $table.groupDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MetricsTableOrderingComposer get parentId {
    final $$MetricsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableOrderingComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetricsTable> {
  $$MetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get inputType =>
      $composableBuilder(column: $table.inputType, builder: (column) => column);

  GeneratedColumn<String> get prevInputType => $composableBuilder(
    column: $table.prevInputType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<int> get starredAt =>
      $composableBuilder(column: $table.starredAt, builder: (column) => column);

  GeneratedColumn<String> get heatmapLabel => $composableBuilder(
    column: $table.heatmapLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heatmapRule => $composableBuilder(
    column: $table.heatmapRule,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isDeletable => $composableBuilder(
    column: $table.isDeletable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupDisplay => $composableBuilder(
    column: $table.groupDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MetricsTableAnnotationComposer get parentId {
    final $$MetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> metricOptionsRefs<T extends Object>(
    Expression<T> Function($$MetricOptionsTableAnnotationComposer a) f,
  ) {
    final $$MetricOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.metricOptions,
      getReferencedColumn: (t) => t.metricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.metricOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.metricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetricsTable,
          Metric,
          $$MetricsTableFilterComposer,
          $$MetricsTableOrderingComposer,
          $$MetricsTableAnnotationComposer,
          $$MetricsTableCreateCompanionBuilder,
          $$MetricsTableUpdateCompanionBuilder,
          (Metric, $$MetricsTableReferences),
          Metric,
          PrefetchHooks Function({
            bool parentId,
            bool metricOptionsRefs,
            bool entriesRefs,
          })
        > {
  $$MetricsTableTableManager(_$AppDatabase db, $MetricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> inputType = const Value.absent(),
                Value<String?> prevInputType = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<int?> starredAt = const Value.absent(),
                Value<String?> heatmapLabel = const Value.absent(),
                Value<String?> heatmapRule = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<bool> isDeletable = const Value.absent(),
                Value<String> groupDisplay = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => MetricsCompanion(
                id: id,
                parentId: parentId,
                key: key,
                title: title,
                inputType: inputType,
                prevInputType: prevInputType,
                isStarred: isStarred,
                starredAt: starredAt,
                heatmapLabel: heatmapLabel,
                heatmapRule: heatmapRule,
                sortOrder: sortOrder,
                unit: unit,
                isDeletable: isDeletable,
                groupDisplay: groupDisplay,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                required String key,
                required String title,
                required String inputType,
                Value<String?> prevInputType = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<int?> starredAt = const Value.absent(),
                Value<String?> heatmapLabel = const Value.absent(),
                Value<String?> heatmapRule = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<bool> isDeletable = const Value.absent(),
                Value<String> groupDisplay = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => MetricsCompanion.insert(
                id: id,
                parentId: parentId,
                key: key,
                title: title,
                inputType: inputType,
                prevInputType: prevInputType,
                isStarred: isStarred,
                starredAt: starredAt,
                heatmapLabel: heatmapLabel,
                heatmapRule: heatmapRule,
                sortOrder: sortOrder,
                unit: unit,
                isDeletable: isDeletable,
                groupDisplay: groupDisplay,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MetricsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                metricOptionsRefs = false,
                entriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (metricOptionsRefs) db.metricOptions,
                    if (entriesRefs) db.entries,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: $$MetricsTableReferences
                                        ._parentIdTable(db),
                                    referencedColumn: $$MetricsTableReferences
                                        ._parentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (metricOptionsRefs)
                        await $_getPrefetchedData<
                          Metric,
                          $MetricsTable,
                          MetricOption
                        >(
                          currentTable: table,
                          referencedTable: $$MetricsTableReferences
                              ._metricOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MetricsTableReferences(
                                db,
                                table,
                                p0,
                              ).metricOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.metricId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entriesRefs)
                        await $_getPrefetchedData<Metric, $MetricsTable, Entry>(
                          currentTable: table,
                          referencedTable: $$MetricsTableReferences
                              ._entriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MetricsTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.metricId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetricsTable,
      Metric,
      $$MetricsTableFilterComposer,
      $$MetricsTableOrderingComposer,
      $$MetricsTableAnnotationComposer,
      $$MetricsTableCreateCompanionBuilder,
      $$MetricsTableUpdateCompanionBuilder,
      (Metric, $$MetricsTableReferences),
      Metric,
      PrefetchHooks Function({
        bool parentId,
        bool metricOptionsRefs,
        bool entriesRefs,
      })
    >;
typedef $$MetricOptionsTableCreateCompanionBuilder =
    MetricOptionsCompanion Function({
      Value<int> id,
      required int metricId,
      required String label,
      Value<int> sortOrder,
    });
typedef $$MetricOptionsTableUpdateCompanionBuilder =
    MetricOptionsCompanion Function({
      Value<int> id,
      Value<int> metricId,
      Value<String> label,
      Value<int> sortOrder,
    });

final class $$MetricOptionsTableReferences
    extends BaseReferences<_$AppDatabase, $MetricOptionsTable, MetricOption> {
  $$MetricOptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MetricsTable _metricIdTable(_$AppDatabase db) =>
      db.metrics.createAlias('metric_options__metric_id__metrics__id');

  $$MetricsTableProcessedTableManager get metricId {
    final $_column = $_itemColumn<int>('metric_id')!;

    final manager = $$MetricsTableTableManager(
      $_db,
      $_db.metrics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_metricIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntryOptionsTable, List<EntryOption>>
  _entryOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryOptions,
    aliasName: 'metric_options__id__entry_options__option_id',
  );

  $$EntryOptionsTableProcessedTableManager get entryOptionsRefs {
    final manager = $$EntryOptionsTableTableManager(
      $_db,
      $_db.entryOptions,
    ).filter((f) => f.optionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MetricOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $MetricOptionsTable> {
  $$MetricOptionsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$MetricsTableFilterComposer get metricId {
    final $$MetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metricId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableFilterComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entryOptionsRefs(
    Expression<bool> Function($$EntryOptionsTableFilterComposer f) f,
  ) {
    final $$EntryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.optionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MetricOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetricOptionsTable> {
  $$MetricOptionsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$MetricsTableOrderingComposer get metricId {
    final $$MetricsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metricId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableOrderingComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetricOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetricOptionsTable> {
  $$MetricOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$MetricsTableAnnotationComposer get metricId {
    final $$MetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metricId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entryOptionsRefs<T extends Object>(
    Expression<T> Function($$EntryOptionsTableAnnotationComposer a) f,
  ) {
    final $$EntryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.optionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MetricOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetricOptionsTable,
          MetricOption,
          $$MetricOptionsTableFilterComposer,
          $$MetricOptionsTableOrderingComposer,
          $$MetricOptionsTableAnnotationComposer,
          $$MetricOptionsTableCreateCompanionBuilder,
          $$MetricOptionsTableUpdateCompanionBuilder,
          (MetricOption, $$MetricOptionsTableReferences),
          MetricOption,
          PrefetchHooks Function({bool metricId, bool entryOptionsRefs})
        > {
  $$MetricOptionsTableTableManager(_$AppDatabase db, $MetricOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetricOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetricOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetricOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> metricId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MetricOptionsCompanion(
                id: id,
                metricId: metricId,
                label: label,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int metricId,
                required String label,
                Value<int> sortOrder = const Value.absent(),
              }) => MetricOptionsCompanion.insert(
                id: id,
                metricId: metricId,
                label: label,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MetricOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({metricId = false, entryOptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entryOptionsRefs) db.entryOptions,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (metricId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.metricId,
                                    referencedTable:
                                        $$MetricOptionsTableReferences
                                            ._metricIdTable(db),
                                    referencedColumn:
                                        $$MetricOptionsTableReferences
                                            ._metricIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entryOptionsRefs)
                        await $_getPrefetchedData<
                          MetricOption,
                          $MetricOptionsTable,
                          EntryOption
                        >(
                          currentTable: table,
                          referencedTable: $$MetricOptionsTableReferences
                              ._entryOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MetricOptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).entryOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.optionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MetricOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetricOptionsTable,
      MetricOption,
      $$MetricOptionsTableFilterComposer,
      $$MetricOptionsTableOrderingComposer,
      $$MetricOptionsTableAnnotationComposer,
      $$MetricOptionsTableCreateCompanionBuilder,
      $$MetricOptionsTableUpdateCompanionBuilder,
      (MetricOption, $$MetricOptionsTableReferences),
      MetricOption,
      PrefetchHooks Function({bool metricId, bool entryOptionsRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required int metricId,
      required String date,
      Value<double?> numValue,
      Value<String?> textValue,
      Value<String> valueSource,
      required int createdAt,
      required int updatedAt,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<int> metricId,
      Value<String> date,
      Value<double?> numValue,
      Value<String?> textValue,
      Value<String> valueSource,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MetricsTable _metricIdTable(_$AppDatabase db) =>
      db.metrics.createAlias('entries__metric_id__metrics__id');

  $$MetricsTableProcessedTableManager get metricId {
    final $_column = $_itemColumn<int>('metric_id')!;

    final manager = $$MetricsTableTableManager(
      $_db,
      $_db.metrics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_metricIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntryOptionsTable, List<EntryOption>>
  _entryOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryOptions,
    aliasName: 'entries__id__entry_options__entry_id',
  );

  $$EntryOptionsTableProcessedTableManager get entryOptionsRefs {
    final manager = $$EntryOptionsTableTableManager(
      $_db,
      $_db.entryOptions,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numValue => $composableBuilder(
    column: $table.numValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueSource => $composableBuilder(
    column: $table.valueSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MetricsTableFilterComposer get metricId {
    final $$MetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metricId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableFilterComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entryOptionsRefs(
    Expression<bool> Function($$EntryOptionsTableFilterComposer f) f,
  ) {
    final $$EntryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numValue => $composableBuilder(
    column: $table.numValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueSource => $composableBuilder(
    column: $table.valueSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MetricsTableOrderingComposer get metricId {
    final $$MetricsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metricId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableOrderingComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get numValue =>
      $composableBuilder(column: $table.numValue, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<String> get valueSource => $composableBuilder(
    column: $table.valueSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MetricsTableAnnotationComposer get metricId {
    final $$MetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.metricId,
      referencedTable: $db.metrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.metrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entryOptionsRefs<T extends Object>(
    Expression<T> Function($$EntryOptionsTableAnnotationComposer a) f,
  ) {
    final $$EntryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({bool metricId, bool entryOptionsRefs})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> metricId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double?> numValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<String> valueSource = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                metricId: metricId,
                date: date,
                numValue: numValue,
                textValue: textValue,
                valueSource: valueSource,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int metricId,
                required String date,
                Value<double?> numValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<String> valueSource = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => EntriesCompanion.insert(
                id: id,
                metricId: metricId,
                date: date,
                numValue: numValue,
                textValue: textValue,
                valueSource: valueSource,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({metricId = false, entryOptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entryOptionsRefs) db.entryOptions,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (metricId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.metricId,
                                    referencedTable: $$EntriesTableReferences
                                        ._metricIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._metricIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entryOptionsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          EntryOption
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._entryOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({bool metricId, bool entryOptionsRefs})
    >;
typedef $$EntryOptionsTableCreateCompanionBuilder =
    EntryOptionsCompanion Function({
      required int entryId,
      required int optionId,
      Value<int> rowid,
    });
typedef $$EntryOptionsTableUpdateCompanionBuilder =
    EntryOptionsCompanion Function({
      Value<int> entryId,
      Value<int> optionId,
      Value<int> rowid,
    });

final class $$EntryOptionsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryOptionsTable, EntryOption> {
  $$EntryOptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) =>
      db.entries.createAlias('entry_options__entry_id__entries__id');

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MetricOptionsTable _optionIdTable(_$AppDatabase db) => db
      .metricOptions
      .createAlias('entry_options__option_id__metric_options__id');

  $$MetricOptionsTableProcessedTableManager get optionId {
    final $_column = $_itemColumn<int>('option_id')!;

    final manager = $$MetricOptionsTableTableManager(
      $_db,
      $_db.metricOptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_optionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryOptionsTable> {
  $$EntryOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MetricOptionsTableFilterComposer get optionId {
    final $$MetricOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.optionId,
      referencedTable: $db.metricOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricOptionsTableFilterComposer(
            $db: $db,
            $table: $db.metricOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryOptionsTable> {
  $$EntryOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MetricOptionsTableOrderingComposer get optionId {
    final $$MetricOptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.optionId,
      referencedTable: $db.metricOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricOptionsTableOrderingComposer(
            $db: $db,
            $table: $db.metricOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryOptionsTable> {
  $$EntryOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MetricOptionsTableAnnotationComposer get optionId {
    final $$MetricOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.optionId,
      referencedTable: $db.metricOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetricOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.metricOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryOptionsTable,
          EntryOption,
          $$EntryOptionsTableFilterComposer,
          $$EntryOptionsTableOrderingComposer,
          $$EntryOptionsTableAnnotationComposer,
          $$EntryOptionsTableCreateCompanionBuilder,
          $$EntryOptionsTableUpdateCompanionBuilder,
          (EntryOption, $$EntryOptionsTableReferences),
          EntryOption,
          PrefetchHooks Function({bool entryId, bool optionId})
        > {
  $$EntryOptionsTableTableManager(_$AppDatabase db, $EntryOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> entryId = const Value.absent(),
                Value<int> optionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryOptionsCompanion(
                entryId: entryId,
                optionId: optionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int entryId,
                required int optionId,
                Value<int> rowid = const Value.absent(),
              }) => EntryOptionsCompanion.insert(
                entryId: entryId,
                optionId: optionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, optionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntryOptionsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$EntryOptionsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (optionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.optionId,
                                referencedTable: $$EntryOptionsTableReferences
                                    ._optionIdTable(db),
                                referencedColumn: $$EntryOptionsTableReferences
                                    ._optionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryOptionsTable,
      EntryOption,
      $$EntryOptionsTableFilterComposer,
      $$EntryOptionsTableOrderingComposer,
      $$EntryOptionsTableAnnotationComposer,
      $$EntryOptionsTableCreateCompanionBuilder,
      $$EntryOptionsTableUpdateCompanionBuilder,
      (EntryOption, $$EntryOptionsTableReferences),
      EntryOption,
      PrefetchHooks Function({bool entryId, bool optionId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required String date,
      required String direction,
      required double amount,
      required String category,
      Value<String?> subtype,
      Value<String?> note,
      required int createdAt,
      required int updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> direction,
      Value<double> amount,
      Value<String> category,
      Value<String?> subtype,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpenseRemindersTable, List<ExpenseReminder>>
  _expenseRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenseReminders,
    aliasName: 'transactions__id__expense_reminders__transaction_id',
  );

  $$ExpenseRemindersTableProcessedTableManager get expenseRemindersRefs {
    final manager = $$ExpenseRemindersTableTableManager(
      $_db,
      $_db.expenseReminders,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expenseRemindersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expenseRemindersRefs(
    Expression<bool> Function($$ExpenseRemindersTableFilterComposer f) f,
  ) {
    final $$ExpenseRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseReminders,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseRemindersTableFilterComposer(
            $db: $db,
            $table: $db.expenseReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> expenseRemindersRefs<T extends Object>(
    Expression<T> Function($$ExpenseRemindersTableAnnotationComposer a) f,
  ) {
    final $$ExpenseRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseReminders,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool expenseRemindersRefs})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                date: date,
                direction: direction,
                amount: amount,
                category: category,
                subtype: subtype,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String direction,
                required double amount,
                required String category,
                Value<String?> subtype = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => TransactionsCompanion.insert(
                id: id,
                date: date,
                direction: direction,
                amount: amount,
                category: category,
                subtype: subtype,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expenseRemindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expenseRemindersRefs) db.expenseReminders,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expenseRemindersRefs)
                    await $_getPrefetchedData<
                      Transaction,
                      $TransactionsTable,
                      ExpenseReminder
                    >(
                      currentTable: table,
                      referencedTable: $$TransactionsTableReferences
                          ._expenseRemindersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TransactionsTableReferences(
                            db,
                            table,
                            p0,
                          ).expenseRemindersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.transactionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool expenseRemindersRefs})
    >;
typedef $$MoneyCategoriesTableCreateCompanionBuilder =
    MoneyCategoriesCompanion Function({
      Value<int> id,
      required String direction,
      required String name,
      Value<bool> isEssential,
      Value<bool> countsInHeatmap,
      Value<int> sortOrder,
    });
typedef $$MoneyCategoriesTableUpdateCompanionBuilder =
    MoneyCategoriesCompanion Function({
      Value<int> id,
      Value<String> direction,
      Value<String> name,
      Value<bool> isEssential,
      Value<bool> countsInHeatmap,
      Value<int> sortOrder,
    });

class $$MoneyCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyCategoriesTable> {
  $$MoneyCategoriesTableFilterComposer({
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

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countsInHeatmap => $composableBuilder(
    column: $table.countsInHeatmap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoneyCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyCategoriesTable> {
  $$MoneyCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countsInHeatmap => $composableBuilder(
    column: $table.countsInHeatmap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoneyCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyCategoriesTable> {
  $$MoneyCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get countsInHeatmap => $composableBuilder(
    column: $table.countsInHeatmap,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$MoneyCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyCategoriesTable,
          MoneyCategory,
          $$MoneyCategoriesTableFilterComposer,
          $$MoneyCategoriesTableOrderingComposer,
          $$MoneyCategoriesTableAnnotationComposer,
          $$MoneyCategoriesTableCreateCompanionBuilder,
          $$MoneyCategoriesTableUpdateCompanionBuilder,
          (
            MoneyCategory,
            BaseReferences<_$AppDatabase, $MoneyCategoriesTable, MoneyCategory>,
          ),
          MoneyCategory,
          PrefetchHooks Function()
        > {
  $$MoneyCategoriesTableTableManager(
    _$AppDatabase db,
    $MoneyCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<bool> countsInHeatmap = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MoneyCategoriesCompanion(
                id: id,
                direction: direction,
                name: name,
                isEssential: isEssential,
                countsInHeatmap: countsInHeatmap,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String direction,
                required String name,
                Value<bool> isEssential = const Value.absent(),
                Value<bool> countsInHeatmap = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MoneyCategoriesCompanion.insert(
                id: id,
                direction: direction,
                name: name,
                isEssential: isEssential,
                countsInHeatmap: countsInHeatmap,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoneyCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyCategoriesTable,
      MoneyCategory,
      $$MoneyCategoriesTableFilterComposer,
      $$MoneyCategoriesTableOrderingComposer,
      $$MoneyCategoriesTableAnnotationComposer,
      $$MoneyCategoriesTableCreateCompanionBuilder,
      $$MoneyCategoriesTableUpdateCompanionBuilder,
      (
        MoneyCategory,
        BaseReferences<_$AppDatabase, $MoneyCategoriesTable, MoneyCategory>,
      ),
      MoneyCategory,
      PrefetchHooks Function()
    >;
typedef $$ExpenseRemindersTableCreateCompanionBuilder =
    ExpenseRemindersCompanion Function({
      Value<int> id,
      required int transactionId,
      required String remindDate,
      Value<bool> fired,
    });
typedef $$ExpenseRemindersTableUpdateCompanionBuilder =
    ExpenseRemindersCompanion Function({
      Value<int> id,
      Value<int> transactionId,
      Value<String> remindDate,
      Value<bool> fired,
    });

final class $$ExpenseRemindersTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExpenseRemindersTable, ExpenseReminder> {
  $$ExpenseRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('expense_reminders__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpenseRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseRemindersTable> {
  $$ExpenseRemindersTableFilterComposer({
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

  ColumnFilters<String> get remindDate => $composableBuilder(
    column: $table.remindDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fired => $composableBuilder(
    column: $table.fired,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseRemindersTable> {
  $$ExpenseRemindersTableOrderingComposer({
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

  ColumnOrderings<String> get remindDate => $composableBuilder(
    column: $table.remindDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fired => $composableBuilder(
    column: $table.fired,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseRemindersTable> {
  $$ExpenseRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remindDate => $composableBuilder(
    column: $table.remindDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fired =>
      $composableBuilder(column: $table.fired, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseRemindersTable,
          ExpenseReminder,
          $$ExpenseRemindersTableFilterComposer,
          $$ExpenseRemindersTableOrderingComposer,
          $$ExpenseRemindersTableAnnotationComposer,
          $$ExpenseRemindersTableCreateCompanionBuilder,
          $$ExpenseRemindersTableUpdateCompanionBuilder,
          (ExpenseReminder, $$ExpenseRemindersTableReferences),
          ExpenseReminder,
          PrefetchHooks Function({bool transactionId})
        > {
  $$ExpenseRemindersTableTableManager(
    _$AppDatabase db,
    $ExpenseRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<String> remindDate = const Value.absent(),
                Value<bool> fired = const Value.absent(),
              }) => ExpenseRemindersCompanion(
                id: id,
                transactionId: transactionId,
                remindDate: remindDate,
                fired: fired,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transactionId,
                required String remindDate,
                Value<bool> fired = const Value.absent(),
              }) => ExpenseRemindersCompanion.insert(
                id: id,
                transactionId: transactionId,
                remindDate: remindDate,
                fired: fired,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpenseRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$ExpenseRemindersTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$ExpenseRemindersTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpenseRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseRemindersTable,
      ExpenseReminder,
      $$ExpenseRemindersTableFilterComposer,
      $$ExpenseRemindersTableOrderingComposer,
      $$ExpenseRemindersTableAnnotationComposer,
      $$ExpenseRemindersTableCreateCompanionBuilder,
      $$ExpenseRemindersTableUpdateCompanionBuilder,
      (ExpenseReminder, $$ExpenseRemindersTableReferences),
      ExpenseReminder,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$HealthProfileTableCreateCompanionBuilder =
    HealthProfileCompanion Function({
      Value<int> id,
      Value<String?> birthDate,
      Value<String?> sex,
      Value<double?> heightCm,
      Value<String?> activityLevel,
      required int updatedAt,
    });
typedef $$HealthProfileTableUpdateCompanionBuilder =
    HealthProfileCompanion Function({
      Value<int> id,
      Value<String?> birthDate,
      Value<String?> sex,
      Value<double?> heightCm,
      Value<String?> activityLevel,
      Value<int> updatedAt,
    });

class $$HealthProfileTableFilterComposer
    extends Composer<_$AppDatabase, $HealthProfileTable> {
  $$HealthProfileTableFilterComposer({
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

  ColumnFilters<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthProfileTable> {
  $$HealthProfileTableOrderingComposer({
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

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthProfileTable> {
  $$HealthProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HealthProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthProfileTable,
          HealthProfileData,
          $$HealthProfileTableFilterComposer,
          $$HealthProfileTableOrderingComposer,
          $$HealthProfileTableAnnotationComposer,
          $$HealthProfileTableCreateCompanionBuilder,
          $$HealthProfileTableUpdateCompanionBuilder,
          (
            HealthProfileData,
            BaseReferences<
              _$AppDatabase,
              $HealthProfileTable,
              HealthProfileData
            >,
          ),
          HealthProfileData,
          PrefetchHooks Function()
        > {
  $$HealthProfileTableTableManager(_$AppDatabase db, $HealthProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => HealthProfileCompanion(
                id: id,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                activityLevel: activityLevel,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                required int updatedAt,
              }) => HealthProfileCompanion.insert(
                id: id,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                activityLevel: activityLevel,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthProfileTable,
      HealthProfileData,
      $$HealthProfileTableFilterComposer,
      $$HealthProfileTableOrderingComposer,
      $$HealthProfileTableAnnotationComposer,
      $$HealthProfileTableCreateCompanionBuilder,
      $$HealthProfileTableUpdateCompanionBuilder,
      (
        HealthProfileData,
        BaseReferences<_$AppDatabase, $HealthProfileTable, HealthProfileData>,
      ),
      HealthProfileData,
      PrefetchHooks Function()
    >;
typedef $$BodyLogTableCreateCompanionBuilder =
    BodyLogCompanion Function({
      Value<int> id,
      required String date,
      Value<double?> weightKg,
      Value<double?> bodyFatPct,
      required int createdAt,
      required int updatedAt,
    });
typedef $$BodyLogTableUpdateCompanionBuilder =
    BodyLogCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<double?> weightKg,
      Value<double?> bodyFatPct,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

class $$BodyLogTableFilterComposer
    extends Composer<_$AppDatabase, $BodyLogTable> {
  $$BodyLogTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyLogTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyLogTable> {
  $$BodyLogTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyLogTable> {
  $$BodyLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BodyLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyLogTable,
          BodyLogData,
          $$BodyLogTableFilterComposer,
          $$BodyLogTableOrderingComposer,
          $$BodyLogTableAnnotationComposer,
          $$BodyLogTableCreateCompanionBuilder,
          $$BodyLogTableUpdateCompanionBuilder,
          (
            BodyLogData,
            BaseReferences<_$AppDatabase, $BodyLogTable, BodyLogData>,
          ),
          BodyLogData,
          PrefetchHooks Function()
        > {
  $$BodyLogTableTableManager(_$AppDatabase db, $BodyLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => BodyLogCompanion(
                id: id,
                date: date,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => BodyLogCompanion.insert(
                id: id,
                date: date,
                weightKg: weightKg,
                bodyFatPct: bodyFatPct,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyLogTable,
      BodyLogData,
      $$BodyLogTableFilterComposer,
      $$BodyLogTableOrderingComposer,
      $$BodyLogTableAnnotationComposer,
      $$BodyLogTableCreateCompanionBuilder,
      $$BodyLogTableUpdateCompanionBuilder,
      (BodyLogData, BaseReferences<_$AppDatabase, $BodyLogTable, BodyLogData>),
      BodyLogData,
      PrefetchHooks Function()
    >;
typedef $$HealthSamplesTableCreateCompanionBuilder =
    HealthSamplesCompanion Function({
      required String date,
      required String kind,
      Value<double?> value,
      Value<String?> valueText,
      required String source,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$HealthSamplesTableUpdateCompanionBuilder =
    HealthSamplesCompanion Function({
      Value<String> date,
      Value<String> kind,
      Value<double?> value,
      Value<String?> valueText,
      Value<String> source,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$HealthSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthSamplesTable> {
  $$HealthSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthSamplesTable> {
  $$HealthSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthSamplesTable> {
  $$HealthSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$HealthSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthSamplesTable,
          HealthSample,
          $$HealthSamplesTableFilterComposer,
          $$HealthSamplesTableOrderingComposer,
          $$HealthSamplesTableAnnotationComposer,
          $$HealthSamplesTableCreateCompanionBuilder,
          $$HealthSamplesTableUpdateCompanionBuilder,
          (
            HealthSample,
            BaseReferences<_$AppDatabase, $HealthSamplesTable, HealthSample>,
          ),
          HealthSample,
          PrefetchHooks Function()
        > {
  $$HealthSamplesTableTableManager(_$AppDatabase db, $HealthSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double?> value = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthSamplesCompanion(
                date: date,
                kind: kind,
                value: value,
                valueText: valueText,
                source: source,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String kind,
                Value<double?> value = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                required String source,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => HealthSamplesCompanion.insert(
                date: date,
                kind: kind,
                value: value,
                valueText: valueText,
                source: source,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthSamplesTable,
      HealthSample,
      $$HealthSamplesTableFilterComposer,
      $$HealthSamplesTableOrderingComposer,
      $$HealthSamplesTableAnnotationComposer,
      $$HealthSamplesTableCreateCompanionBuilder,
      $$HealthSamplesTableUpdateCompanionBuilder,
      (
        HealthSample,
        BaseReferences<_$AppDatabase, $HealthSamplesTable, HealthSample>,
      ),
      HealthSample,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String source,
      Value<int?> lastSync,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> source,
      Value<int?> lastSync,
      Value<int> rowid,
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
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSync => $composableBuilder(
    column: $table.lastSync,
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
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSync => $composableBuilder(
    column: $table.lastSync,
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
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);
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
                Value<String> source = const Value.absent(),
                Value<int?> lastSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                source: source,
                lastSync: lastSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                Value<int?> lastSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                source: source,
                lastSync: lastSync,
                rowid: rowid,
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
typedef $$SavedExerciseTitlesTableCreateCompanionBuilder =
    SavedExerciseTitlesCompanion Function({
      required String name,
      Value<int> rowid,
    });
typedef $$SavedExerciseTitlesTableUpdateCompanionBuilder =
    SavedExerciseTitlesCompanion Function({
      Value<String> name,
      Value<int> rowid,
    });

class $$SavedExerciseTitlesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedExerciseTitlesTable> {
  $$SavedExerciseTitlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedExerciseTitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedExerciseTitlesTable> {
  $$SavedExerciseTitlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedExerciseTitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedExerciseTitlesTable> {
  $$SavedExerciseTitlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$SavedExerciseTitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedExerciseTitlesTable,
          SavedExerciseTitle,
          $$SavedExerciseTitlesTableFilterComposer,
          $$SavedExerciseTitlesTableOrderingComposer,
          $$SavedExerciseTitlesTableAnnotationComposer,
          $$SavedExerciseTitlesTableCreateCompanionBuilder,
          $$SavedExerciseTitlesTableUpdateCompanionBuilder,
          (
            SavedExerciseTitle,
            BaseReferences<
              _$AppDatabase,
              $SavedExerciseTitlesTable,
              SavedExerciseTitle
            >,
          ),
          SavedExerciseTitle,
          PrefetchHooks Function()
        > {
  $$SavedExerciseTitlesTableTableManager(
    _$AppDatabase db,
    $SavedExerciseTitlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedExerciseTitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedExerciseTitlesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavedExerciseTitlesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedExerciseTitlesCompanion(name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                Value<int> rowid = const Value.absent(),
              }) =>
                  SavedExerciseTitlesCompanion.insert(name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedExerciseTitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedExerciseTitlesTable,
      SavedExerciseTitle,
      $$SavedExerciseTitlesTableFilterComposer,
      $$SavedExerciseTitlesTableOrderingComposer,
      $$SavedExerciseTitlesTableAnnotationComposer,
      $$SavedExerciseTitlesTableCreateCompanionBuilder,
      $$SavedExerciseTitlesTableUpdateCompanionBuilder,
      (
        SavedExerciseTitle,
        BaseReferences<
          _$AppDatabase,
          $SavedExerciseTitlesTable,
          SavedExerciseTitle
        >,
      ),
      SavedExerciseTitle,
      PrefetchHooks Function()
    >;
typedef $$SavedFoodTypesTableCreateCompanionBuilder =
    SavedFoodTypesCompanion Function({
      required String name,
      Value<bool> isBuiltin,
      Value<int> rowid,
    });
typedef $$SavedFoodTypesTableUpdateCompanionBuilder =
    SavedFoodTypesCompanion Function({
      Value<String> name,
      Value<bool> isBuiltin,
      Value<int> rowid,
    });

class $$SavedFoodTypesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedFoodTypesTable> {
  $$SavedFoodTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedFoodTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedFoodTypesTable> {
  $$SavedFoodTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedFoodTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedFoodTypesTable> {
  $$SavedFoodTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);
}

class $$SavedFoodTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedFoodTypesTable,
          SavedFoodType,
          $$SavedFoodTypesTableFilterComposer,
          $$SavedFoodTypesTableOrderingComposer,
          $$SavedFoodTypesTableAnnotationComposer,
          $$SavedFoodTypesTableCreateCompanionBuilder,
          $$SavedFoodTypesTableUpdateCompanionBuilder,
          (
            SavedFoodType,
            BaseReferences<_$AppDatabase, $SavedFoodTypesTable, SavedFoodType>,
          ),
          SavedFoodType,
          PrefetchHooks Function()
        > {
  $$SavedFoodTypesTableTableManager(
    _$AppDatabase db,
    $SavedFoodTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedFoodTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedFoodTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedFoodTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFoodTypesCompanion(
                name: name,
                isBuiltin: isBuiltin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<bool> isBuiltin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFoodTypesCompanion.insert(
                name: name,
                isBuiltin: isBuiltin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedFoodTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedFoodTypesTable,
      SavedFoodType,
      $$SavedFoodTypesTableFilterComposer,
      $$SavedFoodTypesTableOrderingComposer,
      $$SavedFoodTypesTableAnnotationComposer,
      $$SavedFoodTypesTableCreateCompanionBuilder,
      $$SavedFoodTypesTableUpdateCompanionBuilder,
      (
        SavedFoodType,
        BaseReferences<_$AppDatabase, $SavedFoodTypesTable, SavedFoodType>,
      ),
      SavedFoodType,
      PrefetchHooks Function()
    >;
typedef $$ProgramsTableCreateCompanionBuilder =
    ProgramsCompanion Function({
      Value<int> id,
      required String name,
      required int createdAt,
      Value<int> sortOrder,
    });
typedef $$ProgramsTableUpdateCompanionBuilder =
    ProgramsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> sortOrder,
    });

final class $$ProgramsTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramsTable, Program> {
  $$ProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProgramExercisesTable, List<ProgramExercise>>
  _programExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.programExercises,
    aliasName: 'programs__id__program_exercises__program_id',
  );

  $$ProgramExercisesTableProcessedTableManager get programExercisesRefs {
    final manager = $$ProgramExercisesTableTableManager(
      $_db,
      $_db.programExercises,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProgramLogTable, List<ProgramLogData>>
  _programLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.programLog,
    aliasName: 'programs__id__program_log__program_id',
  );

  $$ProgramLogTableProcessedTableManager get programLogRefs {
    final manager = $$ProgramLogTableTableManager(
      $_db,
      $_db.programLog,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_programLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> programExercisesRefs(
    Expression<bool> Function($$ProgramExercisesTableFilterComposer f) f,
  ) {
    final $$ProgramExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programExercises,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramExercisesTableFilterComposer(
            $db: $db,
            $table: $db.programExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programLogRefs(
    Expression<bool> Function($$ProgramLogTableFilterComposer f) f,
  ) {
    final $$ProgramLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programLog,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramLogTableFilterComposer(
            $db: $db,
            $table: $db.programLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> programExercisesRefs<T extends Object>(
    Expression<T> Function($$ProgramExercisesTableAnnotationComposer a) f,
  ) {
    final $$ProgramExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programExercises,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.programExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programLogRefs<T extends Object>(
    Expression<T> Function($$ProgramLogTableAnnotationComposer a) f,
  ) {
    final $$ProgramLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programLog,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramLogTableAnnotationComposer(
            $db: $db,
            $table: $db.programLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramsTable,
          Program,
          $$ProgramsTableFilterComposer,
          $$ProgramsTableOrderingComposer,
          $$ProgramsTableAnnotationComposer,
          $$ProgramsTableCreateCompanionBuilder,
          $$ProgramsTableUpdateCompanionBuilder,
          (Program, $$ProgramsTableReferences),
          Program,
          PrefetchHooks Function({
            bool programExercisesRefs,
            bool programLogRefs,
          })
        > {
  $$ProgramsTableTableManager(_$AppDatabase db, $ProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ProgramsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int createdAt,
                Value<int> sortOrder = const Value.absent(),
              }) => ProgramsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({programExercisesRefs = false, programLogRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (programExercisesRefs) db.programExercises,
                    if (programLogRefs) db.programLog,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (programExercisesRefs)
                        await $_getPrefetchedData<
                          Program,
                          $ProgramsTable,
                          ProgramExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ProgramsTableReferences
                              ._programExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProgramsTableReferences(
                                db,
                                table,
                                p0,
                              ).programExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.programId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (programLogRefs)
                        await $_getPrefetchedData<
                          Program,
                          $ProgramsTable,
                          ProgramLogData
                        >(
                          currentTable: table,
                          referencedTable: $$ProgramsTableReferences
                              ._programLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProgramsTableReferences(
                                db,
                                table,
                                p0,
                              ).programLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.programId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramsTable,
      Program,
      $$ProgramsTableFilterComposer,
      $$ProgramsTableOrderingComposer,
      $$ProgramsTableAnnotationComposer,
      $$ProgramsTableCreateCompanionBuilder,
      $$ProgramsTableUpdateCompanionBuilder,
      (Program, $$ProgramsTableReferences),
      Program,
      PrefetchHooks Function({bool programExercisesRefs, bool programLogRefs})
    >;
typedef $$ProgramExercisesTableCreateCompanionBuilder =
    ProgramExercisesCompanion Function({
      Value<int> id,
      required int programId,
      required String name,
      Value<String?> sets,
      Value<String?> duration,
      Value<bool> restAfter,
      Value<int?> supersetGroup,
      Value<int?> supersetRounds,
      Value<int> sortOrder,
    });
typedef $$ProgramExercisesTableUpdateCompanionBuilder =
    ProgramExercisesCompanion Function({
      Value<int> id,
      Value<int> programId,
      Value<String> name,
      Value<String?> sets,
      Value<String?> duration,
      Value<bool> restAfter,
      Value<int?> supersetGroup,
      Value<int?> supersetRounds,
      Value<int> sortOrder,
    });

final class $$ProgramExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProgramExercisesTable, ProgramExercise> {
  $$ProgramExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias('program_exercises__program_id__programs__id');

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramExercisesTable> {
  $$ProgramExercisesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restAfter => $composableBuilder(
    column: $table.restAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetRounds => $composableBuilder(
    column: $table.supersetRounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramExercisesTable> {
  $$ProgramExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restAfter => $composableBuilder(
    column: $table.restAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetRounds => $composableBuilder(
    column: $table.supersetRounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramExercisesTable> {
  $$ProgramExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get restAfter =>
      $composableBuilder(column: $table.restAfter, builder: (column) => column);

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supersetRounds => $composableBuilder(
    column: $table.supersetRounds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramExercisesTable,
          ProgramExercise,
          $$ProgramExercisesTableFilterComposer,
          $$ProgramExercisesTableOrderingComposer,
          $$ProgramExercisesTableAnnotationComposer,
          $$ProgramExercisesTableCreateCompanionBuilder,
          $$ProgramExercisesTableUpdateCompanionBuilder,
          (ProgramExercise, $$ProgramExercisesTableReferences),
          ProgramExercise,
          PrefetchHooks Function({bool programId})
        > {
  $$ProgramExercisesTableTableManager(
    _$AppDatabase db,
    $ProgramExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sets = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<bool> restAfter = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int?> supersetRounds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ProgramExercisesCompanion(
                id: id,
                programId: programId,
                name: name,
                sets: sets,
                duration: duration,
                restAfter: restAfter,
                supersetGroup: supersetGroup,
                supersetRounds: supersetRounds,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int programId,
                required String name,
                Value<String?> sets = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<bool> restAfter = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int?> supersetRounds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ProgramExercisesCompanion.insert(
                id: id,
                programId: programId,
                name: name,
                sets: sets,
                duration: duration,
                restAfter: restAfter,
                supersetGroup: supersetGroup,
                supersetRounds: supersetRounds,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({programId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (programId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.programId,
                                referencedTable:
                                    $$ProgramExercisesTableReferences
                                        ._programIdTable(db),
                                referencedColumn:
                                    $$ProgramExercisesTableReferences
                                        ._programIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProgramExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramExercisesTable,
      ProgramExercise,
      $$ProgramExercisesTableFilterComposer,
      $$ProgramExercisesTableOrderingComposer,
      $$ProgramExercisesTableAnnotationComposer,
      $$ProgramExercisesTableCreateCompanionBuilder,
      $$ProgramExercisesTableUpdateCompanionBuilder,
      (ProgramExercise, $$ProgramExercisesTableReferences),
      ProgramExercise,
      PrefetchHooks Function({bool programId})
    >;
typedef $$CalorieEntriesTableCreateCompanionBuilder =
    CalorieEntriesCompanion Function({
      Value<int> id,
      required String date,
      Value<String?> meal,
      required double kcal,
      required String type,
      required int createdAt,
    });
typedef $$CalorieEntriesTableUpdateCompanionBuilder =
    CalorieEntriesCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String?> meal,
      Value<double> kcal,
      Value<String> type,
      Value<int> createdAt,
    });

class $$CalorieEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CalorieEntriesTable> {
  $$CalorieEntriesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalorieEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CalorieEntriesTable> {
  $$CalorieEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalorieEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalorieEntriesTable> {
  $$CalorieEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CalorieEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalorieEntriesTable,
          CalorieEntry,
          $$CalorieEntriesTableFilterComposer,
          $$CalorieEntriesTableOrderingComposer,
          $$CalorieEntriesTableAnnotationComposer,
          $$CalorieEntriesTableCreateCompanionBuilder,
          $$CalorieEntriesTableUpdateCompanionBuilder,
          (
            CalorieEntry,
            BaseReferences<_$AppDatabase, $CalorieEntriesTable, CalorieEntry>,
          ),
          CalorieEntry,
          PrefetchHooks Function()
        > {
  $$CalorieEntriesTableTableManager(
    _$AppDatabase db,
    $CalorieEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalorieEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalorieEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalorieEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> meal = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => CalorieEntriesCompanion(
                id: id,
                date: date,
                meal: meal,
                kcal: kcal,
                type: type,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<String?> meal = const Value.absent(),
                required double kcal,
                required String type,
                required int createdAt,
              }) => CalorieEntriesCompanion.insert(
                id: id,
                date: date,
                meal: meal,
                kcal: kcal,
                type: type,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalorieEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalorieEntriesTable,
      CalorieEntry,
      $$CalorieEntriesTableFilterComposer,
      $$CalorieEntriesTableOrderingComposer,
      $$CalorieEntriesTableAnnotationComposer,
      $$CalorieEntriesTableCreateCompanionBuilder,
      $$CalorieEntriesTableUpdateCompanionBuilder,
      (
        CalorieEntry,
        BaseReferences<_$AppDatabase, $CalorieEntriesTable, CalorieEntry>,
      ),
      CalorieEntry,
      PrefetchHooks Function()
    >;
typedef $$CalorieDayTableCreateCompanionBuilder =
    CalorieDayCompanion Function({
      required String date,
      Value<double> intake,
      Value<double?> targetSnapshot,
      Value<String?> color,
      Value<int> rowid,
    });
typedef $$CalorieDayTableUpdateCompanionBuilder =
    CalorieDayCompanion Function({
      Value<String> date,
      Value<double> intake,
      Value<double?> targetSnapshot,
      Value<String?> color,
      Value<int> rowid,
    });

class $$CalorieDayTableFilterComposer
    extends Composer<_$AppDatabase, $CalorieDayTable> {
  $$CalorieDayTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intake => $composableBuilder(
    column: $table.intake,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalorieDayTableOrderingComposer
    extends Composer<_$AppDatabase, $CalorieDayTable> {
  $$CalorieDayTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intake => $composableBuilder(
    column: $table.intake,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalorieDayTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalorieDayTable> {
  $$CalorieDayTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get intake =>
      $composableBuilder(column: $table.intake, builder: (column) => column);

  GeneratedColumn<double> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$CalorieDayTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalorieDayTable,
          CalorieDayData,
          $$CalorieDayTableFilterComposer,
          $$CalorieDayTableOrderingComposer,
          $$CalorieDayTableAnnotationComposer,
          $$CalorieDayTableCreateCompanionBuilder,
          $$CalorieDayTableUpdateCompanionBuilder,
          (
            CalorieDayData,
            BaseReferences<_$AppDatabase, $CalorieDayTable, CalorieDayData>,
          ),
          CalorieDayData,
          PrefetchHooks Function()
        > {
  $$CalorieDayTableTableManager(_$AppDatabase db, $CalorieDayTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalorieDayTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalorieDayTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalorieDayTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<double> intake = const Value.absent(),
                Value<double?> targetSnapshot = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalorieDayCompanion(
                date: date,
                intake: intake,
                targetSnapshot: targetSnapshot,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<double> intake = const Value.absent(),
                Value<double?> targetSnapshot = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalorieDayCompanion.insert(
                date: date,
                intake: intake,
                targetSnapshot: targetSnapshot,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalorieDayTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalorieDayTable,
      CalorieDayData,
      $$CalorieDayTableFilterComposer,
      $$CalorieDayTableOrderingComposer,
      $$CalorieDayTableAnnotationComposer,
      $$CalorieDayTableCreateCompanionBuilder,
      $$CalorieDayTableUpdateCompanionBuilder,
      (
        CalorieDayData,
        BaseReferences<_$AppDatabase, $CalorieDayTable, CalorieDayData>,
      ),
      CalorieDayData,
      PrefetchHooks Function()
    >;
typedef $$ProgramLogTableCreateCompanionBuilder =
    ProgramLogCompanion Function({
      Value<int> id,
      required String date,
      required int programId,
      Value<double> volume,
    });
typedef $$ProgramLogTableUpdateCompanionBuilder =
    ProgramLogCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> programId,
      Value<double> volume,
    });

final class $$ProgramLogTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramLogTable, ProgramLogData> {
  $$ProgramLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias('program_log__program_id__programs__id');

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramLogTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramLogTable> {
  $$ProgramLogTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramLogTable> {
  $$ProgramLogTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramLogTable> {
  $$ProgramLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramLogTable,
          ProgramLogData,
          $$ProgramLogTableFilterComposer,
          $$ProgramLogTableOrderingComposer,
          $$ProgramLogTableAnnotationComposer,
          $$ProgramLogTableCreateCompanionBuilder,
          $$ProgramLogTableUpdateCompanionBuilder,
          (ProgramLogData, $$ProgramLogTableReferences),
          ProgramLogData,
          PrefetchHooks Function({bool programId})
        > {
  $$ProgramLogTableTableManager(_$AppDatabase db, $ProgramLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<double> volume = const Value.absent(),
              }) => ProgramLogCompanion(
                id: id,
                date: date,
                programId: programId,
                volume: volume,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required int programId,
                Value<double> volume = const Value.absent(),
              }) => ProgramLogCompanion.insert(
                id: id,
                date: date,
                programId: programId,
                volume: volume,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({programId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (programId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.programId,
                                referencedTable: $$ProgramLogTableReferences
                                    ._programIdTable(db),
                                referencedColumn: $$ProgramLogTableReferences
                                    ._programIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProgramLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramLogTable,
      ProgramLogData,
      $$ProgramLogTableFilterComposer,
      $$ProgramLogTableOrderingComposer,
      $$ProgramLogTableAnnotationComposer,
      $$ProgramLogTableCreateCompanionBuilder,
      $$ProgramLogTableUpdateCompanionBuilder,
      (ProgramLogData, $$ProgramLogTableReferences),
      ProgramLogData,
      PrefetchHooks Function({bool programId})
    >;
typedef $$ScreenTimeDayTableCreateCompanionBuilder =
    ScreenTimeDayCompanion Function({
      required String date,
      Value<int> totalMin,
      required int capturedAt,
      Value<int> rowid,
    });
typedef $$ScreenTimeDayTableUpdateCompanionBuilder =
    ScreenTimeDayCompanion Function({
      Value<String> date,
      Value<int> totalMin,
      Value<int> capturedAt,
      Value<int> rowid,
    });

final class $$ScreenTimeDayTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScreenTimeDayTable, ScreenTimeDayData> {
  $$ScreenTimeDayTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ScreenTimeAppTable, List<ScreenTimeAppData>>
  _screenTimeAppRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.screenTimeApp,
    aliasName: 'screen_time_day__date__screen_time_app__date',
  );

  $$ScreenTimeAppTableProcessedTableManager get screenTimeAppRefs {
    final manager = $$ScreenTimeAppTableTableManager(
      $_db,
      $_db.screenTimeApp,
    ).filter((f) => f.date.date.sqlEquals($_itemColumn<String>('date')!));

    final cache = $_typedResult.readTableOrNull(_screenTimeAppRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScreenTimeDayTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenTimeDayTable> {
  $$ScreenTimeDayTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMin => $composableBuilder(
    column: $table.totalMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> screenTimeAppRefs(
    Expression<bool> Function($$ScreenTimeAppTableFilterComposer f) f,
  ) {
    final $$ScreenTimeAppTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.screenTimeApp,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenTimeAppTableFilterComposer(
            $db: $db,
            $table: $db.screenTimeApp,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScreenTimeDayTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenTimeDayTable> {
  $$ScreenTimeDayTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMin => $composableBuilder(
    column: $table.totalMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreenTimeDayTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenTimeDayTable> {
  $$ScreenTimeDayTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalMin =>
      $composableBuilder(column: $table.totalMin, builder: (column) => column);

  GeneratedColumn<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  Expression<T> screenTimeAppRefs<T extends Object>(
    Expression<T> Function($$ScreenTimeAppTableAnnotationComposer a) f,
  ) {
    final $$ScreenTimeAppTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.screenTimeApp,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenTimeAppTableAnnotationComposer(
            $db: $db,
            $table: $db.screenTimeApp,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScreenTimeDayTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenTimeDayTable,
          ScreenTimeDayData,
          $$ScreenTimeDayTableFilterComposer,
          $$ScreenTimeDayTableOrderingComposer,
          $$ScreenTimeDayTableAnnotationComposer,
          $$ScreenTimeDayTableCreateCompanionBuilder,
          $$ScreenTimeDayTableUpdateCompanionBuilder,
          (ScreenTimeDayData, $$ScreenTimeDayTableReferences),
          ScreenTimeDayData,
          PrefetchHooks Function({bool screenTimeAppRefs})
        > {
  $$ScreenTimeDayTableTableManager(_$AppDatabase db, $ScreenTimeDayTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenTimeDayTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenTimeDayTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenTimeDayTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> totalMin = const Value.absent(),
                Value<int> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenTimeDayCompanion(
                date: date,
                totalMin: totalMin,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int> totalMin = const Value.absent(),
                required int capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => ScreenTimeDayCompanion.insert(
                date: date,
                totalMin: totalMin,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScreenTimeDayTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenTimeAppRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (screenTimeAppRefs) db.screenTimeApp,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (screenTimeAppRefs)
                    await $_getPrefetchedData<
                      ScreenTimeDayData,
                      $ScreenTimeDayTable,
                      ScreenTimeAppData
                    >(
                      currentTable: table,
                      referencedTable: $$ScreenTimeDayTableReferences
                          ._screenTimeAppRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScreenTimeDayTableReferences(
                            db,
                            table,
                            p0,
                          ).screenTimeAppRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.date == item.date),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScreenTimeDayTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenTimeDayTable,
      ScreenTimeDayData,
      $$ScreenTimeDayTableFilterComposer,
      $$ScreenTimeDayTableOrderingComposer,
      $$ScreenTimeDayTableAnnotationComposer,
      $$ScreenTimeDayTableCreateCompanionBuilder,
      $$ScreenTimeDayTableUpdateCompanionBuilder,
      (ScreenTimeDayData, $$ScreenTimeDayTableReferences),
      ScreenTimeDayData,
      PrefetchHooks Function({bool screenTimeAppRefs})
    >;
typedef $$ScreenTimeAppTableCreateCompanionBuilder =
    ScreenTimeAppCompanion Function({
      Value<int> id,
      required String date,
      required String packageName,
      Value<String?> appLabel,
      required int foregroundMin,
      required int rank,
    });
typedef $$ScreenTimeAppTableUpdateCompanionBuilder =
    ScreenTimeAppCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> packageName,
      Value<String?> appLabel,
      Value<int> foregroundMin,
      Value<int> rank,
    });

final class $$ScreenTimeAppTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScreenTimeAppTable, ScreenTimeAppData> {
  $$ScreenTimeAppTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenTimeDayTable _dateTable(_$AppDatabase db) => db.screenTimeDay
      .createAlias('screen_time_app__date__screen_time_day__date');

  $$ScreenTimeDayTableProcessedTableManager get date {
    final $_column = $_itemColumn<String>('date')!;

    final manager = $$ScreenTimeDayTableTableManager(
      $_db,
      $_db.screenTimeDay,
    ).filter((f) => f.date.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScreenTimeAppTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenTimeAppTable> {
  $$ScreenTimeAppTableFilterComposer({
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

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appLabel => $composableBuilder(
    column: $table.appLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foregroundMin => $composableBuilder(
    column: $table.foregroundMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenTimeDayTableFilterComposer get date {
    final $$ScreenTimeDayTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.screenTimeDay,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenTimeDayTableFilterComposer(
            $db: $db,
            $table: $db.screenTimeDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenTimeAppTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenTimeAppTable> {
  $$ScreenTimeAppTableOrderingComposer({
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

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appLabel => $composableBuilder(
    column: $table.appLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundMin => $composableBuilder(
    column: $table.foregroundMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenTimeDayTableOrderingComposer get date {
    final $$ScreenTimeDayTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.screenTimeDay,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenTimeDayTableOrderingComposer(
            $db: $db,
            $table: $db.screenTimeDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenTimeAppTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenTimeAppTable> {
  $$ScreenTimeAppTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appLabel =>
      $composableBuilder(column: $table.appLabel, builder: (column) => column);

  GeneratedColumn<int> get foregroundMin => $composableBuilder(
    column: $table.foregroundMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  $$ScreenTimeDayTableAnnotationComposer get date {
    final $$ScreenTimeDayTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.screenTimeDay,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenTimeDayTableAnnotationComposer(
            $db: $db,
            $table: $db.screenTimeDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenTimeAppTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenTimeAppTable,
          ScreenTimeAppData,
          $$ScreenTimeAppTableFilterComposer,
          $$ScreenTimeAppTableOrderingComposer,
          $$ScreenTimeAppTableAnnotationComposer,
          $$ScreenTimeAppTableCreateCompanionBuilder,
          $$ScreenTimeAppTableUpdateCompanionBuilder,
          (ScreenTimeAppData, $$ScreenTimeAppTableReferences),
          ScreenTimeAppData,
          PrefetchHooks Function({bool date})
        > {
  $$ScreenTimeAppTableTableManager(_$AppDatabase db, $ScreenTimeAppTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenTimeAppTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenTimeAppTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenTimeAppTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String?> appLabel = const Value.absent(),
                Value<int> foregroundMin = const Value.absent(),
                Value<int> rank = const Value.absent(),
              }) => ScreenTimeAppCompanion(
                id: id,
                date: date,
                packageName: packageName,
                appLabel: appLabel,
                foregroundMin: foregroundMin,
                rank: rank,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String packageName,
                Value<String?> appLabel = const Value.absent(),
                required int foregroundMin,
                required int rank,
              }) => ScreenTimeAppCompanion.insert(
                id: id,
                date: date,
                packageName: packageName,
                appLabel: appLabel,
                foregroundMin: foregroundMin,
                rank: rank,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScreenTimeAppTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({date = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (date) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.date,
                                referencedTable: $$ScreenTimeAppTableReferences
                                    ._dateTable(db),
                                referencedColumn: $$ScreenTimeAppTableReferences
                                    ._dateTable(db)
                                    .date,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScreenTimeAppTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenTimeAppTable,
      ScreenTimeAppData,
      $$ScreenTimeAppTableFilterComposer,
      $$ScreenTimeAppTableOrderingComposer,
      $$ScreenTimeAppTableAnnotationComposer,
      $$ScreenTimeAppTableCreateCompanionBuilder,
      $$ScreenTimeAppTableUpdateCompanionBuilder,
      (ScreenTimeAppData, $$ScreenTimeAppTableReferences),
      ScreenTimeAppData,
      PrefetchHooks Function({bool date})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MetricsTableTableManager get metrics =>
      $$MetricsTableTableManager(_db, _db.metrics);
  $$MetricOptionsTableTableManager get metricOptions =>
      $$MetricOptionsTableTableManager(_db, _db.metricOptions);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$EntryOptionsTableTableManager get entryOptions =>
      $$EntryOptionsTableTableManager(_db, _db.entryOptions);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$MoneyCategoriesTableTableManager get moneyCategories =>
      $$MoneyCategoriesTableTableManager(_db, _db.moneyCategories);
  $$ExpenseRemindersTableTableManager get expenseReminders =>
      $$ExpenseRemindersTableTableManager(_db, _db.expenseReminders);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$HealthProfileTableTableManager get healthProfile =>
      $$HealthProfileTableTableManager(_db, _db.healthProfile);
  $$BodyLogTableTableManager get bodyLog =>
      $$BodyLogTableTableManager(_db, _db.bodyLog);
  $$HealthSamplesTableTableManager get healthSamples =>
      $$HealthSamplesTableTableManager(_db, _db.healthSamples);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$SavedExerciseTitlesTableTableManager get savedExerciseTitles =>
      $$SavedExerciseTitlesTableTableManager(_db, _db.savedExerciseTitles);
  $$SavedFoodTypesTableTableManager get savedFoodTypes =>
      $$SavedFoodTypesTableTableManager(_db, _db.savedFoodTypes);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db, _db.programs);
  $$ProgramExercisesTableTableManager get programExercises =>
      $$ProgramExercisesTableTableManager(_db, _db.programExercises);
  $$CalorieEntriesTableTableManager get calorieEntries =>
      $$CalorieEntriesTableTableManager(_db, _db.calorieEntries);
  $$CalorieDayTableTableManager get calorieDay =>
      $$CalorieDayTableTableManager(_db, _db.calorieDay);
  $$ProgramLogTableTableManager get programLog =>
      $$ProgramLogTableTableManager(_db, _db.programLog);
  $$ScreenTimeDayTableTableManager get screenTimeDay =>
      $$ScreenTimeDayTableTableManager(_db, _db.screenTimeDay);
  $$ScreenTimeAppTableTableManager get screenTimeApp =>
      $$ScreenTimeAppTableTableManager(_db, _db.screenTimeApp);
}
