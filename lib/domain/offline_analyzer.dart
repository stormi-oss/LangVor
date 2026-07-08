import '../data/database.dart';
import 'nlp/tokenizer.dart';
import 'nlp/spell_checker.dart';
import 'nlp/grammar_checker.dart';
import 'nlp/translation_matcher.dart';
import 'online/online_translation_checker.dart';

/// Severity levels for inline errors.
enum ErrorSeverity { error, warning, suggestion }

/// Categories of errors detected by the offline engine.
enum ErrorCategory { spelling, grammar, translationMismatch, missingTerm }

/// A single positioned error in the user's translation text.
class InlineError {
  final String id;
  final int startOffset;
  final int endOffset;
  final ErrorSeverity severity;
  final String message;
  final String? suggestion;
  final ErrorCategory category;
  final bool dismissed;

  const InlineError({
    required this.id,
    required this.startOffset,
    required this.endOffset,
    required this.severity,
    required this.message,
    this.suggestion,
    required this.category,
    this.dismissed = false,
  });

  InlineError copyWith({bool? dismissed}) => InlineError(
        id: id,
        startOffset: startOffset,
        endOffset: endOffset,
        severity: severity,
        message: message,
        suggestion: suggestion,
        category: category,
        dismissed: dismissed ?? this.dismissed,
      );
}

/// Unified result of all offline analysis phases.
class AnalysisResult {
  final List<InlineError> errors;
  final double overallScore; // 0.0–1.0
  final String feedback;
  final double coverageScore;
  final int totalSourceTerms;
  final int coveredTerms;

  /// Where the translation-coverage signal came from: a live MyMemory
  /// translation, a cached one, or the offline dictionary fallback.
  final CheckSource checkSource;

  /// A reference machine translation of the source, shown to the user as
  /// "here's one way to say it" — only present when [checkSource] is
  /// [CheckSource.online] or [CheckSource.cache].
  final String? referenceTranslation;

  /// The graded quality band from the online check, if available.
  final TranslationGrade? translationGrade;

  /// Detailed, human-readable reviewer feedback lines from the online check.
  final List<String> onlineFeedback;

  const AnalysisResult({
    required this.errors,
    required this.overallScore,
    required this.feedback,
    this.coverageScore = 1.0,
    this.totalSourceTerms = 0,
    this.coveredTerms = 0,
    this.checkSource = CheckSource.offlineFallback,
    this.referenceTranslation,
    this.translationGrade,
    this.onlineFeedback = const [],
  });

  AnalysisResult copyWith({
    List<InlineError>? errors,
    double? overallScore,
    String? feedback,
    double? coverageScore,
    int? totalSourceTerms,
    int? coveredTerms,
    CheckSource? checkSource,
    String? referenceTranslation,
    TranslationGrade? translationGrade,
    List<String>? onlineFeedback,
  }) {
    return AnalysisResult(
      errors: errors ?? this.errors,
      overallScore: overallScore ?? this.overallScore,
      feedback: feedback ?? this.feedback,
      coverageScore: coverageScore ?? this.coverageScore,
      totalSourceTerms: totalSourceTerms ?? this.totalSourceTerms,
      coveredTerms: coveredTerms ?? this.coveredTerms,
      checkSource: checkSource ?? this.checkSource,
      referenceTranslation: referenceTranslation ?? this.referenceTranslation,
      translationGrade: translationGrade ?? this.translationGrade,
      onlineFeedback: onlineFeedback ?? this.onlineFeedback,
    );
  }

  /// Number of active (non-dismissed) errors.
  int get activeErrorCount => errors.where((e) => !e.dismissed).length;

  /// Empty result for initial state.
  static const empty = AnalysisResult(
    errors: [],
    overallScore: 0.0,
    feedback: '',
  );
}

/// The core offline analysis engine.
///
/// Orchestrates all three phases:
/// - Phase A: Tokenization
/// - Phase B: Spell checking + Grammar checking
/// - Phase C: Translation matching
class OfflineAnalyzer {
  /// Run full analysis pipeline.
  Future<AnalysisResult> analyze({
    required String sourceRussian,
    required String userEnglish,
    required AppDatabase db,
    bool isVerseMode = false,
  }) async {
    if (userEnglish.trim().isEmpty) {
      return const AnalysisResult(
        errors: [],
        overallScore: 0.0,
        feedback: 'Start typing your translation to get feedback.',
      );
    }

    final allErrors = <InlineError>[];
    int errorIdCounter = 0;
    String nextId() => 'err_${errorIdCounter++}';

    final separator = isVerseMode ? '\n' : '\n\n';
    final russianParagraphs = sourceRussian.split(separator);
    final englishParagraphs = userEnglish.split(separator);

    int currentEnglishOffset = 0;
    int totalSourceTerms = 0;
    int coveredTerms = 0;
    double coverageScoreSum = 0.0;
    int matchedParagraphPairs = 0;

    for (int i = 0; i < englishParagraphs.length; i++) {
      final engParagraph = englishParagraphs[i];
      final rusParagraph = i < russianParagraphs.length ? russianParagraphs[i] : '';

      if (engParagraph.isEmpty) {
        currentEnglishOffset += engParagraph.length + separator.length;
        continue;
      }

      // ── Phase A: Tokenize current paragraph ──
      final tokens = Tokenizer.tokenize(engParagraph);

      // ── Phase B: Spell Check current paragraph ──
      final spellErrors = await SpellChecker.check(tokens);
      for (final se in spellErrors) {
        final suggestionText = se.suggestions.isNotEmpty
            ? se.suggestions.first
            : null;
        allErrors.add(InlineError(
          id: nextId(),
          startOffset: currentEnglishOffset + se.token.startOffset,
          endOffset: currentEnglishOffset + se.token.endOffset,
          severity: ErrorSeverity.error,
          message: 'Possible spelling error: "${se.token.raw}".'
              '${se.suggestions.isNotEmpty ? ' Did you mean: ${se.suggestions.join(", ")}?' : ''}',
          suggestion: suggestionText,
          category: ErrorCategory.spelling,
        ));
      }

      // ── Phase B: Grammar Check current paragraph ──
      final grammarErrors = await GrammarChecker.check(engParagraph, tokens, db);
      for (final ge in grammarErrors) {
        allErrors.add(InlineError(
          id: nextId(),
          startOffset: currentEnglishOffset + ge.startOffset,
          endOffset: currentEnglishOffset + ge.endOffset,
          severity: ge.category == 'grammar'
              ? ErrorSeverity.warning
              : ErrorSeverity.suggestion,
          message: ge.message,
          suggestion: ge.suggestion,
          category: ErrorCategory.grammar,
        ));
      }

      // ── Phase C: Translation Matching current paragraph ──
      if (rusParagraph.trim().isNotEmpty) {
        final matchResult = await TranslationMatcher.match(
          sourceRussian: rusParagraph,
          userEnglish: engParagraph,
          db: db,
        );

        totalSourceTerms += matchResult.totalSourceTerms;
        coveredTerms += matchResult.coveredTerms;
        coverageScoreSum += matchResult.coverageScore;
        matchedParagraphPairs++;

        // Missing terms
        for (final mt in matchResult.missingTerms) {
          allErrors.add(InlineError(
            id: nextId(),
            startOffset: currentEnglishOffset, // Place at start of paragraph if missing
            endOffset: currentEnglishOffset,
            severity: ErrorSeverity.suggestion,
            message:
                'Missing translation for "${mt.russianWord}". '
                'Expected: ${mt.expectedEnglish.join(" / ")}.',
            suggestion: mt.expectedEnglish.isNotEmpty
                ? mt.expectedEnglish.first
                : null,
            category: ErrorCategory.missingTerm,
          ));
        }

        // Potential mistranslations
        for (final pm in matchResult.potentialMistranslations) {
          final matchingToken = tokens.where(
              (t) => t.normalized == pm.userWord.toLowerCase()).firstOrNull;

          allErrors.add(InlineError(
            id: nextId(),
            startOffset: matchingToken != null
                ? (currentEnglishOffset + matchingToken.startOffset)
                : currentEnglishOffset,
            endOffset: matchingToken != null
                ? (currentEnglishOffset + matchingToken.endOffset)
                : currentEnglishOffset,
            severity: ErrorSeverity.warning,
            message:
                'Possible mistranslation of "${pm.russianWord}". '
                'You wrote "${pm.userWord}", expected: ${pm.expectedWords.join(" / ")}.',
            suggestion: pm.expectedWords.isNotEmpty
                ? pm.expectedWords.first
                : null,
            category: ErrorCategory.translationMismatch,
          ));
        }
      }

      currentEnglishOffset += engParagraph.length + separator.length;
    }

    // Calculate aggregated coverage score
    final double coverageScore = matchedParagraphPairs > 0
        ? (coverageScoreSum / matchedParagraphPairs)
        : (userEnglish.trim().isNotEmpty ? 1.0 : 0.0);

    // ── Calculate overall score ──
    // Weighted: spelling errors = -0.15 each, grammar = -0.10, missing = -0.05
    double score = 1.0;
    for (final error in allErrors) {
      switch (error.category) {
        case ErrorCategory.spelling:
          score -= 0.15;
          break;
        case ErrorCategory.grammar:
          score -= 0.10;
          break;
        case ErrorCategory.translationMismatch:
          score -= 0.10;
          break;
        case ErrorCategory.missingTerm:
          score -= 0.05;
          break;
      }
    }
    // Factor in coverage
    score = score * 0.7 + coverageScore * 0.3;
    score = score.clamp(0.0, 1.0);

    // ── Generate feedback ──
    final feedback = _generateFeedback(score, allErrors.length,
        coverageScore, totalSourceTerms);

    // Sort errors by position
    allErrors.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    return AnalysisResult(
      errors: allErrors,
      overallScore: score,
      feedback: feedback,
      coverageScore: coverageScore,
      totalSourceTerms: totalSourceTerms,
      coveredTerms: coveredTerms,
    );
  }

  /// Generate encouraging feedback based on score.
  String _generateFeedback(
      double score, int errorCount, double coverage, int totalTerms) {
    if (errorCount == 0 && coverage >= 0.9) {
      return '🎉 Excellent translation! No issues found.';
    }
    if (errorCount == 0) {
      return '✅ No spelling or grammar errors. '
          'Coverage: ${(coverage * 100).toInt()}% of source content.';
    }
    if (score >= 0.85) {
      return '👍 Good translation! $errorCount minor '
          '${errorCount == 1 ? "issue" : "issues"} found.';
    }
    if (score >= 0.65) {
      return '📝 Decent effort! $errorCount '
          '${errorCount == 1 ? "issue" : "issues"} to review.';
    }
    if (score >= 0.4) {
      return '🔍 Keep going! $errorCount '
          '${errorCount == 1 ? "issue" : "issues"} found. '
          'Check spelling and grammar.';
    }
    return '💪 $errorCount ${errorCount == 1 ? "issue" : "issues"} found. '
        'Review your translation carefully.';
  }
}

