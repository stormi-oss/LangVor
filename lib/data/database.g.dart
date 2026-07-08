// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TranslationProjectsTable extends TranslationProjects
    with TableInfo<$TranslationProjectsTable, TranslationProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sourceTextMeta =
      const VerificationMeta('sourceText');
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
      'source_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userTranslationMeta =
      const VerificationMeta('userTranslation');
  @override
  late final GeneratedColumn<String> userTranslation = GeneratedColumn<String>(
      'user_translation', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sourceFormattedMeta =
      const VerificationMeta('sourceFormatted');
  @override
  late final GeneratedColumn<String> sourceFormatted = GeneratedColumn<String>(
      'source_formatted', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _translationFormattedMeta =
      const VerificationMeta('translationFormatted');
  @override
  late final GeneratedColumn<String> translationFormatted =
      GeneratedColumn<String>('translation_formatted', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _isVerseModeMeta =
      const VerificationMeta('isVerseMode');
  @override
  late final GeneratedColumn<bool> isVerseMode = GeneratedColumn<bool>(
      'is_verse_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_verse_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        sourceText,
        userTranslation,
        sourceFormatted,
        translationFormatted,
        isVerseMode,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation_projects';
  @override
  VerificationContext validateIntegrity(Insertable<TranslationProject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source_text')) {
      context.handle(
          _sourceTextMeta,
          sourceText.isAcceptableOrUnknown(
              data['source_text']!, _sourceTextMeta));
    } else if (isInserting) {
      context.missing(_sourceTextMeta);
    }
    if (data.containsKey('user_translation')) {
      context.handle(
          _userTranslationMeta,
          userTranslation.isAcceptableOrUnknown(
              data['user_translation']!, _userTranslationMeta));
    }
    if (data.containsKey('source_formatted')) {
      context.handle(
          _sourceFormattedMeta,
          sourceFormatted.isAcceptableOrUnknown(
              data['source_formatted']!, _sourceFormattedMeta));
    }
    if (data.containsKey('translation_formatted')) {
      context.handle(
          _translationFormattedMeta,
          translationFormatted.isAcceptableOrUnknown(
              data['translation_formatted']!, _translationFormattedMeta));
    }
    if (data.containsKey('is_verse_mode')) {
      context.handle(
          _isVerseModeMeta,
          isVerseMode.isAcceptableOrUnknown(
              data['is_verse_mode']!, _isVerseModeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranslationProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationProject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      sourceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_text'])!,
      userTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}user_translation'])!,
      sourceFormatted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_formatted'])!,
      translationFormatted: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}translation_formatted'])!,
      isVerseMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verse_mode'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TranslationProjectsTable createAlias(String alias) {
    return $TranslationProjectsTable(attachedDatabase, alias);
  }
}

class TranslationProject extends DataClass
    implements Insertable<TranslationProject> {
  final int id;
  final String title;
  final String sourceText;
  final String userTranslation;
  final String sourceFormatted;
  final String translationFormatted;
  final bool isVerseMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TranslationProject(
      {required this.id,
      required this.title,
      required this.sourceText,
      required this.userTranslation,
      required this.sourceFormatted,
      required this.translationFormatted,
      required this.isVerseMode,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['source_text'] = Variable<String>(sourceText);
    map['user_translation'] = Variable<String>(userTranslation);
    map['source_formatted'] = Variable<String>(sourceFormatted);
    map['translation_formatted'] = Variable<String>(translationFormatted);
    map['is_verse_mode'] = Variable<bool>(isVerseMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TranslationProjectsCompanion toCompanion(bool nullToAbsent) {
    return TranslationProjectsCompanion(
      id: Value(id),
      title: Value(title),
      sourceText: Value(sourceText),
      userTranslation: Value(userTranslation),
      sourceFormatted: Value(sourceFormatted),
      translationFormatted: Value(translationFormatted),
      isVerseMode: Value(isVerseMode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TranslationProject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationProject(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sourceText: serializer.fromJson<String>(json['sourceText']),
      userTranslation: serializer.fromJson<String>(json['userTranslation']),
      sourceFormatted: serializer.fromJson<String>(json['sourceFormatted']),
      translationFormatted:
          serializer.fromJson<String>(json['translationFormatted']),
      isVerseMode: serializer.fromJson<bool>(json['isVerseMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'sourceText': serializer.toJson<String>(sourceText),
      'userTranslation': serializer.toJson<String>(userTranslation),
      'sourceFormatted': serializer.toJson<String>(sourceFormatted),
      'translationFormatted': serializer.toJson<String>(translationFormatted),
      'isVerseMode': serializer.toJson<bool>(isVerseMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TranslationProject copyWith(
          {int? id,
          String? title,
          String? sourceText,
          String? userTranslation,
          String? sourceFormatted,
          String? translationFormatted,
          bool? isVerseMode,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TranslationProject(
        id: id ?? this.id,
        title: title ?? this.title,
        sourceText: sourceText ?? this.sourceText,
        userTranslation: userTranslation ?? this.userTranslation,
        sourceFormatted: sourceFormatted ?? this.sourceFormatted,
        translationFormatted: translationFormatted ?? this.translationFormatted,
        isVerseMode: isVerseMode ?? this.isVerseMode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TranslationProject copyWithCompanion(TranslationProjectsCompanion data) {
    return TranslationProject(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sourceText:
          data.sourceText.present ? data.sourceText.value : this.sourceText,
      userTranslation: data.userTranslation.present
          ? data.userTranslation.value
          : this.userTranslation,
      sourceFormatted: data.sourceFormatted.present
          ? data.sourceFormatted.value
          : this.sourceFormatted,
      translationFormatted: data.translationFormatted.present
          ? data.translationFormatted.value
          : this.translationFormatted,
      isVerseMode:
          data.isVerseMode.present ? data.isVerseMode.value : this.isVerseMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationProject(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourceText: $sourceText, ')
          ..write('userTranslation: $userTranslation, ')
          ..write('sourceFormatted: $sourceFormatted, ')
          ..write('translationFormatted: $translationFormatted, ')
          ..write('isVerseMode: $isVerseMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, sourceText, userTranslation,
      sourceFormatted, translationFormatted, isVerseMode, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationProject &&
          other.id == this.id &&
          other.title == this.title &&
          other.sourceText == this.sourceText &&
          other.userTranslation == this.userTranslation &&
          other.sourceFormatted == this.sourceFormatted &&
          other.translationFormatted == this.translationFormatted &&
          other.isVerseMode == this.isVerseMode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TranslationProjectsCompanion extends UpdateCompanion<TranslationProject> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> sourceText;
  final Value<String> userTranslation;
  final Value<String> sourceFormatted;
  final Value<String> translationFormatted;
  final Value<bool> isVerseMode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TranslationProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.userTranslation = const Value.absent(),
    this.sourceFormatted = const Value.absent(),
    this.translationFormatted = const Value.absent(),
    this.isVerseMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TranslationProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String sourceText,
    this.userTranslation = const Value.absent(),
    this.sourceFormatted = const Value.absent(),
    this.translationFormatted = const Value.absent(),
    this.isVerseMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        sourceText = Value(sourceText);
  static Insertable<TranslationProject> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? sourceText,
    Expression<String>? userTranslation,
    Expression<String>? sourceFormatted,
    Expression<String>? translationFormatted,
    Expression<bool>? isVerseMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sourceText != null) 'source_text': sourceText,
      if (userTranslation != null) 'user_translation': userTranslation,
      if (sourceFormatted != null) 'source_formatted': sourceFormatted,
      if (translationFormatted != null)
        'translation_formatted': translationFormatted,
      if (isVerseMode != null) 'is_verse_mode': isVerseMode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TranslationProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? sourceText,
      Value<String>? userTranslation,
      Value<String>? sourceFormatted,
      Value<String>? translationFormatted,
      Value<bool>? isVerseMode,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TranslationProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sourceText: sourceText ?? this.sourceText,
      userTranslation: userTranslation ?? this.userTranslation,
      sourceFormatted: sourceFormatted ?? this.sourceFormatted,
      translationFormatted: translationFormatted ?? this.translationFormatted,
      isVerseMode: isVerseMode ?? this.isVerseMode,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (userTranslation.present) {
      map['user_translation'] = Variable<String>(userTranslation.value);
    }
    if (sourceFormatted.present) {
      map['source_formatted'] = Variable<String>(sourceFormatted.value);
    }
    if (translationFormatted.present) {
      map['translation_formatted'] =
          Variable<String>(translationFormatted.value);
    }
    if (isVerseMode.present) {
      map['is_verse_mode'] = Variable<bool>(isVerseMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourceText: $sourceText, ')
          ..write('userTranslation: $userTranslation, ')
          ..write('sourceFormatted: $sourceFormatted, ')
          ..write('translationFormatted: $translationFormatted, ')
          ..write('isVerseMode: $isVerseMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $VocabularyCardsTable extends VocabularyCards
    with TableInfo<$VocabularyCardsTable, VocabularyCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _englishWordMeta =
      const VerificationMeta('englishWord');
  @override
  late final GeneratedColumn<String> englishWord = GeneratedColumn<String>(
      'english_word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _russianTranslationMeta =
      const VerificationMeta('russianTranslation');
  @override
  late final GeneratedColumn<String> russianTranslation =
      GeneratedColumn<String>('russian_translation', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _definitionMeta =
      const VerificationMeta('definition');
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
      'definition', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _contextSentenceMeta =
      const VerificationMeta('contextSentence');
  @override
  late final GeneratedColumn<String> contextSentence = GeneratedColumn<String>(
      'context_sentence', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
      'part_of_speech', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _nextReviewAtMeta =
      const VerificationMeta('nextReviewAt');
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
      'next_review_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _easeFactorMeta =
      const VerificationMeta('easeFactor');
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
      'ease_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        englishWord,
        russianTranslation,
        definition,
        contextSentence,
        partOfSpeech,
        createdAt,
        nextReviewAt,
        easeFactor,
        interval,
        repetitions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_cards';
  @override
  VerificationContext validateIntegrity(Insertable<VocabularyCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('english_word')) {
      context.handle(
          _englishWordMeta,
          englishWord.isAcceptableOrUnknown(
              data['english_word']!, _englishWordMeta));
    } else if (isInserting) {
      context.missing(_englishWordMeta);
    }
    if (data.containsKey('russian_translation')) {
      context.handle(
          _russianTranslationMeta,
          russianTranslation.isAcceptableOrUnknown(
              data['russian_translation']!, _russianTranslationMeta));
    } else if (isInserting) {
      context.missing(_russianTranslationMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
          _definitionMeta,
          definition.isAcceptableOrUnknown(
              data['definition']!, _definitionMeta));
    }
    if (data.containsKey('context_sentence')) {
      context.handle(
          _contextSentenceMeta,
          contextSentence.isAcceptableOrUnknown(
              data['context_sentence']!, _contextSentenceMeta));
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
          _nextReviewAtMeta,
          nextReviewAt.isAcceptableOrUnknown(
              data['next_review_at']!, _nextReviewAtMeta));
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
          _easeFactorMeta,
          easeFactor.isAcceptableOrUnknown(
              data['ease_factor']!, _easeFactorMeta));
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      englishWord: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}english_word'])!,
      russianTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}russian_translation'])!,
      definition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}definition'])!,
      contextSentence: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}context_sentence'])!,
      partOfSpeech: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_of_speech'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      nextReviewAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_at'])!,
      easeFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease_factor'])!,
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
    );
  }

  @override
  $VocabularyCardsTable createAlias(String alias) {
    return $VocabularyCardsTable(attachedDatabase, alias);
  }
}

class VocabularyCard extends DataClass implements Insertable<VocabularyCard> {
  final int id;
  final String englishWord;
  final String russianTranslation;
  final String definition;
  final String contextSentence;
  final String partOfSpeech;
  final DateTime createdAt;
  final DateTime nextReviewAt;
  final double easeFactor;
  final int interval;
  final int repetitions;
  const VocabularyCard(
      {required this.id,
      required this.englishWord,
      required this.russianTranslation,
      required this.definition,
      required this.contextSentence,
      required this.partOfSpeech,
      required this.createdAt,
      required this.nextReviewAt,
      required this.easeFactor,
      required this.interval,
      required this.repetitions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['english_word'] = Variable<String>(englishWord);
    map['russian_translation'] = Variable<String>(russianTranslation);
    map['definition'] = Variable<String>(definition);
    map['context_sentence'] = Variable<String>(contextSentence);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval'] = Variable<int>(interval);
    map['repetitions'] = Variable<int>(repetitions);
    return map;
  }

  VocabularyCardsCompanion toCompanion(bool nullToAbsent) {
    return VocabularyCardsCompanion(
      id: Value(id),
      englishWord: Value(englishWord),
      russianTranslation: Value(russianTranslation),
      definition: Value(definition),
      contextSentence: Value(contextSentence),
      partOfSpeech: Value(partOfSpeech),
      createdAt: Value(createdAt),
      nextReviewAt: Value(nextReviewAt),
      easeFactor: Value(easeFactor),
      interval: Value(interval),
      repetitions: Value(repetitions),
    );
  }

  factory VocabularyCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyCard(
      id: serializer.fromJson<int>(json['id']),
      englishWord: serializer.fromJson<String>(json['englishWord']),
      russianTranslation:
          serializer.fromJson<String>(json['russianTranslation']),
      definition: serializer.fromJson<String>(json['definition']),
      contextSentence: serializer.fromJson<String>(json['contextSentence']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      interval: serializer.fromJson<int>(json['interval']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'englishWord': serializer.toJson<String>(englishWord),
      'russianTranslation': serializer.toJson<String>(russianTranslation),
      'definition': serializer.toJson<String>(definition),
      'contextSentence': serializer.toJson<String>(contextSentence),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'interval': serializer.toJson<int>(interval),
      'repetitions': serializer.toJson<int>(repetitions),
    };
  }

  VocabularyCard copyWith(
          {int? id,
          String? englishWord,
          String? russianTranslation,
          String? definition,
          String? contextSentence,
          String? partOfSpeech,
          DateTime? createdAt,
          DateTime? nextReviewAt,
          double? easeFactor,
          int? interval,
          int? repetitions}) =>
      VocabularyCard(
        id: id ?? this.id,
        englishWord: englishWord ?? this.englishWord,
        russianTranslation: russianTranslation ?? this.russianTranslation,
        definition: definition ?? this.definition,
        contextSentence: contextSentence ?? this.contextSentence,
        partOfSpeech: partOfSpeech ?? this.partOfSpeech,
        createdAt: createdAt ?? this.createdAt,
        nextReviewAt: nextReviewAt ?? this.nextReviewAt,
        easeFactor: easeFactor ?? this.easeFactor,
        interval: interval ?? this.interval,
        repetitions: repetitions ?? this.repetitions,
      );
  VocabularyCard copyWithCompanion(VocabularyCardsCompanion data) {
    return VocabularyCard(
      id: data.id.present ? data.id.value : this.id,
      englishWord:
          data.englishWord.present ? data.englishWord.value : this.englishWord,
      russianTranslation: data.russianTranslation.present
          ? data.russianTranslation.value
          : this.russianTranslation,
      definition:
          data.definition.present ? data.definition.value : this.definition,
      contextSentence: data.contextSentence.present
          ? data.contextSentence.value
          : this.contextSentence,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyCard(')
          ..write('id: $id, ')
          ..write('englishWord: $englishWord, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('definition: $definition, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      englishWord,
      russianTranslation,
      definition,
      contextSentence,
      partOfSpeech,
      createdAt,
      nextReviewAt,
      easeFactor,
      interval,
      repetitions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyCard &&
          other.id == this.id &&
          other.englishWord == this.englishWord &&
          other.russianTranslation == this.russianTranslation &&
          other.definition == this.definition &&
          other.contextSentence == this.contextSentence &&
          other.partOfSpeech == this.partOfSpeech &&
          other.createdAt == this.createdAt &&
          other.nextReviewAt == this.nextReviewAt &&
          other.easeFactor == this.easeFactor &&
          other.interval == this.interval &&
          other.repetitions == this.repetitions);
}

class VocabularyCardsCompanion extends UpdateCompanion<VocabularyCard> {
  final Value<int> id;
  final Value<String> englishWord;
  final Value<String> russianTranslation;
  final Value<String> definition;
  final Value<String> contextSentence;
  final Value<String> partOfSpeech;
  final Value<DateTime> createdAt;
  final Value<DateTime> nextReviewAt;
  final Value<double> easeFactor;
  final Value<int> interval;
  final Value<int> repetitions;
  const VocabularyCardsCompanion({
    this.id = const Value.absent(),
    this.englishWord = const Value.absent(),
    this.russianTranslation = const Value.absent(),
    this.definition = const Value.absent(),
    this.contextSentence = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
  });
  VocabularyCardsCompanion.insert({
    this.id = const Value.absent(),
    required String englishWord,
    required String russianTranslation,
    this.definition = const Value.absent(),
    this.contextSentence = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
  })  : englishWord = Value(englishWord),
        russianTranslation = Value(russianTranslation);
  static Insertable<VocabularyCard> custom({
    Expression<int>? id,
    Expression<String>? englishWord,
    Expression<String>? russianTranslation,
    Expression<String>? definition,
    Expression<String>? contextSentence,
    Expression<String>? partOfSpeech,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextReviewAt,
    Expression<double>? easeFactor,
    Expression<int>? interval,
    Expression<int>? repetitions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (englishWord != null) 'english_word': englishWord,
      if (russianTranslation != null) 'russian_translation': russianTranslation,
      if (definition != null) 'definition': definition,
      if (contextSentence != null) 'context_sentence': contextSentence,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (createdAt != null) 'created_at': createdAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (interval != null) 'interval': interval,
      if (repetitions != null) 'repetitions': repetitions,
    });
  }

  VocabularyCardsCompanion copyWith(
      {Value<int>? id,
      Value<String>? englishWord,
      Value<String>? russianTranslation,
      Value<String>? definition,
      Value<String>? contextSentence,
      Value<String>? partOfSpeech,
      Value<DateTime>? createdAt,
      Value<DateTime>? nextReviewAt,
      Value<double>? easeFactor,
      Value<int>? interval,
      Value<int>? repetitions}) {
    return VocabularyCardsCompanion(
      id: id ?? this.id,
      englishWord: englishWord ?? this.englishWord,
      russianTranslation: russianTranslation ?? this.russianTranslation,
      definition: definition ?? this.definition,
      contextSentence: contextSentence ?? this.contextSentence,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      createdAt: createdAt ?? this.createdAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (englishWord.present) {
      map['english_word'] = Variable<String>(englishWord.value);
    }
    if (russianTranslation.present) {
      map['russian_translation'] = Variable<String>(russianTranslation.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (contextSentence.present) {
      map['context_sentence'] = Variable<String>(contextSentence.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyCardsCompanion(')
          ..write('id: $id, ')
          ..write('englishWord: $englishWord, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('definition: $definition, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions')
          ..write(')'))
        .toString();
  }
}

class $DictionaryEntriesTable extends DictionaryEntries
    with TableInfo<$DictionaryEntriesTable, DictionaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _definitionMeta =
      const VerificationMeta('definition');
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
      'definition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _synonymsMeta =
      const VerificationMeta('synonyms');
  @override
  late final GeneratedColumn<String> synonyms = GeneratedColumn<String>(
      'synonyms', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
      'part_of_speech', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _frequencyRankMeta =
      const VerificationMeta('frequencyRank');
  @override
  late final GeneratedColumn<int> frequencyRank = GeneratedColumn<int>(
      'frequency_rank', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(99999));
  static const VerificationMeta _russianTranslationMeta =
      const VerificationMeta('russianTranslation');
  @override
  late final GeneratedColumn<String> russianTranslation =
      GeneratedColumn<String>('russian_translation', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _cefrLevelMeta =
      const VerificationMeta('cefrLevel');
  @override
  late final GeneratedColumn<String> cefrLevel = GeneratedColumn<String>(
      'cefr_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _exampleSentenceMeta =
      const VerificationMeta('exampleSentence');
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
      'example_sentence', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        word,
        definition,
        synonyms,
        partOfSpeech,
        frequencyRank,
        russianTranslation,
        cefrLevel,
        exampleSentence
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DictionaryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
          _definitionMeta,
          definition.isAcceptableOrUnknown(
              data['definition']!, _definitionMeta));
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('synonyms')) {
      context.handle(_synonymsMeta,
          synonyms.isAcceptableOrUnknown(data['synonyms']!, _synonymsMeta));
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    }
    if (data.containsKey('frequency_rank')) {
      context.handle(
          _frequencyRankMeta,
          frequencyRank.isAcceptableOrUnknown(
              data['frequency_rank']!, _frequencyRankMeta));
    }
    if (data.containsKey('russian_translation')) {
      context.handle(
          _russianTranslationMeta,
          russianTranslation.isAcceptableOrUnknown(
              data['russian_translation']!, _russianTranslationMeta));
    }
    if (data.containsKey('cefr_level')) {
      context.handle(_cefrLevelMeta,
          cefrLevel.isAcceptableOrUnknown(data['cefr_level']!, _cefrLevelMeta));
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
          _exampleSentenceMeta,
          exampleSentence.isAcceptableOrUnknown(
              data['example_sentence']!, _exampleSentenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  DictionaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryEntry(
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      definition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}definition'])!,
      synonyms: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}synonyms'])!,
      partOfSpeech: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_of_speech'])!,
      frequencyRank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency_rank'])!,
      russianTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}russian_translation'])!,
      cefrLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cefr_level'])!,
      exampleSentence: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}example_sentence'])!,
    );
  }

  @override
  $DictionaryEntriesTable createAlias(String alias) {
    return $DictionaryEntriesTable(attachedDatabase, alias);
  }
}

class DictionaryEntry extends DataClass implements Insertable<DictionaryEntry> {
  final String word;
  final String definition;
  final String synonyms;
  final String partOfSpeech;
  final int frequencyRank;
  final String russianTranslation;
  final String cefrLevel;
  final String exampleSentence;
  const DictionaryEntry(
      {required this.word,
      required this.definition,
      required this.synonyms,
      required this.partOfSpeech,
      required this.frequencyRank,
      required this.russianTranslation,
      required this.cefrLevel,
      required this.exampleSentence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    map['definition'] = Variable<String>(definition);
    map['synonyms'] = Variable<String>(synonyms);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['frequency_rank'] = Variable<int>(frequencyRank);
    map['russian_translation'] = Variable<String>(russianTranslation);
    map['cefr_level'] = Variable<String>(cefrLevel);
    map['example_sentence'] = Variable<String>(exampleSentence);
    return map;
  }

  DictionaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DictionaryEntriesCompanion(
      word: Value(word),
      definition: Value(definition),
      synonyms: Value(synonyms),
      partOfSpeech: Value(partOfSpeech),
      frequencyRank: Value(frequencyRank),
      russianTranslation: Value(russianTranslation),
      cefrLevel: Value(cefrLevel),
      exampleSentence: Value(exampleSentence),
    );
  }

  factory DictionaryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryEntry(
      word: serializer.fromJson<String>(json['word']),
      definition: serializer.fromJson<String>(json['definition']),
      synonyms: serializer.fromJson<String>(json['synonyms']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      frequencyRank: serializer.fromJson<int>(json['frequencyRank']),
      russianTranslation:
          serializer.fromJson<String>(json['russianTranslation']),
      cefrLevel: serializer.fromJson<String>(json['cefrLevel']),
      exampleSentence: serializer.fromJson<String>(json['exampleSentence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'definition': serializer.toJson<String>(definition),
      'synonyms': serializer.toJson<String>(synonyms),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'frequencyRank': serializer.toJson<int>(frequencyRank),
      'russianTranslation': serializer.toJson<String>(russianTranslation),
      'cefrLevel': serializer.toJson<String>(cefrLevel),
      'exampleSentence': serializer.toJson<String>(exampleSentence),
    };
  }

  DictionaryEntry copyWith(
          {String? word,
          String? definition,
          String? synonyms,
          String? partOfSpeech,
          int? frequencyRank,
          String? russianTranslation,
          String? cefrLevel,
          String? exampleSentence}) =>
      DictionaryEntry(
        word: word ?? this.word,
        definition: definition ?? this.definition,
        synonyms: synonyms ?? this.synonyms,
        partOfSpeech: partOfSpeech ?? this.partOfSpeech,
        frequencyRank: frequencyRank ?? this.frequencyRank,
        russianTranslation: russianTranslation ?? this.russianTranslation,
        cefrLevel: cefrLevel ?? this.cefrLevel,
        exampleSentence: exampleSentence ?? this.exampleSentence,
      );
  DictionaryEntry copyWithCompanion(DictionaryEntriesCompanion data) {
    return DictionaryEntry(
      word: data.word.present ? data.word.value : this.word,
      definition:
          data.definition.present ? data.definition.value : this.definition,
      synonyms: data.synonyms.present ? data.synonyms.value : this.synonyms,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      frequencyRank: data.frequencyRank.present
          ? data.frequencyRank.value
          : this.frequencyRank,
      russianTranslation: data.russianTranslation.present
          ? data.russianTranslation.value
          : this.russianTranslation,
      cefrLevel: data.cefrLevel.present ? data.cefrLevel.value : this.cefrLevel,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntry(')
          ..write('word: $word, ')
          ..write('definition: $definition, ')
          ..write('synonyms: $synonyms, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('frequencyRank: $frequencyRank, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('cefrLevel: $cefrLevel, ')
          ..write('exampleSentence: $exampleSentence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(word, definition, synonyms, partOfSpeech,
      frequencyRank, russianTranslation, cefrLevel, exampleSentence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryEntry &&
          other.word == this.word &&
          other.definition == this.definition &&
          other.synonyms == this.synonyms &&
          other.partOfSpeech == this.partOfSpeech &&
          other.frequencyRank == this.frequencyRank &&
          other.russianTranslation == this.russianTranslation &&
          other.cefrLevel == this.cefrLevel &&
          other.exampleSentence == this.exampleSentence);
}

class DictionaryEntriesCompanion extends UpdateCompanion<DictionaryEntry> {
  final Value<String> word;
  final Value<String> definition;
  final Value<String> synonyms;
  final Value<String> partOfSpeech;
  final Value<int> frequencyRank;
  final Value<String> russianTranslation;
  final Value<String> cefrLevel;
  final Value<String> exampleSentence;
  final Value<int> rowid;
  const DictionaryEntriesCompanion({
    this.word = const Value.absent(),
    this.definition = const Value.absent(),
    this.synonyms = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.frequencyRank = const Value.absent(),
    this.russianTranslation = const Value.absent(),
    this.cefrLevel = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionaryEntriesCompanion.insert({
    required String word,
    required String definition,
    this.synonyms = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.frequencyRank = const Value.absent(),
    this.russianTranslation = const Value.absent(),
    this.cefrLevel = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : word = Value(word),
        definition = Value(definition);
  static Insertable<DictionaryEntry> custom({
    Expression<String>? word,
    Expression<String>? definition,
    Expression<String>? synonyms,
    Expression<String>? partOfSpeech,
    Expression<int>? frequencyRank,
    Expression<String>? russianTranslation,
    Expression<String>? cefrLevel,
    Expression<String>? exampleSentence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (definition != null) 'definition': definition,
      if (synonyms != null) 'synonyms': synonyms,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (frequencyRank != null) 'frequency_rank': frequencyRank,
      if (russianTranslation != null) 'russian_translation': russianTranslation,
      if (cefrLevel != null) 'cefr_level': cefrLevel,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionaryEntriesCompanion copyWith(
      {Value<String>? word,
      Value<String>? definition,
      Value<String>? synonyms,
      Value<String>? partOfSpeech,
      Value<int>? frequencyRank,
      Value<String>? russianTranslation,
      Value<String>? cefrLevel,
      Value<String>? exampleSentence,
      Value<int>? rowid}) {
    return DictionaryEntriesCompanion(
      word: word ?? this.word,
      definition: definition ?? this.definition,
      synonyms: synonyms ?? this.synonyms,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      frequencyRank: frequencyRank ?? this.frequencyRank,
      russianTranslation: russianTranslation ?? this.russianTranslation,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (synonyms.present) {
      map['synonyms'] = Variable<String>(synonyms.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (frequencyRank.present) {
      map['frequency_rank'] = Variable<int>(frequencyRank.value);
    }
    if (russianTranslation.present) {
      map['russian_translation'] = Variable<String>(russianTranslation.value);
    }
    if (cefrLevel.present) {
      map['cefr_level'] = Variable<String>(cefrLevel.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntriesCompanion(')
          ..write('word: $word, ')
          ..write('definition: $definition, ')
          ..write('synonyms: $synonyms, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('frequencyRank: $frequencyRank, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('cefrLevel: $cefrLevel, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrammarRulesTable extends GrammarRules
    with TableInfo<$GrammarRulesTable, GrammarRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patternMeta =
      const VerificationMeta('pattern');
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
      'pattern', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctionMeta =
      const VerificationMeta('correction');
  @override
  late final GeneratedColumn<String> correction = GeneratedColumn<String>(
      'correction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exampleWrongMeta =
      const VerificationMeta('exampleWrong');
  @override
  late final GeneratedColumn<String> exampleWrong = GeneratedColumn<String>(
      'example_wrong', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _exampleCorrectMeta =
      const VerificationMeta('exampleCorrect');
  @override
  late final GeneratedColumn<String> exampleCorrect = GeneratedColumn<String>(
      'example_correct', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        pattern,
        correction,
        explanation,
        exampleWrong,
        exampleCorrect
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_rules';
  @override
  VerificationContext validateIntegrity(Insertable<GrammarRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(_patternMeta,
          pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta));
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('correction')) {
      context.handle(
          _correctionMeta,
          correction.isAcceptableOrUnknown(
              data['correction']!, _correctionMeta));
    } else if (isInserting) {
      context.missing(_correctionMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('example_wrong')) {
      context.handle(
          _exampleWrongMeta,
          exampleWrong.isAcceptableOrUnknown(
              data['example_wrong']!, _exampleWrongMeta));
    }
    if (data.containsKey('example_correct')) {
      context.handle(
          _exampleCorrectMeta,
          exampleCorrect.isAcceptableOrUnknown(
              data['example_correct']!, _exampleCorrectMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      pattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern'])!,
      correction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correction'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation'])!,
      exampleWrong: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example_wrong'])!,
      exampleCorrect: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}example_correct'])!,
    );
  }

  @override
  $GrammarRulesTable createAlias(String alias) {
    return $GrammarRulesTable(attachedDatabase, alias);
  }
}

class GrammarRule extends DataClass implements Insertable<GrammarRule> {
  final int id;
  final String category;
  final String pattern;
  final String correction;
  final String explanation;
  final String exampleWrong;
  final String exampleCorrect;
  const GrammarRule(
      {required this.id,
      required this.category,
      required this.pattern,
      required this.correction,
      required this.explanation,
      required this.exampleWrong,
      required this.exampleCorrect});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['pattern'] = Variable<String>(pattern);
    map['correction'] = Variable<String>(correction);
    map['explanation'] = Variable<String>(explanation);
    map['example_wrong'] = Variable<String>(exampleWrong);
    map['example_correct'] = Variable<String>(exampleCorrect);
    return map;
  }

  GrammarRulesCompanion toCompanion(bool nullToAbsent) {
    return GrammarRulesCompanion(
      id: Value(id),
      category: Value(category),
      pattern: Value(pattern),
      correction: Value(correction),
      explanation: Value(explanation),
      exampleWrong: Value(exampleWrong),
      exampleCorrect: Value(exampleCorrect),
    );
  }

  factory GrammarRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarRule(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      pattern: serializer.fromJson<String>(json['pattern']),
      correction: serializer.fromJson<String>(json['correction']),
      explanation: serializer.fromJson<String>(json['explanation']),
      exampleWrong: serializer.fromJson<String>(json['exampleWrong']),
      exampleCorrect: serializer.fromJson<String>(json['exampleCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'pattern': serializer.toJson<String>(pattern),
      'correction': serializer.toJson<String>(correction),
      'explanation': serializer.toJson<String>(explanation),
      'exampleWrong': serializer.toJson<String>(exampleWrong),
      'exampleCorrect': serializer.toJson<String>(exampleCorrect),
    };
  }

  GrammarRule copyWith(
          {int? id,
          String? category,
          String? pattern,
          String? correction,
          String? explanation,
          String? exampleWrong,
          String? exampleCorrect}) =>
      GrammarRule(
        id: id ?? this.id,
        category: category ?? this.category,
        pattern: pattern ?? this.pattern,
        correction: correction ?? this.correction,
        explanation: explanation ?? this.explanation,
        exampleWrong: exampleWrong ?? this.exampleWrong,
        exampleCorrect: exampleCorrect ?? this.exampleCorrect,
      );
  GrammarRule copyWithCompanion(GrammarRulesCompanion data) {
    return GrammarRule(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      correction:
          data.correction.present ? data.correction.value : this.correction,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      exampleWrong: data.exampleWrong.present
          ? data.exampleWrong.value
          : this.exampleWrong,
      exampleCorrect: data.exampleCorrect.present
          ? data.exampleCorrect.value
          : this.exampleCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarRule(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('pattern: $pattern, ')
          ..write('correction: $correction, ')
          ..write('explanation: $explanation, ')
          ..write('exampleWrong: $exampleWrong, ')
          ..write('exampleCorrect: $exampleCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, pattern, correction,
      explanation, exampleWrong, exampleCorrect);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarRule &&
          other.id == this.id &&
          other.category == this.category &&
          other.pattern == this.pattern &&
          other.correction == this.correction &&
          other.explanation == this.explanation &&
          other.exampleWrong == this.exampleWrong &&
          other.exampleCorrect == this.exampleCorrect);
}

class GrammarRulesCompanion extends UpdateCompanion<GrammarRule> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> pattern;
  final Value<String> correction;
  final Value<String> explanation;
  final Value<String> exampleWrong;
  final Value<String> exampleCorrect;
  const GrammarRulesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.pattern = const Value.absent(),
    this.correction = const Value.absent(),
    this.explanation = const Value.absent(),
    this.exampleWrong = const Value.absent(),
    this.exampleCorrect = const Value.absent(),
  });
  GrammarRulesCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String pattern,
    required String correction,
    required String explanation,
    this.exampleWrong = const Value.absent(),
    this.exampleCorrect = const Value.absent(),
  })  : category = Value(category),
        pattern = Value(pattern),
        correction = Value(correction),
        explanation = Value(explanation);
  static Insertable<GrammarRule> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? pattern,
    Expression<String>? correction,
    Expression<String>? explanation,
    Expression<String>? exampleWrong,
    Expression<String>? exampleCorrect,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (pattern != null) 'pattern': pattern,
      if (correction != null) 'correction': correction,
      if (explanation != null) 'explanation': explanation,
      if (exampleWrong != null) 'example_wrong': exampleWrong,
      if (exampleCorrect != null) 'example_correct': exampleCorrect,
    });
  }

  GrammarRulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? category,
      Value<String>? pattern,
      Value<String>? correction,
      Value<String>? explanation,
      Value<String>? exampleWrong,
      Value<String>? exampleCorrect}) {
    return GrammarRulesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      pattern: pattern ?? this.pattern,
      correction: correction ?? this.correction,
      explanation: explanation ?? this.explanation,
      exampleWrong: exampleWrong ?? this.exampleWrong,
      exampleCorrect: exampleCorrect ?? this.exampleCorrect,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (correction.present) {
      map['correction'] = Variable<String>(correction.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (exampleWrong.present) {
      map['example_wrong'] = Variable<String>(exampleWrong.value);
    }
    if (exampleCorrect.present) {
      map['example_correct'] = Variable<String>(exampleCorrect.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarRulesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('pattern: $pattern, ')
          ..write('correction: $correction, ')
          ..write('explanation: $explanation, ')
          ..write('exampleWrong: $exampleWrong, ')
          ..write('exampleCorrect: $exampleCorrect')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TranslationProjectsTable translationProjects =
      $TranslationProjectsTable(this);
  late final $VocabularyCardsTable vocabularyCards =
      $VocabularyCardsTable(this);
  late final $DictionaryEntriesTable dictionaryEntries =
      $DictionaryEntriesTable(this);
  late final $GrammarRulesTable grammarRules = $GrammarRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [translationProjects, vocabularyCards, dictionaryEntries, grammarRules];
}

typedef $$TranslationProjectsTableCreateCompanionBuilder
    = TranslationProjectsCompanion Function({
  Value<int> id,
  required String title,
  required String sourceText,
  Value<String> userTranslation,
  Value<String> sourceFormatted,
  Value<String> translationFormatted,
  Value<bool> isVerseMode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$TranslationProjectsTableUpdateCompanionBuilder
    = TranslationProjectsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> sourceText,
  Value<String> userTranslation,
  Value<String> sourceFormatted,
  Value<String> translationFormatted,
  Value<bool> isVerseMode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$TranslationProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationProjectsTable> {
  $$TranslationProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userTranslation => $composableBuilder(
      column: $table.userTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceFormatted => $composableBuilder(
      column: $table.sourceFormatted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translationFormatted => $composableBuilder(
      column: $table.translationFormatted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVerseMode => $composableBuilder(
      column: $table.isVerseMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TranslationProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationProjectsTable> {
  $$TranslationProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userTranslation => $composableBuilder(
      column: $table.userTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceFormatted => $composableBuilder(
      column: $table.sourceFormatted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translationFormatted => $composableBuilder(
      column: $table.translationFormatted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVerseMode => $composableBuilder(
      column: $table.isVerseMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TranslationProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationProjectsTable> {
  $$TranslationProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => column);

  GeneratedColumn<String> get userTranslation => $composableBuilder(
      column: $table.userTranslation, builder: (column) => column);

  GeneratedColumn<String> get sourceFormatted => $composableBuilder(
      column: $table.sourceFormatted, builder: (column) => column);

  GeneratedColumn<String> get translationFormatted => $composableBuilder(
      column: $table.translationFormatted, builder: (column) => column);

  GeneratedColumn<bool> get isVerseMode => $composableBuilder(
      column: $table.isVerseMode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TranslationProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TranslationProjectsTable,
    TranslationProject,
    $$TranslationProjectsTableFilterComposer,
    $$TranslationProjectsTableOrderingComposer,
    $$TranslationProjectsTableAnnotationComposer,
    $$TranslationProjectsTableCreateCompanionBuilder,
    $$TranslationProjectsTableUpdateCompanionBuilder,
    (
      TranslationProject,
      BaseReferences<_$AppDatabase, $TranslationProjectsTable,
          TranslationProject>
    ),
    TranslationProject,
    PrefetchHooks Function()> {
  $$TranslationProjectsTableTableManager(
      _$AppDatabase db, $TranslationProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationProjectsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationProjectsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> sourceText = const Value.absent(),
            Value<String> userTranslation = const Value.absent(),
            Value<String> sourceFormatted = const Value.absent(),
            Value<String> translationFormatted = const Value.absent(),
            Value<bool> isVerseMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TranslationProjectsCompanion(
            id: id,
            title: title,
            sourceText: sourceText,
            userTranslation: userTranslation,
            sourceFormatted: sourceFormatted,
            translationFormatted: translationFormatted,
            isVerseMode: isVerseMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String sourceText,
            Value<String> userTranslation = const Value.absent(),
            Value<String> sourceFormatted = const Value.absent(),
            Value<String> translationFormatted = const Value.absent(),
            Value<bool> isVerseMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TranslationProjectsCompanion.insert(
            id: id,
            title: title,
            sourceText: sourceText,
            userTranslation: userTranslation,
            sourceFormatted: sourceFormatted,
            translationFormatted: translationFormatted,
            isVerseMode: isVerseMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TranslationProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TranslationProjectsTable,
    TranslationProject,
    $$TranslationProjectsTableFilterComposer,
    $$TranslationProjectsTableOrderingComposer,
    $$TranslationProjectsTableAnnotationComposer,
    $$TranslationProjectsTableCreateCompanionBuilder,
    $$TranslationProjectsTableUpdateCompanionBuilder,
    (
      TranslationProject,
      BaseReferences<_$AppDatabase, $TranslationProjectsTable,
          TranslationProject>
    ),
    TranslationProject,
    PrefetchHooks Function()>;
typedef $$VocabularyCardsTableCreateCompanionBuilder = VocabularyCardsCompanion
    Function({
  Value<int> id,
  required String englishWord,
  required String russianTranslation,
  Value<String> definition,
  Value<String> contextSentence,
  Value<String> partOfSpeech,
  Value<DateTime> createdAt,
  Value<DateTime> nextReviewAt,
  Value<double> easeFactor,
  Value<int> interval,
  Value<int> repetitions,
});
typedef $$VocabularyCardsTableUpdateCompanionBuilder = VocabularyCardsCompanion
    Function({
  Value<int> id,
  Value<String> englishWord,
  Value<String> russianTranslation,
  Value<String> definition,
  Value<String> contextSentence,
  Value<String> partOfSpeech,
  Value<DateTime> createdAt,
  Value<DateTime> nextReviewAt,
  Value<double> easeFactor,
  Value<int> interval,
  Value<int> repetitions,
});

class $$VocabularyCardsTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyCardsTable> {
  $$VocabularyCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get englishWord => $composableBuilder(
      column: $table.englishWord, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextSentence => $composableBuilder(
      column: $table.contextSentence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));
}

class $$VocabularyCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyCardsTable> {
  $$VocabularyCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get englishWord => $composableBuilder(
      column: $table.englishWord, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextSentence => $composableBuilder(
      column: $table.contextSentence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));
}

class $$VocabularyCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyCardsTable> {
  $$VocabularyCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get englishWord => $composableBuilder(
      column: $table.englishWord, builder: (column) => column);

  GeneratedColumn<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => column);

  GeneratedColumn<String> get contextSentence => $composableBuilder(
      column: $table.contextSentence, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);
}

class $$VocabularyCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VocabularyCardsTable,
    VocabularyCard,
    $$VocabularyCardsTableFilterComposer,
    $$VocabularyCardsTableOrderingComposer,
    $$VocabularyCardsTableAnnotationComposer,
    $$VocabularyCardsTableCreateCompanionBuilder,
    $$VocabularyCardsTableUpdateCompanionBuilder,
    (
      VocabularyCard,
      BaseReferences<_$AppDatabase, $VocabularyCardsTable, VocabularyCard>
    ),
    VocabularyCard,
    PrefetchHooks Function()> {
  $$VocabularyCardsTableTableManager(
      _$AppDatabase db, $VocabularyCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> englishWord = const Value.absent(),
            Value<String> russianTranslation = const Value.absent(),
            Value<String> definition = const Value.absent(),
            Value<String> contextSentence = const Value.absent(),
            Value<String> partOfSpeech = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> nextReviewAt = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
          }) =>
              VocabularyCardsCompanion(
            id: id,
            englishWord: englishWord,
            russianTranslation: russianTranslation,
            definition: definition,
            contextSentence: contextSentence,
            partOfSpeech: partOfSpeech,
            createdAt: createdAt,
            nextReviewAt: nextReviewAt,
            easeFactor: easeFactor,
            interval: interval,
            repetitions: repetitions,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String englishWord,
            required String russianTranslation,
            Value<String> definition = const Value.absent(),
            Value<String> contextSentence = const Value.absent(),
            Value<String> partOfSpeech = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> nextReviewAt = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
          }) =>
              VocabularyCardsCompanion.insert(
            id: id,
            englishWord: englishWord,
            russianTranslation: russianTranslation,
            definition: definition,
            contextSentence: contextSentence,
            partOfSpeech: partOfSpeech,
            createdAt: createdAt,
            nextReviewAt: nextReviewAt,
            easeFactor: easeFactor,
            interval: interval,
            repetitions: repetitions,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VocabularyCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VocabularyCardsTable,
    VocabularyCard,
    $$VocabularyCardsTableFilterComposer,
    $$VocabularyCardsTableOrderingComposer,
    $$VocabularyCardsTableAnnotationComposer,
    $$VocabularyCardsTableCreateCompanionBuilder,
    $$VocabularyCardsTableUpdateCompanionBuilder,
    (
      VocabularyCard,
      BaseReferences<_$AppDatabase, $VocabularyCardsTable, VocabularyCard>
    ),
    VocabularyCard,
    PrefetchHooks Function()>;
typedef $$DictionaryEntriesTableCreateCompanionBuilder
    = DictionaryEntriesCompanion Function({
  required String word,
  required String definition,
  Value<String> synonyms,
  Value<String> partOfSpeech,
  Value<int> frequencyRank,
  Value<String> russianTranslation,
  Value<String> cefrLevel,
  Value<String> exampleSentence,
  Value<int> rowid,
});
typedef $$DictionaryEntriesTableUpdateCompanionBuilder
    = DictionaryEntriesCompanion Function({
  Value<String> word,
  Value<String> definition,
  Value<String> synonyms,
  Value<String> partOfSpeech,
  Value<int> frequencyRank,
  Value<String> russianTranslation,
  Value<String> cefrLevel,
  Value<String> exampleSentence,
  Value<int> rowid,
});

class $$DictionaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get synonyms => $composableBuilder(
      column: $table.synonyms, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequencyRank => $composableBuilder(
      column: $table.frequencyRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cefrLevel => $composableBuilder(
      column: $table.cefrLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleSentence => $composableBuilder(
      column: $table.exampleSentence,
      builder: (column) => ColumnFilters(column));
}

class $$DictionaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get synonyms => $composableBuilder(
      column: $table.synonyms, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequencyRank => $composableBuilder(
      column: $table.frequencyRank,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cefrLevel => $composableBuilder(
      column: $table.cefrLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
      column: $table.exampleSentence,
      builder: (column) => ColumnOrderings(column));
}

class $$DictionaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => column);

  GeneratedColumn<String> get synonyms =>
      $composableBuilder(column: $table.synonyms, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => column);

  GeneratedColumn<int> get frequencyRank => $composableBuilder(
      column: $table.frequencyRank, builder: (column) => column);

  GeneratedColumn<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation, builder: (column) => column);

  GeneratedColumn<String> get cefrLevel =>
      $composableBuilder(column: $table.cefrLevel, builder: (column) => column);

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
      column: $table.exampleSentence, builder: (column) => column);
}

class $$DictionaryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DictionaryEntriesTable,
    DictionaryEntry,
    $$DictionaryEntriesTableFilterComposer,
    $$DictionaryEntriesTableOrderingComposer,
    $$DictionaryEntriesTableAnnotationComposer,
    $$DictionaryEntriesTableCreateCompanionBuilder,
    $$DictionaryEntriesTableUpdateCompanionBuilder,
    (
      DictionaryEntry,
      BaseReferences<_$AppDatabase, $DictionaryEntriesTable, DictionaryEntry>
    ),
    DictionaryEntry,
    PrefetchHooks Function()> {
  $$DictionaryEntriesTableTableManager(
      _$AppDatabase db, $DictionaryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionaryEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> word = const Value.absent(),
            Value<String> definition = const Value.absent(),
            Value<String> synonyms = const Value.absent(),
            Value<String> partOfSpeech = const Value.absent(),
            Value<int> frequencyRank = const Value.absent(),
            Value<String> russianTranslation = const Value.absent(),
            Value<String> cefrLevel = const Value.absent(),
            Value<String> exampleSentence = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DictionaryEntriesCompanion(
            word: word,
            definition: definition,
            synonyms: synonyms,
            partOfSpeech: partOfSpeech,
            frequencyRank: frequencyRank,
            russianTranslation: russianTranslation,
            cefrLevel: cefrLevel,
            exampleSentence: exampleSentence,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String word,
            required String definition,
            Value<String> synonyms = const Value.absent(),
            Value<String> partOfSpeech = const Value.absent(),
            Value<int> frequencyRank = const Value.absent(),
            Value<String> russianTranslation = const Value.absent(),
            Value<String> cefrLevel = const Value.absent(),
            Value<String> exampleSentence = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DictionaryEntriesCompanion.insert(
            word: word,
            definition: definition,
            synonyms: synonyms,
            partOfSpeech: partOfSpeech,
            frequencyRank: frequencyRank,
            russianTranslation: russianTranslation,
            cefrLevel: cefrLevel,
            exampleSentence: exampleSentence,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DictionaryEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DictionaryEntriesTable,
    DictionaryEntry,
    $$DictionaryEntriesTableFilterComposer,
    $$DictionaryEntriesTableOrderingComposer,
    $$DictionaryEntriesTableAnnotationComposer,
    $$DictionaryEntriesTableCreateCompanionBuilder,
    $$DictionaryEntriesTableUpdateCompanionBuilder,
    (
      DictionaryEntry,
      BaseReferences<_$AppDatabase, $DictionaryEntriesTable, DictionaryEntry>
    ),
    DictionaryEntry,
    PrefetchHooks Function()>;
typedef $$GrammarRulesTableCreateCompanionBuilder = GrammarRulesCompanion
    Function({
  Value<int> id,
  required String category,
  required String pattern,
  required String correction,
  required String explanation,
  Value<String> exampleWrong,
  Value<String> exampleCorrect,
});
typedef $$GrammarRulesTableUpdateCompanionBuilder = GrammarRulesCompanion
    Function({
  Value<int> id,
  Value<String> category,
  Value<String> pattern,
  Value<String> correction,
  Value<String> explanation,
  Value<String> exampleWrong,
  Value<String> exampleCorrect,
});

class $$GrammarRulesTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarRulesTable> {
  $$GrammarRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pattern => $composableBuilder(
      column: $table.pattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correction => $composableBuilder(
      column: $table.correction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleWrong => $composableBuilder(
      column: $table.exampleWrong, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleCorrect => $composableBuilder(
      column: $table.exampleCorrect,
      builder: (column) => ColumnFilters(column));
}

class $$GrammarRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarRulesTable> {
  $$GrammarRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pattern => $composableBuilder(
      column: $table.pattern, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correction => $composableBuilder(
      column: $table.correction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleWrong => $composableBuilder(
      column: $table.exampleWrong,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleCorrect => $composableBuilder(
      column: $table.exampleCorrect,
      builder: (column) => ColumnOrderings(column));
}

class $$GrammarRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarRulesTable> {
  $$GrammarRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get correction => $composableBuilder(
      column: $table.correction, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get exampleWrong => $composableBuilder(
      column: $table.exampleWrong, builder: (column) => column);

  GeneratedColumn<String> get exampleCorrect => $composableBuilder(
      column: $table.exampleCorrect, builder: (column) => column);
}

class $$GrammarRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GrammarRulesTable,
    GrammarRule,
    $$GrammarRulesTableFilterComposer,
    $$GrammarRulesTableOrderingComposer,
    $$GrammarRulesTableAnnotationComposer,
    $$GrammarRulesTableCreateCompanionBuilder,
    $$GrammarRulesTableUpdateCompanionBuilder,
    (
      GrammarRule,
      BaseReferences<_$AppDatabase, $GrammarRulesTable, GrammarRule>
    ),
    GrammarRule,
    PrefetchHooks Function()> {
  $$GrammarRulesTableTableManager(_$AppDatabase db, $GrammarRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> pattern = const Value.absent(),
            Value<String> correction = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<String> exampleWrong = const Value.absent(),
            Value<String> exampleCorrect = const Value.absent(),
          }) =>
              GrammarRulesCompanion(
            id: id,
            category: category,
            pattern: pattern,
            correction: correction,
            explanation: explanation,
            exampleWrong: exampleWrong,
            exampleCorrect: exampleCorrect,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String category,
            required String pattern,
            required String correction,
            required String explanation,
            Value<String> exampleWrong = const Value.absent(),
            Value<String> exampleCorrect = const Value.absent(),
          }) =>
              GrammarRulesCompanion.insert(
            id: id,
            category: category,
            pattern: pattern,
            correction: correction,
            explanation: explanation,
            exampleWrong: exampleWrong,
            exampleCorrect: exampleCorrect,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GrammarRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GrammarRulesTable,
    GrammarRule,
    $$GrammarRulesTableFilterComposer,
    $$GrammarRulesTableOrderingComposer,
    $$GrammarRulesTableAnnotationComposer,
    $$GrammarRulesTableCreateCompanionBuilder,
    $$GrammarRulesTableUpdateCompanionBuilder,
    (
      GrammarRule,
      BaseReferences<_$AppDatabase, $GrammarRulesTable, GrammarRule>
    ),
    GrammarRule,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TranslationProjectsTableTableManager get translationProjects =>
      $$TranslationProjectsTableTableManager(_db, _db.translationProjects);
  $$VocabularyCardsTableTableManager get vocabularyCards =>
      $$VocabularyCardsTableTableManager(_db, _db.vocabularyCards);
  $$DictionaryEntriesTableTableManager get dictionaryEntries =>
      $$DictionaryEntriesTableTableManager(_db, _db.dictionaryEntries);
  $$GrammarRulesTableTableManager get grammarRules =>
      $$GrammarRulesTableTableManager(_db, _db.grammarRules);
}
