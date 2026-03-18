// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecipesTable extends Recipes
    with TableInfo<$RecipesTable, RecipeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientsMeta = const VerificationMeta(
    'ingredients',
  );
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
    'ingredients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cookingTimeMeta = const VerificationMeta(
    'cookingTime',
  );
  @override
  late final GeneratedColumn<String> cookingTime = GeneratedColumn<String>(
    'cooking_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<String> servings = GeneratedColumn<String>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    ingredients,
    steps,
    cookingTime,
    servings,
    isFavorite,
    createdAt,
    imageUrl,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeEntity> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('ingredients')) {
      context.handle(
        _ingredientsMeta,
        ingredients.isAcceptableOrUnknown(
          data['ingredients']!,
          _ingredientsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientsMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('cooking_time')) {
      context.handle(
        _cookingTimeMeta,
        cookingTime.isAcceptableOrUnknown(
          data['cooking_time']!,
          _cookingTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cookingTimeMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    } else if (isInserting) {
      context.missing(_servingsMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
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
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      ingredients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      )!,
      cookingTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cooking_time'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}servings'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class RecipeEntity extends DataClass implements Insertable<RecipeEntity> {
  final String id;
  final String name;
  final String description;
  final String ingredients;
  final String steps;
  final String cookingTime;
  final String servings;
  final bool isFavorite;
  final int createdAt;
  final String? imageUrl;
  final String? source;
  const RecipeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.servings,
    required this.isFavorite,
    required this.createdAt,
    this.imageUrl,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['ingredients'] = Variable<String>(ingredients);
    map['steps'] = Variable<String>(steps);
    map['cooking_time'] = Variable<String>(cookingTime);
    map['servings'] = Variable<String>(servings);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      ingredients: Value(ingredients),
      steps: Value(steps),
      cookingTime: Value(cookingTime),
      servings: Value(servings),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
    );
  }

  factory RecipeEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      ingredients: serializer.fromJson<String>(json['ingredients']),
      steps: serializer.fromJson<String>(json['steps']),
      cookingTime: serializer.fromJson<String>(json['cookingTime']),
      servings: serializer.fromJson<String>(json['servings']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'ingredients': serializer.toJson<String>(ingredients),
      'steps': serializer.toJson<String>(steps),
      'cookingTime': serializer.toJson<String>(cookingTime),
      'servings': serializer.toJson<String>(servings),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<int>(createdAt),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'source': serializer.toJson<String?>(source),
    };
  }

  RecipeEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? ingredients,
    String? steps,
    String? cookingTime,
    String? servings,
    bool? isFavorite,
    int? createdAt,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> source = const Value.absent(),
  }) => RecipeEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps,
    cookingTime: cookingTime ?? this.cookingTime,
    servings: servings ?? this.servings,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    source: source.present ? source.value : this.source,
  );
  RecipeEntity copyWithCompanion(RecipesCompanion data) {
    return RecipeEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      ingredients: data.ingredients.present
          ? data.ingredients.value
          : this.ingredients,
      steps: data.steps.present ? data.steps.value : this.steps,
      cookingTime: data.cookingTime.present
          ? data.cookingTime.value
          : this.cookingTime,
      servings: data.servings.present ? data.servings.value : this.servings,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('cookingTime: $cookingTime, ')
          ..write('servings: $servings, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    ingredients,
    steps,
    cookingTime,
    servings,
    isFavorite,
    createdAt,
    imageUrl,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.ingredients == this.ingredients &&
          other.steps == this.steps &&
          other.cookingTime == this.cookingTime &&
          other.servings == this.servings &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.imageUrl == this.imageUrl &&
          other.source == this.source);
}

class RecipesCompanion extends UpdateCompanion<RecipeEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> ingredients;
  final Value<String> steps;
  final Value<String> cookingTime;
  final Value<String> servings;
  final Value<bool> isFavorite;
  final Value<int> createdAt;
  final Value<String?> imageUrl;
  final Value<String?> source;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.steps = const Value.absent(),
    this.cookingTime = const Value.absent(),
    this.servings = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String name,
    required String description,
    required String ingredients,
    required String steps,
    required String cookingTime,
    required String servings,
    this.isFavorite = const Value.absent(),
    required int createdAt,
    this.imageUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       ingredients = Value(ingredients),
       steps = Value(steps),
       cookingTime = Value(cookingTime),
       servings = Value(servings),
       createdAt = Value(createdAt);
  static Insertable<RecipeEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? ingredients,
    Expression<String>? steps,
    Expression<String>? cookingTime,
    Expression<String>? servings,
    Expression<bool>? isFavorite,
    Expression<int>? createdAt,
    Expression<String>? imageUrl,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (ingredients != null) 'ingredients': ingredients,
      if (steps != null) 'steps': steps,
      if (cookingTime != null) 'cooking_time': cookingTime,
      if (servings != null) 'servings': servings,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (imageUrl != null) 'image_url': imageUrl,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? ingredients,
    Value<String>? steps,
    Value<String>? cookingTime,
    Value<String>? servings,
    Value<bool>? isFavorite,
    Value<int>? createdAt,
    Value<String?>? imageUrl,
    Value<String?>? source,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (cookingTime.present) {
      map['cooking_time'] = Variable<String>(cookingTime.value);
    }
    if (servings.present) {
      map['servings'] = Variable<String>(servings.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('cookingTime: $cookingTime, ')
          ..write('servings: $servings, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserRecipesTable extends UserRecipes
    with TableInfo<$UserRecipesTable, UserRecipeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRecipesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientsMeta = const VerificationMeta(
    'ingredients',
  );
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
    'ingredients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverEmojiMeta = const VerificationMeta(
    'coverEmoji',
  );
  @override
  late final GeneratedColumn<String> coverEmoji = GeneratedColumn<String>(
    'cover_emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🍽'),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    ingredients,
    steps,
    coverEmoji,
    imageUrl,
    isPublic,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRecipeEntity> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ingredients')) {
      context.handle(
        _ingredientsMeta,
        ingredients.isAcceptableOrUnknown(
          data['ingredients']!,
          _ingredientsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientsMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('cover_emoji')) {
      context.handle(
        _coverEmojiMeta,
        coverEmoji.isAcceptableOrUnknown(data['cover_emoji']!, _coverEmojiMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRecipeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRecipeEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      ingredients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      )!,
      coverEmoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_emoji'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserRecipesTable createAlias(String alias) {
    return $UserRecipesTable(attachedDatabase, alias);
  }
}

class UserRecipeEntity extends DataClass
    implements Insertable<UserRecipeEntity> {
  final String id;
  final String name;
  final String? description;
  final String ingredients;
  final String steps;
  final String coverEmoji;
  final String? imageUrl;
  final bool isPublic;
  final int createdAt;
  const UserRecipeEntity({
    required this.id,
    required this.name,
    this.description,
    required this.ingredients,
    required this.steps,
    required this.coverEmoji,
    this.imageUrl,
    required this.isPublic,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['ingredients'] = Variable<String>(ingredients);
    map['steps'] = Variable<String>(steps);
    map['cover_emoji'] = Variable<String>(coverEmoji);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_public'] = Variable<bool>(isPublic);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  UserRecipesCompanion toCompanion(bool nullToAbsent) {
    return UserRecipesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      ingredients: Value(ingredients),
      steps: Value(steps),
      coverEmoji: Value(coverEmoji),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isPublic: Value(isPublic),
      createdAt: Value(createdAt),
    );
  }

  factory UserRecipeEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRecipeEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      ingredients: serializer.fromJson<String>(json['ingredients']),
      steps: serializer.fromJson<String>(json['steps']),
      coverEmoji: serializer.fromJson<String>(json['coverEmoji']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'ingredients': serializer.toJson<String>(ingredients),
      'steps': serializer.toJson<String>(steps),
      'coverEmoji': serializer.toJson<String>(coverEmoji),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isPublic': serializer.toJson<bool>(isPublic),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  UserRecipeEntity copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? ingredients,
    String? steps,
    String? coverEmoji,
    Value<String?> imageUrl = const Value.absent(),
    bool? isPublic,
    int? createdAt,
  }) => UserRecipeEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps,
    coverEmoji: coverEmoji ?? this.coverEmoji,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    isPublic: isPublic ?? this.isPublic,
    createdAt: createdAt ?? this.createdAt,
  );
  UserRecipeEntity copyWithCompanion(UserRecipesCompanion data) {
    return UserRecipeEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      ingredients: data.ingredients.present
          ? data.ingredients.value
          : this.ingredients,
      steps: data.steps.present ? data.steps.value : this.steps,
      coverEmoji: data.coverEmoji.present
          ? data.coverEmoji.value
          : this.coverEmoji,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRecipeEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('coverEmoji: $coverEmoji, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isPublic: $isPublic, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    ingredients,
    steps,
    coverEmoji,
    imageUrl,
    isPublic,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRecipeEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.ingredients == this.ingredients &&
          other.steps == this.steps &&
          other.coverEmoji == this.coverEmoji &&
          other.imageUrl == this.imageUrl &&
          other.isPublic == this.isPublic &&
          other.createdAt == this.createdAt);
}

class UserRecipesCompanion extends UpdateCompanion<UserRecipeEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> ingredients;
  final Value<String> steps;
  final Value<String> coverEmoji;
  final Value<String?> imageUrl;
  final Value<bool> isPublic;
  final Value<int> createdAt;
  final Value<int> rowid;
  const UserRecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.steps = const Value.absent(),
    this.coverEmoji = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRecipesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String ingredients,
    required String steps,
    this.coverEmoji = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isPublic = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       ingredients = Value(ingredients),
       steps = Value(steps),
       createdAt = Value(createdAt);
  static Insertable<UserRecipeEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? ingredients,
    Expression<String>? steps,
    Expression<String>? coverEmoji,
    Expression<String>? imageUrl,
    Expression<bool>? isPublic,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (ingredients != null) 'ingredients': ingredients,
      if (steps != null) 'steps': steps,
      if (coverEmoji != null) 'cover_emoji': coverEmoji,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isPublic != null) 'is_public': isPublic,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? ingredients,
    Value<String>? steps,
    Value<String>? coverEmoji,
    Value<String?>? imageUrl,
    Value<bool>? isPublic,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return UserRecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (coverEmoji.present) {
      map['cover_emoji'] = Variable<String>(coverEmoji.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('coverEmoji: $coverEmoji, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isPublic: $isPublic, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $UserRecipesTable userRecipes = $UserRecipesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recipes, userRecipes];
}

typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      required String id,
      required String name,
      required String description,
      required String ingredients,
      required String steps,
      required String cookingTime,
      required String servings,
      Value<bool> isFavorite,
      required int createdAt,
      Value<String?> imageUrl,
      Value<String?> source,
      Value<int> rowid,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> ingredients,
      Value<String> steps,
      Value<String> cookingTime,
      Value<String> servings,
      Value<bool> isFavorite,
      Value<int> createdAt,
      Value<String?> imageUrl,
      Value<String?> source,
      Value<int> rowid,
    });

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cookingTime => $composableBuilder(
    column: $table.cookingTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cookingTime => $composableBuilder(
    column: $table.cookingTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get cookingTime => $composableBuilder(
    column: $table.cookingTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          RecipeEntity,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (
            RecipeEntity,
            BaseReferences<_$AppDatabase, $RecipesTable, RecipeEntity>,
          ),
          RecipeEntity,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> ingredients = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<String> cookingTime = const Value.absent(),
                Value<String> servings = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                name: name,
                description: description,
                ingredients: ingredients,
                steps: steps,
                cookingTime: cookingTime,
                servings: servings,
                isFavorite: isFavorite,
                createdAt: createdAt,
                imageUrl: imageUrl,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                required String ingredients,
                required String steps,
                required String cookingTime,
                required String servings,
                Value<bool> isFavorite = const Value.absent(),
                required int createdAt,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                name: name,
                description: description,
                ingredients: ingredients,
                steps: steps,
                cookingTime: cookingTime,
                servings: servings,
                isFavorite: isFavorite,
                createdAt: createdAt,
                imageUrl: imageUrl,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      RecipeEntity,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (
        RecipeEntity,
        BaseReferences<_$AppDatabase, $RecipesTable, RecipeEntity>,
      ),
      RecipeEntity,
      PrefetchHooks Function()
    >;
typedef $$UserRecipesTableCreateCompanionBuilder =
    UserRecipesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String ingredients,
      required String steps,
      Value<String> coverEmoji,
      Value<String?> imageUrl,
      Value<bool> isPublic,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$UserRecipesTableUpdateCompanionBuilder =
    UserRecipesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> ingredients,
      Value<String> steps,
      Value<String> coverEmoji,
      Value<String?> imageUrl,
      Value<bool> isPublic,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$UserRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $UserRecipesTable> {
  $$UserRecipesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverEmoji => $composableBuilder(
    column: $table.coverEmoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserRecipesTable> {
  $$UserRecipesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverEmoji => $composableBuilder(
    column: $table.coverEmoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserRecipesTable> {
  $$UserRecipesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get coverEmoji => $composableBuilder(
    column: $table.coverEmoji,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserRecipesTable,
          UserRecipeEntity,
          $$UserRecipesTableFilterComposer,
          $$UserRecipesTableOrderingComposer,
          $$UserRecipesTableAnnotationComposer,
          $$UserRecipesTableCreateCompanionBuilder,
          $$UserRecipesTableUpdateCompanionBuilder,
          (
            UserRecipeEntity,
            BaseReferences<_$AppDatabase, $UserRecipesTable, UserRecipeEntity>,
          ),
          UserRecipeEntity,
          PrefetchHooks Function()
        > {
  $$UserRecipesTableTableManager(_$AppDatabase db, $UserRecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> ingredients = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<String> coverEmoji = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRecipesCompanion(
                id: id,
                name: name,
                description: description,
                ingredients: ingredients,
                steps: steps,
                coverEmoji: coverEmoji,
                imageUrl: imageUrl,
                isPublic: isPublic,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String ingredients,
                required String steps,
                Value<String> coverEmoji = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserRecipesCompanion.insert(
                id: id,
                name: name,
                description: description,
                ingredients: ingredients,
                steps: steps,
                coverEmoji: coverEmoji,
                imageUrl: imageUrl,
                isPublic: isPublic,
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

typedef $$UserRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserRecipesTable,
      UserRecipeEntity,
      $$UserRecipesTableFilterComposer,
      $$UserRecipesTableOrderingComposer,
      $$UserRecipesTableAnnotationComposer,
      $$UserRecipesTableCreateCompanionBuilder,
      $$UserRecipesTableUpdateCompanionBuilder,
      (
        UserRecipeEntity,
        BaseReferences<_$AppDatabase, $UserRecipesTable, UserRecipeEntity>,
      ),
      UserRecipeEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$UserRecipesTableTableManager get userRecipes =>
      $$UserRecipesTableTableManager(_db, _db.userRecipes);
}
