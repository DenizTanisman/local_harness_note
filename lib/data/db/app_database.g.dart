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
    isStarred,
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
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
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
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
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
  final bool isStarred;
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
    required this.isStarred,
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
    map['is_starred'] = Variable<bool>(isStarred);
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
      isStarred: Value(isStarred),
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
      isStarred: serializer.fromJson<bool>(json['isStarred']),
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
      'isStarred': serializer.toJson<bool>(isStarred),
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
    bool? isStarred,
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
    isStarred: isStarred ?? this.isStarred,
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
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
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
          ..write('isStarred: $isStarred, ')
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
    isStarred,
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
          other.isStarred == this.isStarred &&
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
  final Value<bool> isStarred;
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
    this.isStarred = const Value.absent(),
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
    this.isStarred = const Value.absent(),
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
    Expression<bool>? isStarred,
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
      if (isStarred != null) 'is_starred': isStarred,
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
    Value<bool>? isStarred,
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
      isStarred: isStarred ?? this.isStarred,
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
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
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
          ..write('isStarred: $isStarred, ')
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
  final int createdAt;
  final int updatedAt;
  const Entry({
    required this.id,
    required this.metricId,
    required this.date,
    this.numValue,
    this.textValue,
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
    int? createdAt,
    int? updatedAt,
  }) => Entry(
    id: id ?? this.id,
    metricId: metricId ?? this.metricId,
    date: date ?? this.date,
    numValue: numValue.present ? numValue.value : this.numValue,
    textValue: textValue.present ? textValue.value : this.textValue,
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
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<int> metricId;
  final Value<String> date;
  final Value<double?> numValue;
  final Value<String?> textValue;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.metricId = const Value.absent(),
    this.date = const Value.absent(),
    this.numValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int metricId,
    required String date,
    this.numValue = const Value.absent(),
    this.textValue = const Value.absent(),
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
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricId != null) 'metric_id': metricId,
      if (date != null) 'date': date,
      if (numValue != null) 'num_value': numValue,
      if (textValue != null) 'text_value': textValue,
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
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      metricId: metricId ?? this.metricId,
      date: date ?? this.date,
      numValue: numValue ?? this.numValue,
      textValue: textValue ?? this.textValue,
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
  ]);
}

typedef $$MetricsTableCreateCompanionBuilder =
    MetricsCompanion Function({
      Value<int> id,
      Value<int?> parentId,
      required String key,
      required String title,
      required String inputType,
      Value<bool> isStarred,
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
      Value<bool> isStarred,
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

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
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

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
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

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

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
                Value<bool> isStarred = const Value.absent(),
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
                isStarred: isStarred,
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
                Value<bool> isStarred = const Value.absent(),
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
                isStarred: isStarred,
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
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                metricId: metricId,
                date: date,
                numValue: numValue,
                textValue: textValue,
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
                required int createdAt,
                required int updatedAt,
              }) => EntriesCompanion.insert(
                id: id,
                metricId: metricId,
                date: date,
                numValue: numValue,
                textValue: textValue,
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
}
