import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' show Value;
import '../../../data/database.dart';
import '../../../domain/offline_analyzer.dart';
import '../../../domain/online/online_translation_checker.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends TranslationEvent {
  const LoadProjects();
}

class CreateProject extends TranslationEvent {
  final String sourceText;
  const CreateProject(this.sourceText);

  @override
  List<Object?> get props => [sourceText];
}

class SelectProject extends TranslationEvent {
  final int projectId;
  const SelectProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class DeleteProject extends TranslationEvent {
  final int projectId;
  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class UpdateSourceText extends TranslationEvent {
  final String text;
  final String deltaJson;
  const UpdateSourceText(this.text, this.deltaJson);

  @override
  List<Object?> get props => [text, deltaJson];
}

class UpdateTranslationText extends TranslationEvent {
  final String text;
  final String deltaJson;
  const UpdateTranslationText(this.text, this.deltaJson);

  @override
  List<Object?> get props => [text, deltaJson];
}

class RunAnalysis extends TranslationEvent {
  const RunAnalysis();
}

class DismissError extends TranslationEvent {
  final String errorId;
  const DismissError(this.errorId);

  @override
  List<Object?> get props => [errorId];
}

class ApplySuggestion extends TranslationEvent {
  final String errorId;
  const ApplySuggestion(this.errorId);

  @override
  List<Object?> get props => [errorId];
}

class LookupWord extends TranslationEvent {
  final String word;
  const LookupWord(this.word);

  @override
  List<Object?> get props => [word];
}

class DismissLookup extends TranslationEvent {
  const DismissLookup();
}

class ToggleVerseMode extends TranslationEvent {
  final bool isVerseMode;
  const ToggleVerseMode(this.isVerseMode);

  @override
  List<Object?> get props => [isVerseMode];
}

/// Runs after local analysis completes — compares the translation against
/// a live MyMemory reference translation. Internal; dispatched by the bloc
/// itself, gated on [TranslationState.onlineCheckingEnabled].
class RunOnlineCheck extends TranslationEvent {
  const RunOnlineCheck();
}

/// Forwards the current online-checking preference from SettingsBloc.
/// Keeps TranslationBloc decoupled from SettingsBloc (both are flat
/// siblings under one MultiBlocProvider) — see the BlocListener in app.dart.
class SyncOnlineCheckSettings extends TranslationEvent {
  final bool enabled;
  final String contactEmail;
  const SyncOnlineCheckSettings({
    required this.enabled,
    required this.contactEmail,
  });

  @override
  List<Object?> get props => [enabled, contactEmail];
}

// ─── State ──────────────────────────────────────────────────────────────────

enum TranslationStatus { initial, loading, loaded, error }

class TranslationState extends Equatable {
  final TranslationStatus status;
  final List<TranslationProject> projects;
  final TranslationProject? selectedProject;
  final String sourceText;
  final String translationText;
  final String sourceDelta;
  final String translationDelta;
  final AnalysisResult? analysisResult;
  final bool isAnalyzing;
  final String? errorMessage;
  // Dictionary lookup state
  final List<DictionaryEntry> lookupResults;
  final String? lookupWord;
  final bool isLookupLoading;
  // Online translation checking (MyMemory), synced from SettingsBloc
  final bool onlineCheckingEnabled;
  final String contactEmail;
  final bool isCheckingOnline;

  const TranslationState({
    this.status = TranslationStatus.initial,
    this.projects = const [],
    this.selectedProject,
    this.sourceText = '',
    this.translationText = '',
    this.sourceDelta = '',
    this.translationDelta = '',
    this.analysisResult,
    this.isAnalyzing = false,
    this.errorMessage,
    this.lookupResults = const [],
    this.lookupWord,
    this.isLookupLoading = false,
    this.onlineCheckingEnabled = true,
    this.contactEmail = '',
    this.isCheckingOnline = false,
  });

  /// Inline errors from analysis.
  List<InlineError> get inlineErrors => analysisResult?.errors ?? [];

  /// Overall score (0.0–1.0).
  double get overallScore => analysisResult?.overallScore ?? 0.0;

  /// Feedback text.
  String get feedback => analysisResult?.feedback ?? '';

  /// Number of active (non-dismissed) errors.
  int get activeErrorCount => analysisResult?.activeErrorCount ?? 0;

  TranslationState copyWith({
    TranslationStatus? status,
    List<TranslationProject>? projects,
    TranslationProject? selectedProject,
    bool clearSelectedProject = false,
    String? sourceText,
    String? translationText,
    String? sourceDelta,
    String? translationDelta,
    AnalysisResult? analysisResult,
    bool? isAnalyzing,
    bool clearAnalysis = false,
    String? errorMessage,
    List<DictionaryEntry>? lookupResults,
    String? lookupWord,
    bool? isLookupLoading,
    bool clearLookup = false,
    bool? onlineCheckingEnabled,
    String? contactEmail,
    bool? isCheckingOnline,
  }) {
    return TranslationState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      selectedProject: clearSelectedProject
          ? null
          : (selectedProject ?? this.selectedProject),
      sourceText: sourceText ?? this.sourceText,
      translationText: translationText ?? this.translationText,
      sourceDelta: sourceDelta ?? this.sourceDelta,
      translationDelta: translationDelta ?? this.translationDelta,
      analysisResult:
          clearAnalysis ? null : (analysisResult ?? this.analysisResult),
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage ?? this.errorMessage,
      lookupResults:
          clearLookup ? const [] : (lookupResults ?? this.lookupResults),
      lookupWord: clearLookup ? null : (lookupWord ?? this.lookupWord),
      isLookupLoading: isLookupLoading ?? this.isLookupLoading,
      onlineCheckingEnabled:
          onlineCheckingEnabled ?? this.onlineCheckingEnabled,
      contactEmail: contactEmail ?? this.contactEmail,
      isCheckingOnline: isCheckingOnline ?? this.isCheckingOnline,
    );
  }

  @override
  List<Object?> get props => [
        status,
        projects,
        selectedProject,
        sourceText,
        translationText,
        sourceDelta,
        translationDelta,
        analysisResult,
        isAnalyzing,
        errorMessage,
        lookupResults,
        lookupWord,
        isLookupLoading,
        onlineCheckingEnabled,
        contactEmail,
        isCheckingOnline,
      ];
}

// ─── BLoC ───────────────────────────────────────────────────────────────────

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final AppDatabase _db;
  final OfflineAnalyzer _analyzer;
  final OnlineTranslationChecker _onlineChecker;

  /// Debounce timer for auto-saving.
  Timer? _saveDebounce;

  /// Debounce timer for auto-analysis after typing stops.
  Timer? _analysisDebounce;

  /// Guards against a stale online-check response overwriting a newer one
  /// when the user kept typing while a request was in flight.
  int _onlineCheckGeneration = 0;

  TranslationBloc(
    this._db, {
    OfflineAnalyzer? analyzer,
    OnlineTranslationChecker? onlineChecker,
  })  : _analyzer = analyzer ?? OfflineAnalyzer(),
        _onlineChecker = onlineChecker ?? OnlineTranslationChecker(),
        super(const TranslationState()) {
    on<LoadProjects>(_onLoadProjects);
    on<CreateProject>(_onCreateProject);
    on<SelectProject>(_onSelectProject);
    on<DeleteProject>(_onDeleteProject);
    on<UpdateSourceText>(_onUpdateSourceText);
    on<UpdateTranslationText>(_onUpdateTranslationText);
    on<RunAnalysis>(_onRunAnalysis);
    on<RunOnlineCheck>(_onRunOnlineCheck);
    on<SyncOnlineCheckSettings>(_onSyncOnlineCheckSettings);
    on<DismissError>(_onDismissError);
    on<ApplySuggestion>(_onApplySuggestion);
    on<LookupWord>(_onLookupWord);
    on<DismissLookup>(_onDismissLookup);
    on<ToggleVerseMode>(_onToggleVerseMode);
  }

  @override
  Future<void> close() {
    _saveDebounce?.cancel();
    _analysisDebounce?.cancel();
    _onlineChecker.dispose();
    return super.close();
  }

  // ── Project CRUD ──

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<TranslationState> emit,
  ) async {
    emit(state.copyWith(status: TranslationStatus.loading));
    try {
      final projects = await _db.getAllProjects();
      emit(state.copyWith(
        status: TranslationStatus.loaded,
        projects: projects,
        clearSelectedProject: true,
        sourceText: '',
        translationText: '',
        sourceDelta: '',
        translationDelta: '',
        clearAnalysis: true,
        clearLookup: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TranslationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<TranslationState> emit,
  ) async {
    try {
      if (event.sourceText.trim().isEmpty) {
        emit(state.copyWith(
          errorMessage: 'Please enter some text to translate.',
        ));
        return;
      }

      // Generate title from first ~50 chars
      final title = event.sourceText.length > 50
          ? '${event.sourceText.substring(0, 50).trim()}…'
          : event.sourceText.trim();

      final now = DateTime.now();
      final projectId = await _db.insertProject(
        TranslationProjectsCompanion.insert(
          title: title,
          sourceText: event.sourceText,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Reload and select the new project
      add(const LoadProjects());
      add(SelectProject(projectId));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to create project: $e',
      ));
    }
  }

  Future<void> _onSelectProject(
    SelectProject event,
    Emitter<TranslationState> emit,
  ) async {
    try {
      final projects = state.projects.isEmpty
          ? await _db.getAllProjects()
          : state.projects;
      final project =
          projects.where((p) => p.id == event.projectId).firstOrNull;

      if (project == null) {
        emit(state.copyWith(
          errorMessage: 'Project not found.',
        ));
        return;
      }

      emit(state.copyWith(
        status: TranslationStatus.loaded,
        projects: projects,
        selectedProject: project,
        sourceText: project.sourceText,
        translationText: project.userTranslation,
        sourceDelta: project.sourceFormatted,
        translationDelta: project.translationFormatted,
        clearAnalysis: true,
        clearLookup: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load project: $e',
      ));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<TranslationState> emit,
  ) async {
    try {
      await _db.deleteProject(event.projectId);
      final isSelectedDeleted =
          state.selectedProject?.id == event.projectId;
      if (isSelectedDeleted) {
        emit(state.copyWith(
          clearSelectedProject: true,
          sourceText: '',
          translationText: '',
          clearAnalysis: true,
        ));
      }
      add(const LoadProjects());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete project: $e'));
    }
  }

  // ── Text Updates ──

  Future<void> _onUpdateSourceText(
    UpdateSourceText event,
    Emitter<TranslationState> emit,
  ) async {
    emit(state.copyWith(
      sourceText: event.text,
      sourceDelta: event.deltaJson,
    ));

    _scheduleSave();
  }

  Future<void> _onUpdateTranslationText(
    UpdateTranslationText event,
    Emitter<TranslationState> emit,
  ) async {
    emit(state.copyWith(
      translationText: event.text,
      translationDelta: event.deltaJson,
    ));

    _scheduleSave();

    // Auto-trigger analysis after 800ms of inactivity
    _analysisDebounce?.cancel();
    _analysisDebounce = Timer(const Duration(milliseconds: 800), () {
      add(const RunAnalysis());
    });
  }

  // ── Analysis ──

  Future<void> _onRunAnalysis(
    RunAnalysis event,
    Emitter<TranslationState> emit,
  ) async {
    if (state.translationText.trim().isEmpty) return;

    emit(state.copyWith(isAnalyzing: true));

    try {
      final result = await _analyzer.analyze(
        sourceRussian: state.sourceText,
        userEnglish: state.translationText,
        db: _db,
        isVerseMode: state.selectedProject?.isVerseMode ?? false,
      );

      emit(state.copyWith(
        isAnalyzing: false,
        analysisResult: result,
      ));

      if (state.onlineCheckingEnabled) {
        add(const RunOnlineCheck());
      }
    } catch (e) {
      emit(state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Analysis failed: $e',
      ));
    }
  }

  Future<void> _onRunOnlineCheck(
    RunOnlineCheck event,
    Emitter<TranslationState> emit,
  ) async {
    if (state.sourceText.trim().isEmpty ||
        state.translationText.trim().isEmpty) {
      return;
    }

    final generation = ++_onlineCheckGeneration;
    emit(state.copyWith(isCheckingOnline: true));

    final result = await _onlineChecker.check(
      sourceRussian: state.sourceText,
      userEnglish: state.translationText,
      contactEmail: state.contactEmail,
    );

    // The user kept typing and a newer check superseded this one — drop it.
    if (generation != _onlineCheckGeneration || emit.isDone) return;

    if (!result.isAvailable || state.analysisResult == null) {
      emit(state.copyWith(isCheckingOnline: false));
      return;
    }

    // Blend the online coverage signal into the existing local result:
    // replace the coverage score with the online similarity and attach
    // the reference translation, but keep the local spelling/grammar
    // errors — those remain valid regardless of the coverage source.
    final base = state.analysisResult!;
    final merged = base.copyWith(
      checkSource: result.source,
      referenceTranslation: result.referenceTranslation,
      translationGrade: result.grade,
      onlineFeedback: result.feedback,
      coverageScore: result.similarity,
      overallScore:
          (base.overallScore * 0.7 + result.similarity * 0.3).clamp(0.0, 1.0),
    );

    emit(state.copyWith(isCheckingOnline: false, analysisResult: merged));
  }

  void _onSyncOnlineCheckSettings(
    SyncOnlineCheckSettings event,
    Emitter<TranslationState> emit,
  ) {
    emit(state.copyWith(
      onlineCheckingEnabled: event.enabled,
      contactEmail: event.contactEmail,
    ));
  }

  void _onDismissError(
    DismissError event,
    Emitter<TranslationState> emit,
  ) {
    if (state.analysisResult == null) return;

    final updatedErrors = state.analysisResult!.errors.map((e) {
      if (e.id == event.errorId) {
        return e.copyWith(dismissed: true);
      }
      return e;
    }).toList();

    emit(state.copyWith(
      analysisResult: state.analysisResult!.copyWith(errors: updatedErrors),
    ));
  }

  void _onApplySuggestion(
    ApplySuggestion event,
    Emitter<TranslationState> emit,
  ) {
    if (state.analysisResult == null) return;

    final error = state.analysisResult!.errors
        .where((e) => e.id == event.errorId)
        .firstOrNull;

    if (error == null || error.suggestion == null) return;
    if (error.startOffset == error.endOffset) return; // No valid span

    // Replace the error span with the suggestion in the translation text
    final text = state.translationText;
    if (error.startOffset >= 0 && error.endOffset <= text.length) {
      final newText = text.substring(0, error.startOffset) +
          error.suggestion! +
          text.substring(error.endOffset);

      emit(state.copyWith(
        translationText: newText,
        clearAnalysis: true, // Will re-analyze
      ));

      _scheduleSave();

      // Re-analyze after applying
      _analysisDebounce?.cancel();
      _analysisDebounce = Timer(const Duration(milliseconds: 500), () {
        add(const RunAnalysis());
      });
    }
  }

  // ── Dictionary Lookup ──

  Future<void> _onLookupWord(
    LookupWord event,
    Emitter<TranslationState> emit,
  ) async {
    final word = event.word.trim().toLowerCase();
    if (word.isEmpty) return;

    emit(state.copyWith(
      lookupWord: event.word,
      isLookupLoading: true,
      lookupResults: const [],
    ));

    try {
      final results = await _db.lookupWord(word);
      emit(state.copyWith(
        lookupResults: results,
        isLookupLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLookupLoading: false,
        lookupResults: const [],
      ));
    }
  }

  void _onDismissLookup(
    DismissLookup event,
    Emitter<TranslationState> emit,
  ) {
    emit(state.copyWith(clearLookup: true));
  }

  Future<void> _onToggleVerseMode(
    ToggleVerseMode event,
    Emitter<TranslationState> emit,
  ) async {
    if (state.selectedProject == null) return;
    try {
      final updatedProject = state.selectedProject!.copyWith(
        isVerseMode: event.isVerseMode,
        updatedAt: DateTime.now(),
      );
      await _db.updateProject(updatedProject);
      emit(state.copyWith(
        selectedProject: updatedProject,
      ));
      // Re-run analysis with the new mode
      add(const RunAnalysis());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update verse mode: $e'));
    }
  }

  // ── Persistence ──

  /// Debounced save — persists current text to database after 500ms.
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _persistProject();
    });
  }

  Future<void> _persistProject() async {
    try {
      if (state.selectedProject == null) return;
      final project = state.selectedProject!;

      await _db.updateProject(TranslationProject(
        id: project.id,
        title: project.title,
        sourceText: state.sourceText,
        userTranslation: state.translationText,
        sourceFormatted: state.sourceDelta,
        translationFormatted: state.translationDelta,
        isVerseMode: project.isVerseMode,
        createdAt: project.createdAt,
        updatedAt: DateTime.now(),
      ));
    } catch (_) {
      // Silently fail on background saves
    }
  }
}
