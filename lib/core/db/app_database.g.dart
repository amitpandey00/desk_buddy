// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
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
  List<GeneratedColumn> get $columns => [id, name, emoji, colorHex, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
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
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String emoji;
  final String colorHex;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? emoji,
    String? colorHex,
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, colorHex, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String emoji,
    required String colorHex,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       emoji = Value(emoji),
       colorHex = Value(colorHex);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTemplateMeta = const VerificationMeta(
    'messageTemplate',
  );
  @override
  late final GeneratedColumn<String> messageTemplate = GeneratedColumn<String>(
    'message_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleType, String>
  scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ScheduleType>($RemindersTable.$converterscheduleType);
  static const VerificationMeta _everyMinutesMeta = const VerificationMeta(
    'everyMinutes',
  );
  @override
  late final GeneratedColumn<int> everyMinutes = GeneratedColumn<int>(
    'every_minutes',
    aliasedName,
    false,
    check: () => ComparableExpr(everyMinutes).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeFromMeta = const VerificationMeta(
    'activeFrom',
  );
  @override
  late final GeneratedColumn<String> activeFrom = GeneratedColumn<String>(
    'active_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeToMeta = const VerificationMeta(
    'activeTo',
  );
  @override
  late final GeneratedColumn<String> activeTo = GeneratedColumn<String>(
    'active_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOfDayMeta = const VerificationMeta(
    'timeOfDay',
  );
  @override
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
    'time_of_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> daysOfWeek =
      GeneratedColumn<String>(
        'days_of_week',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($RemindersTable.$converterdaysOfWeek);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyGoalMeta = const VerificationMeta(
    'dailyGoal',
  );
  @override
  late final GeneratedColumn<int> dailyGoal = GeneratedColumn<int>(
    'daily_goal',
    aliasedName,
    false,
    check: () => ComparableExpr(dailyGoal).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalUnitMeta = const VerificationMeta(
    'goalUnit',
  );
  @override
  late final GeneratedColumn<String> goalUnit = GeneratedColumn<String>(
    'goal_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propIdMeta = const VerificationMeta('propId');
  @override
  late final GeneratedColumn<String> propId = GeneratedColumn<String>(
    'prop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneLabelMeta = const VerificationMeta(
    'doneLabel',
  );
  @override
  late final GeneratedColumn<String> doneLabel = GeneratedColumn<String>(
    'done_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<int> nextDueAt = GeneratedColumn<int>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
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
    title,
    emoji,
    messageTemplate,
    categoryId,
    scheduleType,
    everyMinutes,
    activeFrom,
    activeTo,
    timeOfDay,
    daysOfWeek,
    date,
    dailyGoal,
    goalUnit,
    propId,
    doneLabel,
    enabled,
    nextDueAt,
    source,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('message_template')) {
      context.handle(
        _messageTemplateMeta,
        messageTemplate.isAcceptableOrUnknown(
          data['message_template']!,
          _messageTemplateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTemplateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('every_minutes')) {
      context.handle(
        _everyMinutesMeta,
        everyMinutes.isAcceptableOrUnknown(
          data['every_minutes']!,
          _everyMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_everyMinutesMeta);
    }
    if (data.containsKey('active_from')) {
      context.handle(
        _activeFromMeta,
        activeFrom.isAcceptableOrUnknown(data['active_from']!, _activeFromMeta),
      );
    }
    if (data.containsKey('active_to')) {
      context.handle(
        _activeToMeta,
        activeTo.isAcceptableOrUnknown(data['active_to']!, _activeToMeta),
      );
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
        _timeOfDayMeta,
        timeOfDay.isAcceptableOrUnknown(data['time_of_day']!, _timeOfDayMeta),
      );
    } else if (isInserting) {
      context.missing(_timeOfDayMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('daily_goal')) {
      context.handle(
        _dailyGoalMeta,
        dailyGoal.isAcceptableOrUnknown(data['daily_goal']!, _dailyGoalMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyGoalMeta);
    }
    if (data.containsKey('goal_unit')) {
      context.handle(
        _goalUnitMeta,
        goalUnit.isAcceptableOrUnknown(data['goal_unit']!, _goalUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_goalUnitMeta);
    }
    if (data.containsKey('prop_id')) {
      context.handle(
        _propIdMeta,
        propId.isAcceptableOrUnknown(data['prop_id']!, _propIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propIdMeta);
    }
    if (data.containsKey('done_label')) {
      context.handle(
        _doneLabelMeta,
        doneLabel.isAcceptableOrUnknown(data['done_label']!, _doneLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_doneLabelMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
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
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      messageTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_template'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      scheduleType: $RemindersTable.$converterscheduleType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_type'],
        )!,
      ),
      everyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}every_minutes'],
      )!,
      activeFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_from'],
      ),
      activeTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_to'],
      ),
      timeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_of_day'],
      )!,
      daysOfWeek: $RemindersTable.$converterdaysOfWeek.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}days_of_week'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      dailyGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal'],
      )!,
      goalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_unit'],
      )!,
      propId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prop_id'],
      )!,
      doneLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_label'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
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
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleType, String, String>
  $converterscheduleType = const EnumNameConverter<ScheduleType>(
    ScheduleType.values,
  );
  static TypeConverter<List<int>, String> $converterdaysOfWeek =
      const IntListConverter();
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String title;
  final String emoji;
  final String messageTemplate;
  final String categoryId;
  final ScheduleType scheduleType;
  final int everyMinutes;
  final String? activeFrom;
  final String? activeTo;
  final String timeOfDay;
  final List<int> daysOfWeek;
  final String? date;
  final int dailyGoal;
  final String goalUnit;
  final String propId;
  final String doneLabel;
  final bool enabled;
  final int? nextDueAt;
  final String source;
  final int createdAt;
  final int updatedAt;
  const ReminderRow({
    required this.id,
    required this.title,
    required this.emoji,
    required this.messageTemplate,
    required this.categoryId,
    required this.scheduleType,
    required this.everyMinutes,
    this.activeFrom,
    this.activeTo,
    required this.timeOfDay,
    required this.daysOfWeek,
    this.date,
    required this.dailyGoal,
    required this.goalUnit,
    required this.propId,
    required this.doneLabel,
    required this.enabled,
    this.nextDueAt,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['emoji'] = Variable<String>(emoji);
    map['message_template'] = Variable<String>(messageTemplate);
    map['category_id'] = Variable<String>(categoryId);
    {
      map['schedule_type'] = Variable<String>(
        $RemindersTable.$converterscheduleType.toSql(scheduleType),
      );
    }
    map['every_minutes'] = Variable<int>(everyMinutes);
    if (!nullToAbsent || activeFrom != null) {
      map['active_from'] = Variable<String>(activeFrom);
    }
    if (!nullToAbsent || activeTo != null) {
      map['active_to'] = Variable<String>(activeTo);
    }
    map['time_of_day'] = Variable<String>(timeOfDay);
    {
      map['days_of_week'] = Variable<String>(
        $RemindersTable.$converterdaysOfWeek.toSql(daysOfWeek),
      );
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    map['daily_goal'] = Variable<int>(dailyGoal);
    map['goal_unit'] = Variable<String>(goalUnit);
    map['prop_id'] = Variable<String>(propId);
    map['done_label'] = Variable<String>(doneLabel);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<int>(nextDueAt);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      emoji: Value(emoji),
      messageTemplate: Value(messageTemplate),
      categoryId: Value(categoryId),
      scheduleType: Value(scheduleType),
      everyMinutes: Value(everyMinutes),
      activeFrom: activeFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(activeFrom),
      activeTo: activeTo == null && nullToAbsent
          ? const Value.absent()
          : Value(activeTo),
      timeOfDay: Value(timeOfDay),
      daysOfWeek: Value(daysOfWeek),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      dailyGoal: Value(dailyGoal),
      goalUnit: Value(goalUnit),
      propId: Value(propId),
      doneLabel: Value(doneLabel),
      enabled: Value(enabled),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      emoji: serializer.fromJson<String>(json['emoji']),
      messageTemplate: serializer.fromJson<String>(json['messageTemplate']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      scheduleType: $RemindersTable.$converterscheduleType.fromJson(
        serializer.fromJson<String>(json['scheduleType']),
      ),
      everyMinutes: serializer.fromJson<int>(json['everyMinutes']),
      activeFrom: serializer.fromJson<String?>(json['activeFrom']),
      activeTo: serializer.fromJson<String?>(json['activeTo']),
      timeOfDay: serializer.fromJson<String>(json['timeOfDay']),
      daysOfWeek: serializer.fromJson<List<int>>(json['daysOfWeek']),
      date: serializer.fromJson<String?>(json['date']),
      dailyGoal: serializer.fromJson<int>(json['dailyGoal']),
      goalUnit: serializer.fromJson<String>(json['goalUnit']),
      propId: serializer.fromJson<String>(json['propId']),
      doneLabel: serializer.fromJson<String>(json['doneLabel']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      nextDueAt: serializer.fromJson<int?>(json['nextDueAt']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'emoji': serializer.toJson<String>(emoji),
      'messageTemplate': serializer.toJson<String>(messageTemplate),
      'categoryId': serializer.toJson<String>(categoryId),
      'scheduleType': serializer.toJson<String>(
        $RemindersTable.$converterscheduleType.toJson(scheduleType),
      ),
      'everyMinutes': serializer.toJson<int>(everyMinutes),
      'activeFrom': serializer.toJson<String?>(activeFrom),
      'activeTo': serializer.toJson<String?>(activeTo),
      'timeOfDay': serializer.toJson<String>(timeOfDay),
      'daysOfWeek': serializer.toJson<List<int>>(daysOfWeek),
      'date': serializer.toJson<String?>(date),
      'dailyGoal': serializer.toJson<int>(dailyGoal),
      'goalUnit': serializer.toJson<String>(goalUnit),
      'propId': serializer.toJson<String>(propId),
      'doneLabel': serializer.toJson<String>(doneLabel),
      'enabled': serializer.toJson<bool>(enabled),
      'nextDueAt': serializer.toJson<int?>(nextDueAt),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? title,
    String? emoji,
    String? messageTemplate,
    String? categoryId,
    ScheduleType? scheduleType,
    int? everyMinutes,
    Value<String?> activeFrom = const Value.absent(),
    Value<String?> activeTo = const Value.absent(),
    String? timeOfDay,
    List<int>? daysOfWeek,
    Value<String?> date = const Value.absent(),
    int? dailyGoal,
    String? goalUnit,
    String? propId,
    String? doneLabel,
    bool? enabled,
    Value<int?> nextDueAt = const Value.absent(),
    String? source,
    int? createdAt,
    int? updatedAt,
  }) => ReminderRow(
    id: id ?? this.id,
    title: title ?? this.title,
    emoji: emoji ?? this.emoji,
    messageTemplate: messageTemplate ?? this.messageTemplate,
    categoryId: categoryId ?? this.categoryId,
    scheduleType: scheduleType ?? this.scheduleType,
    everyMinutes: everyMinutes ?? this.everyMinutes,
    activeFrom: activeFrom.present ? activeFrom.value : this.activeFrom,
    activeTo: activeTo.present ? activeTo.value : this.activeTo,
    timeOfDay: timeOfDay ?? this.timeOfDay,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    date: date.present ? date.value : this.date,
    dailyGoal: dailyGoal ?? this.dailyGoal,
    goalUnit: goalUnit ?? this.goalUnit,
    propId: propId ?? this.propId,
    doneLabel: doneLabel ?? this.doneLabel,
    enabled: enabled ?? this.enabled,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      messageTemplate: data.messageTemplate.present
          ? data.messageTemplate.value
          : this.messageTemplate,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      everyMinutes: data.everyMinutes.present
          ? data.everyMinutes.value
          : this.everyMinutes,
      activeFrom: data.activeFrom.present
          ? data.activeFrom.value
          : this.activeFrom,
      activeTo: data.activeTo.present ? data.activeTo.value : this.activeTo,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      date: data.date.present ? data.date.value : this.date,
      dailyGoal: data.dailyGoal.present ? data.dailyGoal.value : this.dailyGoal,
      goalUnit: data.goalUnit.present ? data.goalUnit.value : this.goalUnit,
      propId: data.propId.present ? data.propId.value : this.propId,
      doneLabel: data.doneLabel.present ? data.doneLabel.value : this.doneLabel,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('emoji: $emoji, ')
          ..write('messageTemplate: $messageTemplate, ')
          ..write('categoryId: $categoryId, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('everyMinutes: $everyMinutes, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeTo: $activeTo, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('date: $date, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('goalUnit: $goalUnit, ')
          ..write('propId: $propId, ')
          ..write('doneLabel: $doneLabel, ')
          ..write('enabled: $enabled, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    emoji,
    messageTemplate,
    categoryId,
    scheduleType,
    everyMinutes,
    activeFrom,
    activeTo,
    timeOfDay,
    daysOfWeek,
    date,
    dailyGoal,
    goalUnit,
    propId,
    doneLabel,
    enabled,
    nextDueAt,
    source,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.emoji == this.emoji &&
          other.messageTemplate == this.messageTemplate &&
          other.categoryId == this.categoryId &&
          other.scheduleType == this.scheduleType &&
          other.everyMinutes == this.everyMinutes &&
          other.activeFrom == this.activeFrom &&
          other.activeTo == this.activeTo &&
          other.timeOfDay == this.timeOfDay &&
          other.daysOfWeek == this.daysOfWeek &&
          other.date == this.date &&
          other.dailyGoal == this.dailyGoal &&
          other.goalUnit == this.goalUnit &&
          other.propId == this.propId &&
          other.doneLabel == this.doneLabel &&
          other.enabled == this.enabled &&
          other.nextDueAt == this.nextDueAt &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> emoji;
  final Value<String> messageTemplate;
  final Value<String> categoryId;
  final Value<ScheduleType> scheduleType;
  final Value<int> everyMinutes;
  final Value<String?> activeFrom;
  final Value<String?> activeTo;
  final Value<String> timeOfDay;
  final Value<List<int>> daysOfWeek;
  final Value<String?> date;
  final Value<int> dailyGoal;
  final Value<String> goalUnit;
  final Value<String> propId;
  final Value<String> doneLabel;
  final Value<bool> enabled;
  final Value<int?> nextDueAt;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.emoji = const Value.absent(),
    this.messageTemplate = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.everyMinutes = const Value.absent(),
    this.activeFrom = const Value.absent(),
    this.activeTo = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.date = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.goalUnit = const Value.absent(),
    this.propId = const Value.absent(),
    this.doneLabel = const Value.absent(),
    this.enabled = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String title,
    required String emoji,
    required String messageTemplate,
    required String categoryId,
    required ScheduleType scheduleType,
    required int everyMinutes,
    this.activeFrom = const Value.absent(),
    this.activeTo = const Value.absent(),
    required String timeOfDay,
    required List<int> daysOfWeek,
    this.date = const Value.absent(),
    required int dailyGoal,
    required String goalUnit,
    required String propId,
    required String doneLabel,
    required bool enabled,
    this.nextDueAt = const Value.absent(),
    this.source = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       emoji = Value(emoji),
       messageTemplate = Value(messageTemplate),
       categoryId = Value(categoryId),
       scheduleType = Value(scheduleType),
       everyMinutes = Value(everyMinutes),
       timeOfDay = Value(timeOfDay),
       daysOfWeek = Value(daysOfWeek),
       dailyGoal = Value(dailyGoal),
       goalUnit = Value(goalUnit),
       propId = Value(propId),
       doneLabel = Value(doneLabel),
       enabled = Value(enabled),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? emoji,
    Expression<String>? messageTemplate,
    Expression<String>? categoryId,
    Expression<String>? scheduleType,
    Expression<int>? everyMinutes,
    Expression<String>? activeFrom,
    Expression<String>? activeTo,
    Expression<String>? timeOfDay,
    Expression<String>? daysOfWeek,
    Expression<String>? date,
    Expression<int>? dailyGoal,
    Expression<String>? goalUnit,
    Expression<String>? propId,
    Expression<String>? doneLabel,
    Expression<bool>? enabled,
    Expression<int>? nextDueAt,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (emoji != null) 'emoji': emoji,
      if (messageTemplate != null) 'message_template': messageTemplate,
      if (categoryId != null) 'category_id': categoryId,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (everyMinutes != null) 'every_minutes': everyMinutes,
      if (activeFrom != null) 'active_from': activeFrom,
      if (activeTo != null) 'active_to': activeTo,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (date != null) 'date': date,
      if (dailyGoal != null) 'daily_goal': dailyGoal,
      if (goalUnit != null) 'goal_unit': goalUnit,
      if (propId != null) 'prop_id': propId,
      if (doneLabel != null) 'done_label': doneLabel,
      if (enabled != null) 'enabled': enabled,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? emoji,
    Value<String>? messageTemplate,
    Value<String>? categoryId,
    Value<ScheduleType>? scheduleType,
    Value<int>? everyMinutes,
    Value<String?>? activeFrom,
    Value<String?>? activeTo,
    Value<String>? timeOfDay,
    Value<List<int>>? daysOfWeek,
    Value<String?>? date,
    Value<int>? dailyGoal,
    Value<String>? goalUnit,
    Value<String>? propId,
    Value<String>? doneLabel,
    Value<bool>? enabled,
    Value<int?>? nextDueAt,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      categoryId: categoryId ?? this.categoryId,
      scheduleType: scheduleType ?? this.scheduleType,
      everyMinutes: everyMinutes ?? this.everyMinutes,
      activeFrom: activeFrom ?? this.activeFrom,
      activeTo: activeTo ?? this.activeTo,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      date: date ?? this.date,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      goalUnit: goalUnit ?? this.goalUnit,
      propId: propId ?? this.propId,
      doneLabel: doneLabel ?? this.doneLabel,
      enabled: enabled ?? this.enabled,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (messageTemplate.present) {
      map['message_template'] = Variable<String>(messageTemplate.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(
        $RemindersTable.$converterscheduleType.toSql(scheduleType.value),
      );
    }
    if (everyMinutes.present) {
      map['every_minutes'] = Variable<int>(everyMinutes.value);
    }
    if (activeFrom.present) {
      map['active_from'] = Variable<String>(activeFrom.value);
    }
    if (activeTo.present) {
      map['active_to'] = Variable<String>(activeTo.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(
        $RemindersTable.$converterdaysOfWeek.toSql(daysOfWeek.value),
      );
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (dailyGoal.present) {
      map['daily_goal'] = Variable<int>(dailyGoal.value);
    }
    if (goalUnit.present) {
      map['goal_unit'] = Variable<String>(goalUnit.value);
    }
    if (propId.present) {
      map['prop_id'] = Variable<String>(propId.value);
    }
    if (doneLabel.present) {
      map['done_label'] = Variable<String>(doneLabel.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<int>(nextDueAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('emoji: $emoji, ')
          ..write('messageTemplate: $messageTemplate, ')
          ..write('categoryId: $categoryId, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('everyMinutes: $everyMinutes, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeTo: $activeTo, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('date: $date, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('goalUnit: $goalUnit, ')
          ..write('propId: $propId, ')
          ..write('doneLabel: $doneLabel, ')
          ..write('enabled: $enabled, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogAction, String> action =
      GeneratedColumn<String>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogAction>($LogEntriesTable.$converteraction);
  static const VerificationMeta _responseSecondsMeta = const VerificationMeta(
    'responseSeconds',
  );
  @override
  late final GeneratedColumn<int> responseSeconds = GeneratedColumn<int>(
    'response_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _manualMeta = const VerificationMeta('manual');
  @override
  late final GeneratedColumn<bool> manual = GeneratedColumn<bool>(
    'manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sampleMeta = const VerificationMeta('sample');
  @override
  late final GeneratedColumn<bool> sample = GeneratedColumn<bool>(
    'sample',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sample" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reminderId,
    categoryId,
    at,
    action,
    responseSeconds,
    manual,
    sample,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('response_seconds')) {
      context.handle(
        _responseSecondsMeta,
        responseSeconds.isAcceptableOrUnknown(
          data['response_seconds']!,
          _responseSecondsMeta,
        ),
      );
    }
    if (data.containsKey('manual')) {
      context.handle(
        _manualMeta,
        manual.isAcceptableOrUnknown(data['manual']!, _manualMeta),
      );
    }
    if (data.containsKey('sample')) {
      context.handle(
        _sampleMeta,
        sample.isAcceptableOrUnknown(data['sample']!, _sampleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      action: $LogEntriesTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action'],
        )!,
      ),
      responseSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_seconds'],
      )!,
      manual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manual'],
      )!,
      sample: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sample'],
      )!,
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LogAction, String, String> $converteraction =
      const EnumNameConverter<LogAction>(LogAction.values);
}

class LogEntryRow extends DataClass implements Insertable<LogEntryRow> {
  final String id;
  final String? reminderId;
  final String? categoryId;
  final int at;
  final LogAction action;
  final int responseSeconds;
  final bool manual;
  final bool sample;
  const LogEntryRow({
    required this.id,
    this.reminderId,
    this.categoryId,
    required this.at,
    required this.action,
    required this.responseSeconds,
    required this.manual,
    required this.sample,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || reminderId != null) {
      map['reminder_id'] = Variable<String>(reminderId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['at'] = Variable<int>(at);
    {
      map['action'] = Variable<String>(
        $LogEntriesTable.$converteraction.toSql(action),
      );
    }
    map['response_seconds'] = Variable<int>(responseSeconds);
    map['manual'] = Variable<bool>(manual);
    map['sample'] = Variable<bool>(sample);
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      reminderId: reminderId == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      at: Value(at),
      action: Value(action),
      responseSeconds: Value(responseSeconds),
      manual: Value(manual),
      sample: Value(sample),
    );
  }

  factory LogEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntryRow(
      id: serializer.fromJson<String>(json['id']),
      reminderId: serializer.fromJson<String?>(json['reminderId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      at: serializer.fromJson<int>(json['at']),
      action: $LogEntriesTable.$converteraction.fromJson(
        serializer.fromJson<String>(json['action']),
      ),
      responseSeconds: serializer.fromJson<int>(json['responseSeconds']),
      manual: serializer.fromJson<bool>(json['manual']),
      sample: serializer.fromJson<bool>(json['sample']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reminderId': serializer.toJson<String?>(reminderId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'at': serializer.toJson<int>(at),
      'action': serializer.toJson<String>(
        $LogEntriesTable.$converteraction.toJson(action),
      ),
      'responseSeconds': serializer.toJson<int>(responseSeconds),
      'manual': serializer.toJson<bool>(manual),
      'sample': serializer.toJson<bool>(sample),
    };
  }

  LogEntryRow copyWith({
    String? id,
    Value<String?> reminderId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    int? at,
    LogAction? action,
    int? responseSeconds,
    bool? manual,
    bool? sample,
  }) => LogEntryRow(
    id: id ?? this.id,
    reminderId: reminderId.present ? reminderId.value : this.reminderId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    at: at ?? this.at,
    action: action ?? this.action,
    responseSeconds: responseSeconds ?? this.responseSeconds,
    manual: manual ?? this.manual,
    sample: sample ?? this.sample,
  );
  LogEntryRow copyWithCompanion(LogEntriesCompanion data) {
    return LogEntryRow(
      id: data.id.present ? data.id.value : this.id,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      at: data.at.present ? data.at.value : this.at,
      action: data.action.present ? data.action.value : this.action,
      responseSeconds: data.responseSeconds.present
          ? data.responseSeconds.value
          : this.responseSeconds,
      manual: data.manual.present ? data.manual.value : this.manual,
      sample: data.sample.present ? data.sample.value : this.sample,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntryRow(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('categoryId: $categoryId, ')
          ..write('at: $at, ')
          ..write('action: $action, ')
          ..write('responseSeconds: $responseSeconds, ')
          ..write('manual: $manual, ')
          ..write('sample: $sample')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reminderId,
    categoryId,
    at,
    action,
    responseSeconds,
    manual,
    sample,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntryRow &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.categoryId == this.categoryId &&
          other.at == this.at &&
          other.action == this.action &&
          other.responseSeconds == this.responseSeconds &&
          other.manual == this.manual &&
          other.sample == this.sample);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntryRow> {
  final Value<String> id;
  final Value<String?> reminderId;
  final Value<String?> categoryId;
  final Value<int> at;
  final Value<LogAction> action;
  final Value<int> responseSeconds;
  final Value<bool> manual;
  final Value<bool> sample;
  final Value<int> rowid;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.at = const Value.absent(),
    this.action = const Value.absent(),
    this.responseSeconds = const Value.absent(),
    this.manual = const Value.absent(),
    this.sample = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    required String id,
    this.reminderId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int at,
    required LogAction action,
    this.responseSeconds = const Value.absent(),
    this.manual = const Value.absent(),
    this.sample = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       action = Value(action);
  static Insertable<LogEntryRow> custom({
    Expression<String>? id,
    Expression<String>? reminderId,
    Expression<String>? categoryId,
    Expression<int>? at,
    Expression<String>? action,
    Expression<int>? responseSeconds,
    Expression<bool>? manual,
    Expression<bool>? sample,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (categoryId != null) 'category_id': categoryId,
      if (at != null) 'at': at,
      if (action != null) 'action': action,
      if (responseSeconds != null) 'response_seconds': responseSeconds,
      if (manual != null) 'manual': manual,
      if (sample != null) 'sample': sample,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? reminderId,
    Value<String?>? categoryId,
    Value<int>? at,
    Value<LogAction>? action,
    Value<int>? responseSeconds,
    Value<bool>? manual,
    Value<bool>? sample,
    Value<int>? rowid,
  }) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      categoryId: categoryId ?? this.categoryId,
      at: at ?? this.at,
      action: action ?? this.action,
      responseSeconds: responseSeconds ?? this.responseSeconds,
      manual: manual ?? this.manual,
      sample: sample ?? this.sample,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(
        $LogEntriesTable.$converteraction.toSql(action.value),
      );
    }
    if (responseSeconds.present) {
      map['response_seconds'] = Variable<int>(responseSeconds.value);
    }
    if (manual.present) {
      map['manual'] = Variable<bool>(manual.value);
    }
    if (sample.present) {
      map['sample'] = Variable<bool>(sample.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('categoryId: $categoryId, ')
          ..write('at: $at, ')
          ..write('action: $action, ')
          ..write('responseSeconds: $responseSeconds, ')
          ..write('manual: $manual, ')
          ..write('sample: $sample, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuddyLooksTable extends BuddyLooks
    with TableInfo<$BuddyLooksTable, BuddyLookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuddyLooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _skinHexMeta = const VerificationMeta(
    'skinHex',
  );
  @override
  late final GeneratedColumn<String> skinHex = GeneratedColumn<String>(
    'skin_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hairHexMeta = const VerificationMeta(
    'hairHex',
  );
  @override
  late final GeneratedColumn<String> hairHex = GeneratedColumn<String>(
    'hair_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jacketHexMeta = const VerificationMeta(
    'jacketHex',
  );
  @override
  late final GeneratedColumn<String> jacketHex = GeneratedColumn<String>(
    'jacket_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shirtHexMeta = const VerificationMeta(
    'shirtHex',
  );
  @override
  late final GeneratedColumn<String> shirtHex = GeneratedColumn<String>(
    'shirt_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pantsHexMeta = const VerificationMeta(
    'pantsHex',
  );
  @override
  late final GeneratedColumn<String> pantsHex = GeneratedColumn<String>(
    'pants_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shoesHexMeta = const VerificationMeta(
    'shoesHex',
  );
  @override
  late final GeneratedColumn<String> shoesHex = GeneratedColumn<String>(
    'shoes_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HairStyle, String> hairStyle =
      GeneratedColumn<String>(
        'hair_style',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HairStyle>($BuddyLooksTable.$converterhairStyle);
  @override
  late final GeneratedColumnWithTypeConverter<HatStyle, String> hat =
      GeneratedColumn<String>(
        'hat',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HatStyle>($BuddyLooksTable.$converterhat);
  static const VerificationMeta _spectaclesMeta = const VerificationMeta(
    'spectacles',
  );
  @override
  late final GeneratedColumn<bool> spectacles = GeneratedColumn<bool>(
    'spectacles',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("spectacles" IN (0, 1))',
    ),
  );
  static const VerificationMeta _defaultPropIdMeta = const VerificationMeta(
    'defaultPropId',
  );
  @override
  late final GeneratedColumn<String> defaultPropId = GeneratedColumn<String>(
    'default_prop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    skinHex,
    hairHex,
    jacketHex,
    shirtHex,
    pantsHex,
    shoesHex,
    hairStyle,
    hat,
    spectacles,
    defaultPropId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buddy_looks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BuddyLookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skin_hex')) {
      context.handle(
        _skinHexMeta,
        skinHex.isAcceptableOrUnknown(data['skin_hex']!, _skinHexMeta),
      );
    } else if (isInserting) {
      context.missing(_skinHexMeta);
    }
    if (data.containsKey('hair_hex')) {
      context.handle(
        _hairHexMeta,
        hairHex.isAcceptableOrUnknown(data['hair_hex']!, _hairHexMeta),
      );
    } else if (isInserting) {
      context.missing(_hairHexMeta);
    }
    if (data.containsKey('jacket_hex')) {
      context.handle(
        _jacketHexMeta,
        jacketHex.isAcceptableOrUnknown(data['jacket_hex']!, _jacketHexMeta),
      );
    } else if (isInserting) {
      context.missing(_jacketHexMeta);
    }
    if (data.containsKey('shirt_hex')) {
      context.handle(
        _shirtHexMeta,
        shirtHex.isAcceptableOrUnknown(data['shirt_hex']!, _shirtHexMeta),
      );
    } else if (isInserting) {
      context.missing(_shirtHexMeta);
    }
    if (data.containsKey('pants_hex')) {
      context.handle(
        _pantsHexMeta,
        pantsHex.isAcceptableOrUnknown(data['pants_hex']!, _pantsHexMeta),
      );
    } else if (isInserting) {
      context.missing(_pantsHexMeta);
    }
    if (data.containsKey('shoes_hex')) {
      context.handle(
        _shoesHexMeta,
        shoesHex.isAcceptableOrUnknown(data['shoes_hex']!, _shoesHexMeta),
      );
    } else if (isInserting) {
      context.missing(_shoesHexMeta);
    }
    if (data.containsKey('spectacles')) {
      context.handle(
        _spectaclesMeta,
        spectacles.isAcceptableOrUnknown(data['spectacles']!, _spectaclesMeta),
      );
    } else if (isInserting) {
      context.missing(_spectaclesMeta);
    }
    if (data.containsKey('default_prop_id')) {
      context.handle(
        _defaultPropIdMeta,
        defaultPropId.isAcceptableOrUnknown(
          data['default_prop_id']!,
          _defaultPropIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultPropIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuddyLookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuddyLookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      skinHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skin_hex'],
      )!,
      hairHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hair_hex'],
      )!,
      jacketHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jacket_hex'],
      )!,
      shirtHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shirt_hex'],
      )!,
      pantsHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pants_hex'],
      )!,
      shoesHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shoes_hex'],
      )!,
      hairStyle: $BuddyLooksTable.$converterhairStyle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hair_style'],
        )!,
      ),
      hat: $BuddyLooksTable.$converterhat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hat'],
        )!,
      ),
      spectacles: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}spectacles'],
      )!,
      defaultPropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_prop_id'],
      )!,
    );
  }

  @override
  $BuddyLooksTable createAlias(String alias) {
    return $BuddyLooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HairStyle, String, String> $converterhairStyle =
      const EnumNameConverter<HairStyle>(HairStyle.values);
  static JsonTypeConverter2<HatStyle, String, String> $converterhat =
      const EnumNameConverter<HatStyle>(HatStyle.values);
}

class BuddyLookRow extends DataClass implements Insertable<BuddyLookRow> {
  final int id;
  final String skinHex;
  final String hairHex;
  final String jacketHex;
  final String shirtHex;
  final String pantsHex;
  final String shoesHex;
  final HairStyle hairStyle;
  final HatStyle hat;
  final bool spectacles;
  final String defaultPropId;
  const BuddyLookRow({
    required this.id,
    required this.skinHex,
    required this.hairHex,
    required this.jacketHex,
    required this.shirtHex,
    required this.pantsHex,
    required this.shoesHex,
    required this.hairStyle,
    required this.hat,
    required this.spectacles,
    required this.defaultPropId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skin_hex'] = Variable<String>(skinHex);
    map['hair_hex'] = Variable<String>(hairHex);
    map['jacket_hex'] = Variable<String>(jacketHex);
    map['shirt_hex'] = Variable<String>(shirtHex);
    map['pants_hex'] = Variable<String>(pantsHex);
    map['shoes_hex'] = Variable<String>(shoesHex);
    {
      map['hair_style'] = Variable<String>(
        $BuddyLooksTable.$converterhairStyle.toSql(hairStyle),
      );
    }
    {
      map['hat'] = Variable<String>($BuddyLooksTable.$converterhat.toSql(hat));
    }
    map['spectacles'] = Variable<bool>(spectacles);
    map['default_prop_id'] = Variable<String>(defaultPropId);
    return map;
  }

  BuddyLooksCompanion toCompanion(bool nullToAbsent) {
    return BuddyLooksCompanion(
      id: Value(id),
      skinHex: Value(skinHex),
      hairHex: Value(hairHex),
      jacketHex: Value(jacketHex),
      shirtHex: Value(shirtHex),
      pantsHex: Value(pantsHex),
      shoesHex: Value(shoesHex),
      hairStyle: Value(hairStyle),
      hat: Value(hat),
      spectacles: Value(spectacles),
      defaultPropId: Value(defaultPropId),
    );
  }

  factory BuddyLookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuddyLookRow(
      id: serializer.fromJson<int>(json['id']),
      skinHex: serializer.fromJson<String>(json['skinHex']),
      hairHex: serializer.fromJson<String>(json['hairHex']),
      jacketHex: serializer.fromJson<String>(json['jacketHex']),
      shirtHex: serializer.fromJson<String>(json['shirtHex']),
      pantsHex: serializer.fromJson<String>(json['pantsHex']),
      shoesHex: serializer.fromJson<String>(json['shoesHex']),
      hairStyle: $BuddyLooksTable.$converterhairStyle.fromJson(
        serializer.fromJson<String>(json['hairStyle']),
      ),
      hat: $BuddyLooksTable.$converterhat.fromJson(
        serializer.fromJson<String>(json['hat']),
      ),
      spectacles: serializer.fromJson<bool>(json['spectacles']),
      defaultPropId: serializer.fromJson<String>(json['defaultPropId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skinHex': serializer.toJson<String>(skinHex),
      'hairHex': serializer.toJson<String>(hairHex),
      'jacketHex': serializer.toJson<String>(jacketHex),
      'shirtHex': serializer.toJson<String>(shirtHex),
      'pantsHex': serializer.toJson<String>(pantsHex),
      'shoesHex': serializer.toJson<String>(shoesHex),
      'hairStyle': serializer.toJson<String>(
        $BuddyLooksTable.$converterhairStyle.toJson(hairStyle),
      ),
      'hat': serializer.toJson<String>(
        $BuddyLooksTable.$converterhat.toJson(hat),
      ),
      'spectacles': serializer.toJson<bool>(spectacles),
      'defaultPropId': serializer.toJson<String>(defaultPropId),
    };
  }

  BuddyLookRow copyWith({
    int? id,
    String? skinHex,
    String? hairHex,
    String? jacketHex,
    String? shirtHex,
    String? pantsHex,
    String? shoesHex,
    HairStyle? hairStyle,
    HatStyle? hat,
    bool? spectacles,
    String? defaultPropId,
  }) => BuddyLookRow(
    id: id ?? this.id,
    skinHex: skinHex ?? this.skinHex,
    hairHex: hairHex ?? this.hairHex,
    jacketHex: jacketHex ?? this.jacketHex,
    shirtHex: shirtHex ?? this.shirtHex,
    pantsHex: pantsHex ?? this.pantsHex,
    shoesHex: shoesHex ?? this.shoesHex,
    hairStyle: hairStyle ?? this.hairStyle,
    hat: hat ?? this.hat,
    spectacles: spectacles ?? this.spectacles,
    defaultPropId: defaultPropId ?? this.defaultPropId,
  );
  BuddyLookRow copyWithCompanion(BuddyLooksCompanion data) {
    return BuddyLookRow(
      id: data.id.present ? data.id.value : this.id,
      skinHex: data.skinHex.present ? data.skinHex.value : this.skinHex,
      hairHex: data.hairHex.present ? data.hairHex.value : this.hairHex,
      jacketHex: data.jacketHex.present ? data.jacketHex.value : this.jacketHex,
      shirtHex: data.shirtHex.present ? data.shirtHex.value : this.shirtHex,
      pantsHex: data.pantsHex.present ? data.pantsHex.value : this.pantsHex,
      shoesHex: data.shoesHex.present ? data.shoesHex.value : this.shoesHex,
      hairStyle: data.hairStyle.present ? data.hairStyle.value : this.hairStyle,
      hat: data.hat.present ? data.hat.value : this.hat,
      spectacles: data.spectacles.present
          ? data.spectacles.value
          : this.spectacles,
      defaultPropId: data.defaultPropId.present
          ? data.defaultPropId.value
          : this.defaultPropId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuddyLookRow(')
          ..write('id: $id, ')
          ..write('skinHex: $skinHex, ')
          ..write('hairHex: $hairHex, ')
          ..write('jacketHex: $jacketHex, ')
          ..write('shirtHex: $shirtHex, ')
          ..write('pantsHex: $pantsHex, ')
          ..write('shoesHex: $shoesHex, ')
          ..write('hairStyle: $hairStyle, ')
          ..write('hat: $hat, ')
          ..write('spectacles: $spectacles, ')
          ..write('defaultPropId: $defaultPropId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    skinHex,
    hairHex,
    jacketHex,
    shirtHex,
    pantsHex,
    shoesHex,
    hairStyle,
    hat,
    spectacles,
    defaultPropId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuddyLookRow &&
          other.id == this.id &&
          other.skinHex == this.skinHex &&
          other.hairHex == this.hairHex &&
          other.jacketHex == this.jacketHex &&
          other.shirtHex == this.shirtHex &&
          other.pantsHex == this.pantsHex &&
          other.shoesHex == this.shoesHex &&
          other.hairStyle == this.hairStyle &&
          other.hat == this.hat &&
          other.spectacles == this.spectacles &&
          other.defaultPropId == this.defaultPropId);
}

class BuddyLooksCompanion extends UpdateCompanion<BuddyLookRow> {
  final Value<int> id;
  final Value<String> skinHex;
  final Value<String> hairHex;
  final Value<String> jacketHex;
  final Value<String> shirtHex;
  final Value<String> pantsHex;
  final Value<String> shoesHex;
  final Value<HairStyle> hairStyle;
  final Value<HatStyle> hat;
  final Value<bool> spectacles;
  final Value<String> defaultPropId;
  const BuddyLooksCompanion({
    this.id = const Value.absent(),
    this.skinHex = const Value.absent(),
    this.hairHex = const Value.absent(),
    this.jacketHex = const Value.absent(),
    this.shirtHex = const Value.absent(),
    this.pantsHex = const Value.absent(),
    this.shoesHex = const Value.absent(),
    this.hairStyle = const Value.absent(),
    this.hat = const Value.absent(),
    this.spectacles = const Value.absent(),
    this.defaultPropId = const Value.absent(),
  });
  BuddyLooksCompanion.insert({
    this.id = const Value.absent(),
    required String skinHex,
    required String hairHex,
    required String jacketHex,
    required String shirtHex,
    required String pantsHex,
    required String shoesHex,
    required HairStyle hairStyle,
    required HatStyle hat,
    required bool spectacles,
    required String defaultPropId,
  }) : skinHex = Value(skinHex),
       hairHex = Value(hairHex),
       jacketHex = Value(jacketHex),
       shirtHex = Value(shirtHex),
       pantsHex = Value(pantsHex),
       shoesHex = Value(shoesHex),
       hairStyle = Value(hairStyle),
       hat = Value(hat),
       spectacles = Value(spectacles),
       defaultPropId = Value(defaultPropId);
  static Insertable<BuddyLookRow> custom({
    Expression<int>? id,
    Expression<String>? skinHex,
    Expression<String>? hairHex,
    Expression<String>? jacketHex,
    Expression<String>? shirtHex,
    Expression<String>? pantsHex,
    Expression<String>? shoesHex,
    Expression<String>? hairStyle,
    Expression<String>? hat,
    Expression<bool>? spectacles,
    Expression<String>? defaultPropId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skinHex != null) 'skin_hex': skinHex,
      if (hairHex != null) 'hair_hex': hairHex,
      if (jacketHex != null) 'jacket_hex': jacketHex,
      if (shirtHex != null) 'shirt_hex': shirtHex,
      if (pantsHex != null) 'pants_hex': pantsHex,
      if (shoesHex != null) 'shoes_hex': shoesHex,
      if (hairStyle != null) 'hair_style': hairStyle,
      if (hat != null) 'hat': hat,
      if (spectacles != null) 'spectacles': spectacles,
      if (defaultPropId != null) 'default_prop_id': defaultPropId,
    });
  }

  BuddyLooksCompanion copyWith({
    Value<int>? id,
    Value<String>? skinHex,
    Value<String>? hairHex,
    Value<String>? jacketHex,
    Value<String>? shirtHex,
    Value<String>? pantsHex,
    Value<String>? shoesHex,
    Value<HairStyle>? hairStyle,
    Value<HatStyle>? hat,
    Value<bool>? spectacles,
    Value<String>? defaultPropId,
  }) {
    return BuddyLooksCompanion(
      id: id ?? this.id,
      skinHex: skinHex ?? this.skinHex,
      hairHex: hairHex ?? this.hairHex,
      jacketHex: jacketHex ?? this.jacketHex,
      shirtHex: shirtHex ?? this.shirtHex,
      pantsHex: pantsHex ?? this.pantsHex,
      shoesHex: shoesHex ?? this.shoesHex,
      hairStyle: hairStyle ?? this.hairStyle,
      hat: hat ?? this.hat,
      spectacles: spectacles ?? this.spectacles,
      defaultPropId: defaultPropId ?? this.defaultPropId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skinHex.present) {
      map['skin_hex'] = Variable<String>(skinHex.value);
    }
    if (hairHex.present) {
      map['hair_hex'] = Variable<String>(hairHex.value);
    }
    if (jacketHex.present) {
      map['jacket_hex'] = Variable<String>(jacketHex.value);
    }
    if (shirtHex.present) {
      map['shirt_hex'] = Variable<String>(shirtHex.value);
    }
    if (pantsHex.present) {
      map['pants_hex'] = Variable<String>(pantsHex.value);
    }
    if (shoesHex.present) {
      map['shoes_hex'] = Variable<String>(shoesHex.value);
    }
    if (hairStyle.present) {
      map['hair_style'] = Variable<String>(
        $BuddyLooksTable.$converterhairStyle.toSql(hairStyle.value),
      );
    }
    if (hat.present) {
      map['hat'] = Variable<String>(
        $BuddyLooksTable.$converterhat.toSql(hat.value),
      );
    }
    if (spectacles.present) {
      map['spectacles'] = Variable<bool>(spectacles.value);
    }
    if (defaultPropId.present) {
      map['default_prop_id'] = Variable<String>(defaultPropId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuddyLooksCompanion(')
          ..write('id: $id, ')
          ..write('skinHex: $skinHex, ')
          ..write('hairHex: $hairHex, ')
          ..write('jacketHex: $jacketHex, ')
          ..write('shirtHex: $shirtHex, ')
          ..write('pantsHex: $pantsHex, ')
          ..write('shoesHex: $shoesHex, ')
          ..write('hairStyle: $hairStyle, ')
          ..write('hat: $hat, ')
          ..write('spectacles: $spectacles, ')
          ..write('defaultPropId: $defaultPropId')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buddySizeMeta = const VerificationMeta(
    'buddySize',
  );
  @override
  late final GeneratedColumn<int> buddySize = GeneratedColumn<int>(
    'buddy_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walkSpeedMeta = const VerificationMeta(
    'walkSpeed',
  );
  @override
  late final GeneratedColumn<int> walkSpeed = GeneratedColumn<int>(
    'walk_speed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walkEnabledMeta = const VerificationMeta(
    'walkEnabled',
  );
  @override
  late final GeneratedColumn<bool> walkEnabled = GeneratedColumn<bool>(
    'walk_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("walk_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _buddyVisibleMeta = const VerificationMeta(
    'buddyVisible',
  );
  @override
  late final GeneratedColumn<bool> buddyVisible = GeneratedColumn<bool>(
    'buddy_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("buddy_visible" IN (0, 1))',
    ),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _snoozeMinutesMeta = const VerificationMeta(
    'snoozeMinutes',
  );
  @override
  late final GeneratedColumn<int> snoozeMinutes = GeneratedColumn<int>(
    'snooze_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoMissMinutesMeta = const VerificationMeta(
    'autoMissMinutes',
  );
  @override
  late final GeneratedColumn<int> autoMissMinutes = GeneratedColumn<int>(
    'auto_miss_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doNotDisturbMeta = const VerificationMeta(
    'doNotDisturb',
  );
  @override
  late final GeneratedColumn<bool> doNotDisturb = GeneratedColumn<bool>(
    'do_not_disturb',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("do_not_disturb" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String>
  themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ThemePreference>($SettingsTableTable.$converterthemeMode);
  static const VerificationMeta _launchAtLoginMeta = const VerificationMeta(
    'launchAtLogin',
  );
  @override
  late final GeneratedColumn<bool> launchAtLogin = GeneratedColumn<bool>(
    'launch_at_login',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("launch_at_login" IN (0, 1))',
    ),
  );
  static const VerificationMeta _focusPopupsMeta = const VerificationMeta(
    'focusPopups',
  );
  @override
  late final GeneratedColumn<bool> focusPopups = GeneratedColumn<bool>(
    'focus_popups',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("focus_popups" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buddyXMeta = const VerificationMeta('buddyX');
  @override
  late final GeneratedColumn<double> buddyX = GeneratedColumn<double>(
    'buddy_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buddyYMeta = const VerificationMeta('buddyY');
  @override
  late final GeneratedColumn<double> buddyY = GeneratedColumn<double>(
    'buddy_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userName,
    buddySize,
    walkSpeed,
    walkEnabled,
    buddyVisible,
    soundEnabled,
    snoozeMinutes,
    autoMissMinutes,
    doNotDisturb,
    themeMode,
    launchAtLogin,
    focusPopups,
    buddyX,
    buddyY,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('buddy_size')) {
      context.handle(
        _buddySizeMeta,
        buddySize.isAcceptableOrUnknown(data['buddy_size']!, _buddySizeMeta),
      );
    } else if (isInserting) {
      context.missing(_buddySizeMeta);
    }
    if (data.containsKey('walk_speed')) {
      context.handle(
        _walkSpeedMeta,
        walkSpeed.isAcceptableOrUnknown(data['walk_speed']!, _walkSpeedMeta),
      );
    } else if (isInserting) {
      context.missing(_walkSpeedMeta);
    }
    if (data.containsKey('walk_enabled')) {
      context.handle(
        _walkEnabledMeta,
        walkEnabled.isAcceptableOrUnknown(
          data['walk_enabled']!,
          _walkEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_walkEnabledMeta);
    }
    if (data.containsKey('buddy_visible')) {
      context.handle(
        _buddyVisibleMeta,
        buddyVisible.isAcceptableOrUnknown(
          data['buddy_visible']!,
          _buddyVisibleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_buddyVisibleMeta);
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soundEnabledMeta);
    }
    if (data.containsKey('snooze_minutes')) {
      context.handle(
        _snoozeMinutesMeta,
        snoozeMinutes.isAcceptableOrUnknown(
          data['snooze_minutes']!,
          _snoozeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snoozeMinutesMeta);
    }
    if (data.containsKey('auto_miss_minutes')) {
      context.handle(
        _autoMissMinutesMeta,
        autoMissMinutes.isAcceptableOrUnknown(
          data['auto_miss_minutes']!,
          _autoMissMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autoMissMinutesMeta);
    }
    if (data.containsKey('do_not_disturb')) {
      context.handle(
        _doNotDisturbMeta,
        doNotDisturb.isAcceptableOrUnknown(
          data['do_not_disturb']!,
          _doNotDisturbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_doNotDisturbMeta);
    }
    if (data.containsKey('launch_at_login')) {
      context.handle(
        _launchAtLoginMeta,
        launchAtLogin.isAcceptableOrUnknown(
          data['launch_at_login']!,
          _launchAtLoginMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_launchAtLoginMeta);
    }
    if (data.containsKey('focus_popups')) {
      context.handle(
        _focusPopupsMeta,
        focusPopups.isAcceptableOrUnknown(
          data['focus_popups']!,
          _focusPopupsMeta,
        ),
      );
    }
    if (data.containsKey('buddy_x')) {
      context.handle(
        _buddyXMeta,
        buddyX.isAcceptableOrUnknown(data['buddy_x']!, _buddyXMeta),
      );
    }
    if (data.containsKey('buddy_y')) {
      context.handle(
        _buddyYMeta,
        buddyY.isAcceptableOrUnknown(data['buddy_y']!, _buddyYMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      buddySize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buddy_size'],
      )!,
      walkSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}walk_speed'],
      )!,
      walkEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}walk_enabled'],
      )!,
      buddyVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}buddy_visible'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      snoozeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_minutes'],
      )!,
      autoMissMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_miss_minutes'],
      )!,
      doNotDisturb: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}do_not_disturb'],
      )!,
      themeMode: $SettingsTableTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      launchAtLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}launch_at_login'],
      )!,
      focusPopups: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}focus_popups'],
      )!,
      buddyX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}buddy_x'],
      ),
      buddyY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}buddy_y'],
      ),
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ThemePreference, String, String>
  $converterthemeMode = const EnumNameConverter<ThemePreference>(
    ThemePreference.values,
  );
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;
  final String userName;
  final int buddySize;
  final int walkSpeed;
  final bool walkEnabled;
  final bool buddyVisible;
  final bool soundEnabled;
  final int snoozeMinutes;
  final int autoMissMinutes;
  final bool doNotDisturb;
  final ThemePreference themeMode;
  final bool launchAtLogin;

  /// Added in schema v2.
  final bool focusPopups;
  final double? buddyX;
  final double? buddyY;
  const SettingsRow({
    required this.id,
    required this.userName,
    required this.buddySize,
    required this.walkSpeed,
    required this.walkEnabled,
    required this.buddyVisible,
    required this.soundEnabled,
    required this.snoozeMinutes,
    required this.autoMissMinutes,
    required this.doNotDisturb,
    required this.themeMode,
    required this.launchAtLogin,
    required this.focusPopups,
    this.buddyX,
    this.buddyY,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_name'] = Variable<String>(userName);
    map['buddy_size'] = Variable<int>(buddySize);
    map['walk_speed'] = Variable<int>(walkSpeed);
    map['walk_enabled'] = Variable<bool>(walkEnabled);
    map['buddy_visible'] = Variable<bool>(buddyVisible);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['snooze_minutes'] = Variable<int>(snoozeMinutes);
    map['auto_miss_minutes'] = Variable<int>(autoMissMinutes);
    map['do_not_disturb'] = Variable<bool>(doNotDisturb);
    {
      map['theme_mode'] = Variable<String>(
        $SettingsTableTable.$converterthemeMode.toSql(themeMode),
      );
    }
    map['launch_at_login'] = Variable<bool>(launchAtLogin);
    map['focus_popups'] = Variable<bool>(focusPopups);
    if (!nullToAbsent || buddyX != null) {
      map['buddy_x'] = Variable<double>(buddyX);
    }
    if (!nullToAbsent || buddyY != null) {
      map['buddy_y'] = Variable<double>(buddyY);
    }
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      userName: Value(userName),
      buddySize: Value(buddySize),
      walkSpeed: Value(walkSpeed),
      walkEnabled: Value(walkEnabled),
      buddyVisible: Value(buddyVisible),
      soundEnabled: Value(soundEnabled),
      snoozeMinutes: Value(snoozeMinutes),
      autoMissMinutes: Value(autoMissMinutes),
      doNotDisturb: Value(doNotDisturb),
      themeMode: Value(themeMode),
      launchAtLogin: Value(launchAtLogin),
      focusPopups: Value(focusPopups),
      buddyX: buddyX == null && nullToAbsent
          ? const Value.absent()
          : Value(buddyX),
      buddyY: buddyY == null && nullToAbsent
          ? const Value.absent()
          : Value(buddyY),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      userName: serializer.fromJson<String>(json['userName']),
      buddySize: serializer.fromJson<int>(json['buddySize']),
      walkSpeed: serializer.fromJson<int>(json['walkSpeed']),
      walkEnabled: serializer.fromJson<bool>(json['walkEnabled']),
      buddyVisible: serializer.fromJson<bool>(json['buddyVisible']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      snoozeMinutes: serializer.fromJson<int>(json['snoozeMinutes']),
      autoMissMinutes: serializer.fromJson<int>(json['autoMissMinutes']),
      doNotDisturb: serializer.fromJson<bool>(json['doNotDisturb']),
      themeMode: $SettingsTableTable.$converterthemeMode.fromJson(
        serializer.fromJson<String>(json['themeMode']),
      ),
      launchAtLogin: serializer.fromJson<bool>(json['launchAtLogin']),
      focusPopups: serializer.fromJson<bool>(json['focusPopups']),
      buddyX: serializer.fromJson<double?>(json['buddyX']),
      buddyY: serializer.fromJson<double?>(json['buddyY']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userName': serializer.toJson<String>(userName),
      'buddySize': serializer.toJson<int>(buddySize),
      'walkSpeed': serializer.toJson<int>(walkSpeed),
      'walkEnabled': serializer.toJson<bool>(walkEnabled),
      'buddyVisible': serializer.toJson<bool>(buddyVisible),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'snoozeMinutes': serializer.toJson<int>(snoozeMinutes),
      'autoMissMinutes': serializer.toJson<int>(autoMissMinutes),
      'doNotDisturb': serializer.toJson<bool>(doNotDisturb),
      'themeMode': serializer.toJson<String>(
        $SettingsTableTable.$converterthemeMode.toJson(themeMode),
      ),
      'launchAtLogin': serializer.toJson<bool>(launchAtLogin),
      'focusPopups': serializer.toJson<bool>(focusPopups),
      'buddyX': serializer.toJson<double?>(buddyX),
      'buddyY': serializer.toJson<double?>(buddyY),
    };
  }

  SettingsRow copyWith({
    int? id,
    String? userName,
    int? buddySize,
    int? walkSpeed,
    bool? walkEnabled,
    bool? buddyVisible,
    bool? soundEnabled,
    int? snoozeMinutes,
    int? autoMissMinutes,
    bool? doNotDisturb,
    ThemePreference? themeMode,
    bool? launchAtLogin,
    bool? focusPopups,
    Value<double?> buddyX = const Value.absent(),
    Value<double?> buddyY = const Value.absent(),
  }) => SettingsRow(
    id: id ?? this.id,
    userName: userName ?? this.userName,
    buddySize: buddySize ?? this.buddySize,
    walkSpeed: walkSpeed ?? this.walkSpeed,
    walkEnabled: walkEnabled ?? this.walkEnabled,
    buddyVisible: buddyVisible ?? this.buddyVisible,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    autoMissMinutes: autoMissMinutes ?? this.autoMissMinutes,
    doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    themeMode: themeMode ?? this.themeMode,
    launchAtLogin: launchAtLogin ?? this.launchAtLogin,
    focusPopups: focusPopups ?? this.focusPopups,
    buddyX: buddyX.present ? buddyX.value : this.buddyX,
    buddyY: buddyY.present ? buddyY.value : this.buddyY,
  );
  SettingsRow copyWithCompanion(SettingsTableCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      buddySize: data.buddySize.present ? data.buddySize.value : this.buddySize,
      walkSpeed: data.walkSpeed.present ? data.walkSpeed.value : this.walkSpeed,
      walkEnabled: data.walkEnabled.present
          ? data.walkEnabled.value
          : this.walkEnabled,
      buddyVisible: data.buddyVisible.present
          ? data.buddyVisible.value
          : this.buddyVisible,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      snoozeMinutes: data.snoozeMinutes.present
          ? data.snoozeMinutes.value
          : this.snoozeMinutes,
      autoMissMinutes: data.autoMissMinutes.present
          ? data.autoMissMinutes.value
          : this.autoMissMinutes,
      doNotDisturb: data.doNotDisturb.present
          ? data.doNotDisturb.value
          : this.doNotDisturb,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      launchAtLogin: data.launchAtLogin.present
          ? data.launchAtLogin.value
          : this.launchAtLogin,
      focusPopups: data.focusPopups.present
          ? data.focusPopups.value
          : this.focusPopups,
      buddyX: data.buddyX.present ? data.buddyX.value : this.buddyX,
      buddyY: data.buddyY.present ? data.buddyY.value : this.buddyY,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('buddySize: $buddySize, ')
          ..write('walkSpeed: $walkSpeed, ')
          ..write('walkEnabled: $walkEnabled, ')
          ..write('buddyVisible: $buddyVisible, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('autoMissMinutes: $autoMissMinutes, ')
          ..write('doNotDisturb: $doNotDisturb, ')
          ..write('themeMode: $themeMode, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('focusPopups: $focusPopups, ')
          ..write('buddyX: $buddyX, ')
          ..write('buddyY: $buddyY')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userName,
    buddySize,
    walkSpeed,
    walkEnabled,
    buddyVisible,
    soundEnabled,
    snoozeMinutes,
    autoMissMinutes,
    doNotDisturb,
    themeMode,
    launchAtLogin,
    focusPopups,
    buddyX,
    buddyY,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.buddySize == this.buddySize &&
          other.walkSpeed == this.walkSpeed &&
          other.walkEnabled == this.walkEnabled &&
          other.buddyVisible == this.buddyVisible &&
          other.soundEnabled == this.soundEnabled &&
          other.snoozeMinutes == this.snoozeMinutes &&
          other.autoMissMinutes == this.autoMissMinutes &&
          other.doNotDisturb == this.doNotDisturb &&
          other.themeMode == this.themeMode &&
          other.launchAtLogin == this.launchAtLogin &&
          other.focusPopups == this.focusPopups &&
          other.buddyX == this.buddyX &&
          other.buddyY == this.buddyY);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<String> userName;
  final Value<int> buddySize;
  final Value<int> walkSpeed;
  final Value<bool> walkEnabled;
  final Value<bool> buddyVisible;
  final Value<bool> soundEnabled;
  final Value<int> snoozeMinutes;
  final Value<int> autoMissMinutes;
  final Value<bool> doNotDisturb;
  final Value<ThemePreference> themeMode;
  final Value<bool> launchAtLogin;
  final Value<bool> focusPopups;
  final Value<double?> buddyX;
  final Value<double?> buddyY;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.buddySize = const Value.absent(),
    this.walkSpeed = const Value.absent(),
    this.walkEnabled = const Value.absent(),
    this.buddyVisible = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.autoMissMinutes = const Value.absent(),
    this.doNotDisturb = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.focusPopups = const Value.absent(),
    this.buddyX = const Value.absent(),
    this.buddyY = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String userName,
    required int buddySize,
    required int walkSpeed,
    required bool walkEnabled,
    required bool buddyVisible,
    required bool soundEnabled,
    required int snoozeMinutes,
    required int autoMissMinutes,
    required bool doNotDisturb,
    required ThemePreference themeMode,
    required bool launchAtLogin,
    this.focusPopups = const Value.absent(),
    this.buddyX = const Value.absent(),
    this.buddyY = const Value.absent(),
  }) : userName = Value(userName),
       buddySize = Value(buddySize),
       walkSpeed = Value(walkSpeed),
       walkEnabled = Value(walkEnabled),
       buddyVisible = Value(buddyVisible),
       soundEnabled = Value(soundEnabled),
       snoozeMinutes = Value(snoozeMinutes),
       autoMissMinutes = Value(autoMissMinutes),
       doNotDisturb = Value(doNotDisturb),
       themeMode = Value(themeMode),
       launchAtLogin = Value(launchAtLogin);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<String>? userName,
    Expression<int>? buddySize,
    Expression<int>? walkSpeed,
    Expression<bool>? walkEnabled,
    Expression<bool>? buddyVisible,
    Expression<bool>? soundEnabled,
    Expression<int>? snoozeMinutes,
    Expression<int>? autoMissMinutes,
    Expression<bool>? doNotDisturb,
    Expression<String>? themeMode,
    Expression<bool>? launchAtLogin,
    Expression<bool>? focusPopups,
    Expression<double>? buddyX,
    Expression<double>? buddyY,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (buddySize != null) 'buddy_size': buddySize,
      if (walkSpeed != null) 'walk_speed': walkSpeed,
      if (walkEnabled != null) 'walk_enabled': walkEnabled,
      if (buddyVisible != null) 'buddy_visible': buddyVisible,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (snoozeMinutes != null) 'snooze_minutes': snoozeMinutes,
      if (autoMissMinutes != null) 'auto_miss_minutes': autoMissMinutes,
      if (doNotDisturb != null) 'do_not_disturb': doNotDisturb,
      if (themeMode != null) 'theme_mode': themeMode,
      if (launchAtLogin != null) 'launch_at_login': launchAtLogin,
      if (focusPopups != null) 'focus_popups': focusPopups,
      if (buddyX != null) 'buddy_x': buddyX,
      if (buddyY != null) 'buddy_y': buddyY,
    });
  }

  SettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userName,
    Value<int>? buddySize,
    Value<int>? walkSpeed,
    Value<bool>? walkEnabled,
    Value<bool>? buddyVisible,
    Value<bool>? soundEnabled,
    Value<int>? snoozeMinutes,
    Value<int>? autoMissMinutes,
    Value<bool>? doNotDisturb,
    Value<ThemePreference>? themeMode,
    Value<bool>? launchAtLogin,
    Value<bool>? focusPopups,
    Value<double?>? buddyX,
    Value<double?>? buddyY,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      buddySize: buddySize ?? this.buddySize,
      walkSpeed: walkSpeed ?? this.walkSpeed,
      walkEnabled: walkEnabled ?? this.walkEnabled,
      buddyVisible: buddyVisible ?? this.buddyVisible,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      autoMissMinutes: autoMissMinutes ?? this.autoMissMinutes,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      themeMode: themeMode ?? this.themeMode,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      focusPopups: focusPopups ?? this.focusPopups,
      buddyX: buddyX ?? this.buddyX,
      buddyY: buddyY ?? this.buddyY,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (buddySize.present) {
      map['buddy_size'] = Variable<int>(buddySize.value);
    }
    if (walkSpeed.present) {
      map['walk_speed'] = Variable<int>(walkSpeed.value);
    }
    if (walkEnabled.present) {
      map['walk_enabled'] = Variable<bool>(walkEnabled.value);
    }
    if (buddyVisible.present) {
      map['buddy_visible'] = Variable<bool>(buddyVisible.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (snoozeMinutes.present) {
      map['snooze_minutes'] = Variable<int>(snoozeMinutes.value);
    }
    if (autoMissMinutes.present) {
      map['auto_miss_minutes'] = Variable<int>(autoMissMinutes.value);
    }
    if (doNotDisturb.present) {
      map['do_not_disturb'] = Variable<bool>(doNotDisturb.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(
        $SettingsTableTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (launchAtLogin.present) {
      map['launch_at_login'] = Variable<bool>(launchAtLogin.value);
    }
    if (focusPopups.present) {
      map['focus_popups'] = Variable<bool>(focusPopups.value);
    }
    if (buddyX.present) {
      map['buddy_x'] = Variable<double>(buddyX.value);
    }
    if (buddyY.present) {
      map['buddy_y'] = Variable<double>(buddyY.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('buddySize: $buddySize, ')
          ..write('walkSpeed: $walkSpeed, ')
          ..write('walkEnabled: $walkEnabled, ')
          ..write('buddyVisible: $buddyVisible, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('autoMissMinutes: $autoMissMinutes, ')
          ..write('doNotDisturb: $doNotDisturb, ')
          ..write('themeMode: $themeMode, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('focusPopups: $focusPopups, ')
          ..write('buddyX: $buddyX, ')
          ..write('buddyY: $buddyY')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  late final $BuddyLooksTable buddyLooks = $BuddyLooksTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final Index logEntriesAt = Index(
    'log_entries_at',
    'CREATE INDEX log_entries_at ON log_entries (at)',
  );
  late final Index logEntriesReminderAt = Index(
    'log_entries_reminder_at',
    'CREATE INDEX log_entries_reminder_at ON log_entries (reminder_id, at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    reminders,
    logEntries,
    buddyLooks,
    settingsTable,
    logEntriesAt,
    logEntriesReminderAt,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String emoji,
      required String colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'categories__id__reminders__category_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool remindersRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                emoji: emoji,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String emoji,
                required String colorHex,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (remindersRefs) db.reminders],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      ReminderRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._remindersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).remindersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool remindersRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String title,
      required String emoji,
      required String messageTemplate,
      required String categoryId,
      required ScheduleType scheduleType,
      required int everyMinutes,
      Value<String?> activeFrom,
      Value<String?> activeTo,
      required String timeOfDay,
      required List<int> daysOfWeek,
      Value<String?> date,
      required int dailyGoal,
      required String goalUnit,
      required String propId,
      required String doneLabel,
      required bool enabled,
      Value<int?> nextDueAt,
      Value<String> source,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> emoji,
      Value<String> messageTemplate,
      Value<String> categoryId,
      Value<ScheduleType> scheduleType,
      Value<int> everyMinutes,
      Value<String?> activeFrom,
      Value<String?> activeTo,
      Value<String> timeOfDay,
      Value<List<int>> daysOfWeek,
      Value<String?> date,
      Value<int> dailyGoal,
      Value<String> goalUnit,
      Value<String> propId,
      Value<String> doneLabel,
      Value<bool> enabled,
      Value<int?> nextDueAt,
      Value<String> source,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('reminders__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageTemplate => $composableBuilder(
    column: $table.messageTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleType, ScheduleType, String>
  get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get everyMinutes => $composableBuilder(
    column: $table.everyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeTo => $composableBuilder(
    column: $table.activeTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get daysOfWeek =>
      $composableBuilder(
        column: $table.daysOfWeek,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalUnit => $composableBuilder(
    column: $table.goalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propId => $composableBuilder(
    column: $table.propId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneLabel => $composableBuilder(
    column: $table.doneLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
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

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageTemplate => $composableBuilder(
    column: $table.messageTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get everyMinutes => $composableBuilder(
    column: $table.everyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeTo => $composableBuilder(
    column: $table.activeTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalUnit => $composableBuilder(
    column: $table.goalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propId => $composableBuilder(
    column: $table.propId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneLabel => $composableBuilder(
    column: $table.doneLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
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

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get messageTemplate => $composableBuilder(
    column: $table.messageTemplate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ScheduleType, String> get scheduleType =>
      $composableBuilder(
        column: $table.scheduleType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get everyMinutes => $composableBuilder(
    column: $table.everyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeTo =>
      $composableBuilder(column: $table.activeTo, builder: (column) => column);

  GeneratedColumn<String> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get daysOfWeek =>
      $composableBuilder(
        column: $table.daysOfWeek,
        builder: (column) => column,
      );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get dailyGoal =>
      $composableBuilder(column: $table.dailyGoal, builder: (column) => column);

  GeneratedColumn<String> get goalUnit =>
      $composableBuilder(column: $table.goalUnit, builder: (column) => column);

  GeneratedColumn<String> get propId =>
      $composableBuilder(column: $table.propId, builder: (column) => column);

  GeneratedColumn<String> get doneLabel =>
      $composableBuilder(column: $table.doneLabel, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> messageTemplate = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<ScheduleType> scheduleType = const Value.absent(),
                Value<int> everyMinutes = const Value.absent(),
                Value<String?> activeFrom = const Value.absent(),
                Value<String?> activeTo = const Value.absent(),
                Value<String> timeOfDay = const Value.absent(),
                Value<List<int>> daysOfWeek = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<String> goalUnit = const Value.absent(),
                Value<String> propId = const Value.absent(),
                Value<String> doneLabel = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int?> nextDueAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                emoji: emoji,
                messageTemplate: messageTemplate,
                categoryId: categoryId,
                scheduleType: scheduleType,
                everyMinutes: everyMinutes,
                activeFrom: activeFrom,
                activeTo: activeTo,
                timeOfDay: timeOfDay,
                daysOfWeek: daysOfWeek,
                date: date,
                dailyGoal: dailyGoal,
                goalUnit: goalUnit,
                propId: propId,
                doneLabel: doneLabel,
                enabled: enabled,
                nextDueAt: nextDueAt,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String emoji,
                required String messageTemplate,
                required String categoryId,
                required ScheduleType scheduleType,
                required int everyMinutes,
                Value<String?> activeFrom = const Value.absent(),
                Value<String?> activeTo = const Value.absent(),
                required String timeOfDay,
                required List<int> daysOfWeek,
                Value<String?> date = const Value.absent(),
                required int dailyGoal,
                required String goalUnit,
                required String propId,
                required String doneLabel,
                required bool enabled,
                Value<int?> nextDueAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                emoji: emoji,
                messageTemplate: messageTemplate,
                categoryId: categoryId,
                scheduleType: scheduleType,
                everyMinutes: everyMinutes,
                activeFrom: activeFrom,
                activeTo: activeTo,
                timeOfDay: timeOfDay,
                daysOfWeek: daysOfWeek,
                date: date,
                dailyGoal: dailyGoal,
                goalUnit: goalUnit,
                propId: propId,
                doneLabel: doneLabel,
                enabled: enabled,
                nextDueAt: nextDueAt,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$RemindersTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._categoryIdTable(db)
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

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$LogEntriesTableCreateCompanionBuilder =
    LogEntriesCompanion Function({
      required String id,
      Value<String?> reminderId,
      Value<String?> categoryId,
      required int at,
      required LogAction action,
      Value<int> responseSeconds,
      Value<bool> manual,
      Value<bool> sample,
      Value<int> rowid,
    });
typedef $$LogEntriesTableUpdateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<String> id,
      Value<String?> reminderId,
      Value<String?> categoryId,
      Value<int> at,
      Value<LogAction> action,
      Value<int> responseSeconds,
      Value<bool> manual,
      Value<bool> sample,
      Value<int> rowid,
    });

class $$LogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
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

  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogAction, LogAction, String> get action =>
      $composableBuilder(
        column: $table.action,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get responseSeconds => $composableBuilder(
    column: $table.responseSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get manual => $composableBuilder(
    column: $table.manual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sample => $composableBuilder(
    column: $table.sample,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseSeconds => $composableBuilder(
    column: $table.responseSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get manual => $composableBuilder(
    column: $table.manual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sample => $composableBuilder(
    column: $table.sample,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogAction, String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get responseSeconds => $composableBuilder(
    column: $table.responseSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get manual =>
      $composableBuilder(column: $table.manual, builder: (column) => column);

  GeneratedColumn<bool> get sample =>
      $composableBuilder(column: $table.sample, builder: (column) => column);
}

class $$LogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogEntriesTable,
          LogEntryRow,
          $$LogEntriesTableFilterComposer,
          $$LogEntriesTableOrderingComposer,
          $$LogEntriesTableAnnotationComposer,
          $$LogEntriesTableCreateCompanionBuilder,
          $$LogEntriesTableUpdateCompanionBuilder,
          (
            LogEntryRow,
            BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntryRow>,
          ),
          LogEntryRow,
          PrefetchHooks Function()
        > {
  $$LogEntriesTableTableManager(_$AppDatabase db, $LogEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> reminderId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<LogAction> action = const Value.absent(),
                Value<int> responseSeconds = const Value.absent(),
                Value<bool> manual = const Value.absent(),
                Value<bool> sample = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogEntriesCompanion(
                id: id,
                reminderId: reminderId,
                categoryId: categoryId,
                at: at,
                action: action,
                responseSeconds: responseSeconds,
                manual: manual,
                sample: sample,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> reminderId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required int at,
                required LogAction action,
                Value<int> responseSeconds = const Value.absent(),
                Value<bool> manual = const Value.absent(),
                Value<bool> sample = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogEntriesCompanion.insert(
                id: id,
                reminderId: reminderId,
                categoryId: categoryId,
                at: at,
                action: action,
                responseSeconds: responseSeconds,
                manual: manual,
                sample: sample,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LogEntriesTable, LogEntryRow>(table),
                  BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogEntriesTable,
      LogEntryRow,
      $$LogEntriesTableFilterComposer,
      $$LogEntriesTableOrderingComposer,
      $$LogEntriesTableAnnotationComposer,
      $$LogEntriesTableCreateCompanionBuilder,
      $$LogEntriesTableUpdateCompanionBuilder,
      (
        LogEntryRow,
        BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntryRow>,
      ),
      LogEntryRow,
      PrefetchHooks Function()
    >;
typedef $$BuddyLooksTableCreateCompanionBuilder =
    BuddyLooksCompanion Function({
      Value<int> id,
      required String skinHex,
      required String hairHex,
      required String jacketHex,
      required String shirtHex,
      required String pantsHex,
      required String shoesHex,
      required HairStyle hairStyle,
      required HatStyle hat,
      required bool spectacles,
      required String defaultPropId,
    });
typedef $$BuddyLooksTableUpdateCompanionBuilder =
    BuddyLooksCompanion Function({
      Value<int> id,
      Value<String> skinHex,
      Value<String> hairHex,
      Value<String> jacketHex,
      Value<String> shirtHex,
      Value<String> pantsHex,
      Value<String> shoesHex,
      Value<HairStyle> hairStyle,
      Value<HatStyle> hat,
      Value<bool> spectacles,
      Value<String> defaultPropId,
    });

class $$BuddyLooksTableFilterComposer
    extends Composer<_$AppDatabase, $BuddyLooksTable> {
  $$BuddyLooksTableFilterComposer({
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

  ColumnFilters<String> get skinHex => $composableBuilder(
    column: $table.skinHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hairHex => $composableBuilder(
    column: $table.hairHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jacketHex => $composableBuilder(
    column: $table.jacketHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shirtHex => $composableBuilder(
    column: $table.shirtHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pantsHex => $composableBuilder(
    column: $table.pantsHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shoesHex => $composableBuilder(
    column: $table.shoesHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HairStyle, HairStyle, String> get hairStyle =>
      $composableBuilder(
        column: $table.hairStyle,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<HatStyle, HatStyle, String> get hat =>
      $composableBuilder(
        column: $table.hat,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get spectacles => $composableBuilder(
    column: $table.spectacles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultPropId => $composableBuilder(
    column: $table.defaultPropId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BuddyLooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BuddyLooksTable> {
  $$BuddyLooksTableOrderingComposer({
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

  ColumnOrderings<String> get skinHex => $composableBuilder(
    column: $table.skinHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hairHex => $composableBuilder(
    column: $table.hairHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jacketHex => $composableBuilder(
    column: $table.jacketHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shirtHex => $composableBuilder(
    column: $table.shirtHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pantsHex => $composableBuilder(
    column: $table.pantsHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shoesHex => $composableBuilder(
    column: $table.shoesHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hairStyle => $composableBuilder(
    column: $table.hairStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hat => $composableBuilder(
    column: $table.hat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get spectacles => $composableBuilder(
    column: $table.spectacles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultPropId => $composableBuilder(
    column: $table.defaultPropId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuddyLooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuddyLooksTable> {
  $$BuddyLooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get skinHex =>
      $composableBuilder(column: $table.skinHex, builder: (column) => column);

  GeneratedColumn<String> get hairHex =>
      $composableBuilder(column: $table.hairHex, builder: (column) => column);

  GeneratedColumn<String> get jacketHex =>
      $composableBuilder(column: $table.jacketHex, builder: (column) => column);

  GeneratedColumn<String> get shirtHex =>
      $composableBuilder(column: $table.shirtHex, builder: (column) => column);

  GeneratedColumn<String> get pantsHex =>
      $composableBuilder(column: $table.pantsHex, builder: (column) => column);

  GeneratedColumn<String> get shoesHex =>
      $composableBuilder(column: $table.shoesHex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HairStyle, String> get hairStyle =>
      $composableBuilder(column: $table.hairStyle, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HatStyle, String> get hat =>
      $composableBuilder(column: $table.hat, builder: (column) => column);

  GeneratedColumn<bool> get spectacles => $composableBuilder(
    column: $table.spectacles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultPropId => $composableBuilder(
    column: $table.defaultPropId,
    builder: (column) => column,
  );
}

class $$BuddyLooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuddyLooksTable,
          BuddyLookRow,
          $$BuddyLooksTableFilterComposer,
          $$BuddyLooksTableOrderingComposer,
          $$BuddyLooksTableAnnotationComposer,
          $$BuddyLooksTableCreateCompanionBuilder,
          $$BuddyLooksTableUpdateCompanionBuilder,
          (
            BuddyLookRow,
            BaseReferences<_$AppDatabase, $BuddyLooksTable, BuddyLookRow>,
          ),
          BuddyLookRow,
          PrefetchHooks Function()
        > {
  $$BuddyLooksTableTableManager(_$AppDatabase db, $BuddyLooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuddyLooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuddyLooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuddyLooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> skinHex = const Value.absent(),
                Value<String> hairHex = const Value.absent(),
                Value<String> jacketHex = const Value.absent(),
                Value<String> shirtHex = const Value.absent(),
                Value<String> pantsHex = const Value.absent(),
                Value<String> shoesHex = const Value.absent(),
                Value<HairStyle> hairStyle = const Value.absent(),
                Value<HatStyle> hat = const Value.absent(),
                Value<bool> spectacles = const Value.absent(),
                Value<String> defaultPropId = const Value.absent(),
              }) => BuddyLooksCompanion(
                id: id,
                skinHex: skinHex,
                hairHex: hairHex,
                jacketHex: jacketHex,
                shirtHex: shirtHex,
                pantsHex: pantsHex,
                shoesHex: shoesHex,
                hairStyle: hairStyle,
                hat: hat,
                spectacles: spectacles,
                defaultPropId: defaultPropId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String skinHex,
                required String hairHex,
                required String jacketHex,
                required String shirtHex,
                required String pantsHex,
                required String shoesHex,
                required HairStyle hairStyle,
                required HatStyle hat,
                required bool spectacles,
                required String defaultPropId,
              }) => BuddyLooksCompanion.insert(
                id: id,
                skinHex: skinHex,
                hairHex: hairHex,
                jacketHex: jacketHex,
                shirtHex: shirtHex,
                pantsHex: pantsHex,
                shoesHex: shoesHex,
                hairStyle: hairStyle,
                hat: hat,
                spectacles: spectacles,
                defaultPropId: defaultPropId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BuddyLooksTable, BuddyLookRow>(table),
                  BaseReferences<_$AppDatabase, $BuddyLooksTable, BuddyLookRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BuddyLooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuddyLooksTable,
      BuddyLookRow,
      $$BuddyLooksTableFilterComposer,
      $$BuddyLooksTableOrderingComposer,
      $$BuddyLooksTableAnnotationComposer,
      $$BuddyLooksTableCreateCompanionBuilder,
      $$BuddyLooksTableUpdateCompanionBuilder,
      (
        BuddyLookRow,
        BaseReferences<_$AppDatabase, $BuddyLooksTable, BuddyLookRow>,
      ),
      BuddyLookRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      required String userName,
      required int buddySize,
      required int walkSpeed,
      required bool walkEnabled,
      required bool buddyVisible,
      required bool soundEnabled,
      required int snoozeMinutes,
      required int autoMissMinutes,
      required bool doNotDisturb,
      required ThemePreference themeMode,
      required bool launchAtLogin,
      Value<bool> focusPopups,
      Value<double?> buddyX,
      Value<double?> buddyY,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<String> userName,
      Value<int> buddySize,
      Value<int> walkSpeed,
      Value<bool> walkEnabled,
      Value<bool> buddyVisible,
      Value<bool> soundEnabled,
      Value<int> snoozeMinutes,
      Value<int> autoMissMinutes,
      Value<bool> doNotDisturb,
      Value<ThemePreference> themeMode,
      Value<bool> launchAtLogin,
      Value<bool> focusPopups,
      Value<double?> buddyX,
      Value<double?> buddyY,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
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

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buddySize => $composableBuilder(
    column: $table.buddySize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walkSpeed => $composableBuilder(
    column: $table.walkSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get walkEnabled => $composableBuilder(
    column: $table.walkEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get buddyVisible => $composableBuilder(
    column: $table.buddyVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoMissMinutes => $composableBuilder(
    column: $table.autoMissMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get doNotDisturb => $composableBuilder(
    column: $table.doNotDisturb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get focusPopups => $composableBuilder(
    column: $table.focusPopups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get buddyX => $composableBuilder(
    column: $table.buddyX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get buddyY => $composableBuilder(
    column: $table.buddyY,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buddySize => $composableBuilder(
    column: $table.buddySize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walkSpeed => $composableBuilder(
    column: $table.walkSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get walkEnabled => $composableBuilder(
    column: $table.walkEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get buddyVisible => $composableBuilder(
    column: $table.buddyVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoMissMinutes => $composableBuilder(
    column: $table.autoMissMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get doNotDisturb => $composableBuilder(
    column: $table.doNotDisturb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get focusPopups => $composableBuilder(
    column: $table.focusPopups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get buddyX => $composableBuilder(
    column: $table.buddyX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get buddyY => $composableBuilder(
    column: $table.buddyY,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<int> get buddySize =>
      $composableBuilder(column: $table.buddySize, builder: (column) => column);

  GeneratedColumn<int> get walkSpeed =>
      $composableBuilder(column: $table.walkSpeed, builder: (column) => column);

  GeneratedColumn<bool> get walkEnabled => $composableBuilder(
    column: $table.walkEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get buddyVisible => $composableBuilder(
    column: $table.buddyVisible,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoMissMinutes => $composableBuilder(
    column: $table.autoMissMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get doNotDisturb => $composableBuilder(
    column: $table.doNotDisturb,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ThemePreference, String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get focusPopups => $composableBuilder(
    column: $table.focusPopups,
    builder: (column) => column,
  );

  GeneratedColumn<double> get buddyX =>
      $composableBuilder(column: $table.buddyX, builder: (column) => column);

  GeneratedColumn<double> get buddyY =>
      $composableBuilder(column: $table.buddyY, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsRow,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<int> buddySize = const Value.absent(),
                Value<int> walkSpeed = const Value.absent(),
                Value<bool> walkEnabled = const Value.absent(),
                Value<bool> buddyVisible = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> autoMissMinutes = const Value.absent(),
                Value<bool> doNotDisturb = const Value.absent(),
                Value<ThemePreference> themeMode = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> focusPopups = const Value.absent(),
                Value<double?> buddyX = const Value.absent(),
                Value<double?> buddyY = const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                userName: userName,
                buddySize: buddySize,
                walkSpeed: walkSpeed,
                walkEnabled: walkEnabled,
                buddyVisible: buddyVisible,
                soundEnabled: soundEnabled,
                snoozeMinutes: snoozeMinutes,
                autoMissMinutes: autoMissMinutes,
                doNotDisturb: doNotDisturb,
                themeMode: themeMode,
                launchAtLogin: launchAtLogin,
                focusPopups: focusPopups,
                buddyX: buddyX,
                buddyY: buddyY,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userName,
                required int buddySize,
                required int walkSpeed,
                required bool walkEnabled,
                required bool buddyVisible,
                required bool soundEnabled,
                required int snoozeMinutes,
                required int autoMissMinutes,
                required bool doNotDisturb,
                required ThemePreference themeMode,
                required bool launchAtLogin,
                Value<bool> focusPopups = const Value.absent(),
                Value<double?> buddyX = const Value.absent(),
                Value<double?> buddyY = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                userName: userName,
                buddySize: buddySize,
                walkSpeed: walkSpeed,
                walkEnabled: walkEnabled,
                buddyVisible: buddyVisible,
                soundEnabled: soundEnabled,
                snoozeMinutes: snoozeMinutes,
                autoMissMinutes: autoMissMinutes,
                doNotDisturb: doNotDisturb,
                themeMode: themeMode,
                launchAtLogin: launchAtLogin,
                focusPopups: focusPopups,
                buddyX: buddyX,
                buddyY: buddyY,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTableTable, SettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsTableTable,
                    SettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsRow,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
  $$BuddyLooksTableTableManager get buddyLooks =>
      $$BuddyLooksTableTableManager(_db, _db.buddyLooks);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
