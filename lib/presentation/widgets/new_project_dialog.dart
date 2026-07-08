import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Dialog for creating a new translation project.
///
/// Provides a large text area for pasting Russian source text.
class NewProjectDialog extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const NewProjectDialog({super.key, required this.onSubmit});

  @override
  State<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenSize.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'New Translation',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Paste your Russian text below. It will be split into sentences for translation.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              // Text input
              Flexible(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 8,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  decoration: const InputDecoration(
                    hintText: 'Вставьте русский текст здесь...\n\n'
                        'Paste your Russian text here — a paragraph, '
                        'a poem, an article, or even a full chapter.',
                    hintMaxLines: 5,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _hasText
                        ? () {
                            widget.onSubmit(_controller.text.trim());
                            Navigator.of(context).pop();
                          }
                        : null,
                    icon: const Icon(Icons.translate_rounded, size: 18),
                    label: const Text('Start Translating'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
