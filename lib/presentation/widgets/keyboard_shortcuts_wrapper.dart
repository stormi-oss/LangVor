import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global keyboard shortcut handler for the app.
///
/// Wraps the child widget and intercepts:
/// - Ctrl+Enter (Cmd+Enter on macOS): Submit translation
/// - Ctrl+H (Cmd+H on macOS): Request hint
/// - Ctrl+N (Cmd+N on macOS): New project
/// - Escape: Dismiss hint / back
class KeyboardShortcutsWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSubmitTranslation;
  final VoidCallback? onRequestHint;
  final VoidCallback? onNewProject;
  final VoidCallback? onEscape;

  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.onSubmitTranslation,
    this.onRequestHint,
    this.onNewProject,
    this.onEscape,
  });

  /// Returns true if the platform uses Cmd (macOS) instead of Ctrl.
  static bool get _isMacOS {
    try {
      return Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Ctrl+Enter / Cmd+Enter → Submit
        SingleActivator(
          LogicalKeyboardKey.enter,
          control: !_isMacOS,
          meta: _isMacOS,
        ): const _SubmitTranslationIntent(),

        // Ctrl+H / Cmd+H → Hint
        SingleActivator(
          LogicalKeyboardKey.keyH,
          control: !_isMacOS,
          meta: _isMacOS,
        ): const _RequestHintIntent(),

        // Ctrl+N / Cmd+N → New project
        SingleActivator(
          LogicalKeyboardKey.keyN,
          control: !_isMacOS,
          meta: _isMacOS,
        ): const _NewProjectIntent(),

        // Escape → Dismiss / back
        const SingleActivator(LogicalKeyboardKey.escape):
            const _EscapeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SubmitTranslationIntent: CallbackAction<_SubmitTranslationIntent>(
            onInvoke: (_) {
              onSubmitTranslation?.call();
              return null;
            },
          ),
          _RequestHintIntent: CallbackAction<_RequestHintIntent>(
            onInvoke: (_) {
              onRequestHint?.call();
              return null;
            },
          ),
          _NewProjectIntent: CallbackAction<_NewProjectIntent>(
            onInvoke: (_) {
              onNewProject?.call();
              return null;
            },
          ),
          _EscapeIntent: CallbackAction<_EscapeIntent>(
            onInvoke: (_) {
              onEscape?.call();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

class _SubmitTranslationIntent extends Intent {
  const _SubmitTranslationIntent();
}

class _RequestHintIntent extends Intent {
  const _RequestHintIntent();
}

class _NewProjectIntent extends Intent {
  const _NewProjectIntent();
}

class _EscapeIntent extends Intent {
  const _EscapeIntent();
}
