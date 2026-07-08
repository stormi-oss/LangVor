import 'package:flutter/material.dart';
import '../../domain/offline_analyzer.dart';
import '../theme/app_colors.dart';

/// Floating tooltip widget shown when user taps a highlighted error.
///
/// Shows category icon, error message, suggested correction,
/// "Apply Fix" button, and "Dismiss" button.
class ErrorTooltip extends StatelessWidget {
  final InlineError error;
  final VoidCallback onApplyFix;
  final VoidCallback onDismiss;
  final VoidCallback onClose;

  const ErrorTooltip({
    super.key,
    required this.error,
    required this.onApplyFix,
    required this.onDismiss,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 8,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(12),
      color: isDark
          ? const Color(0xFF232340)
          : const Color(0xFFFFFFFF),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: category icon + label + close
            Row(
              children: [
                _CategoryBadge(
                  category: error.category,
                  severity: error.severity,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _categoryLabel(error.category),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _severityColor(error.severity),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onClose,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Error message
            Text(
              error.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                height: 1.4,
              ),
            ),
            // Suggestion
            if (error.suggestion != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error.suggestion!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Dismiss'),
                ),
                if (error.suggestion != null) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onApplyFix,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: const Text('Apply Fix'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _severityColor(error.severity),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _categoryLabel(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.spelling:
        return 'Spelling Error';
      case ErrorCategory.grammar:
        return 'Grammar Issue';
      case ErrorCategory.translationMismatch:
        return 'Translation Mismatch';
      case ErrorCategory.missingTerm:
        return 'Missing Translation';
    }
  }

  static Color _severityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.error:
        return const Color(0xFFFF6B6B);
      case ErrorSeverity.warning:
        return const Color(0xFFFFB74D);
      case ErrorSeverity.suggestion:
        return const Color(0xFF64B5F6);
    }
  }
}

/// Category icon badge.
class _CategoryBadge extends StatelessWidget {
  final ErrorCategory category;
  final ErrorSeverity severity;

  const _CategoryBadge({
    required this.category,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color = ErrorTooltip._severityColor(severity);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _icon,
        size: 16,
        color: color,
      ),
    );
  }

  IconData get _icon {
    switch (category) {
      case ErrorCategory.spelling:
        return Icons.spellcheck_rounded;
      case ErrorCategory.grammar:
        return Icons.rule_rounded;
      case ErrorCategory.translationMismatch:
        return Icons.compare_arrows_rounded;
      case ErrorCategory.missingTerm:
        return Icons.help_outline_rounded;
    }
  }
}
