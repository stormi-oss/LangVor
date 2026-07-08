import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Custom formatting toolbar for the rich text editors.
///
/// Provides Bold, Italic, Font Size dropdown, Undo, and Redo buttons.
/// Operates on whichever [QuillController] is currently active.
class FormattingToolbar extends StatelessWidget {
  final QuillController? activeController;

  const FormattingToolbar({
    super.key,
    this.activeController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = activeController;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF0F1F5),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF2A2A4A)
                : const Color(0xFFE4E6EF),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // Bold
          _ToolbarButton(
            icon: Icons.format_bold_rounded,
            tooltip: 'Bold',
            isActive: controller != null &&
                _isAttributeActive(controller, Attribute.bold),
            onPressed: controller != null
                ? () => _toggleAttribute(controller, Attribute.bold)
                : null,
          ),
          // Italic
          _ToolbarButton(
            icon: Icons.format_italic_rounded,
            tooltip: 'Italic',
            isActive: controller != null &&
                _isAttributeActive(controller, Attribute.italic),
            onPressed: controller != null
                ? () => _toggleAttribute(controller, Attribute.italic)
                : null,
          ),
          const _ToolbarDivider(),
          // Font Size Dropdown
          _FontSizeDropdown(
            controller: controller,
          ),
          const _ToolbarDivider(),
          // Undo
          _ToolbarButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onPressed: controller != null
                ? () => controller.undo()
                : null,
          ),
          // Redo
          _ToolbarButton(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onPressed: controller != null
                ? () => controller.redo()
                : null,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  bool _isAttributeActive(QuillController controller, Attribute attribute) {
    return controller.getSelectionStyle().containsKey(attribute.key);
  }

  void _toggleAttribute(QuillController controller, Attribute attribute) {
    final isActive = _isAttributeActive(controller, attribute);
    if (isActive) {
      controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }
}

/// Individual toolbar button with active state.
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFF6C63FF);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? primaryColor.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 20,
              color: onPressed == null
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : isActive
                      ? primaryColor
                      : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }
}

/// Font size dropdown.
class _FontSizeDropdown extends StatelessWidget {
  final QuillController? controller;

  const _FontSizeDropdown({this.controller});

  static const _sizes = [12.0, 14.0, 16.0, 18.0, 20.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopupMenuButton<double>(
      tooltip: 'Font Size',
      enabled: controller != null,
      onSelected: (size) {
        if (controller == null) return;
        controller!.formatSelection(Attribute.fromKeyValue(
          'size', size.toInt().toString(),
        )!);
      },
      itemBuilder: (_) => _sizes.map((s) {
        return PopupMenuItem<double>(
          value: s,
          child: Text(
            '${s.toInt()} px',
            style: TextStyle(fontSize: s),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2A2A4A)
                : const Color(0xFFE4E6EF),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_size_rounded,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical divider in toolbar.
class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 1,
        height: 22,
        color: isDark
            ? const Color(0xFF2A2A4A)
            : const Color(0xFFE4E6EF),
      ),
    );
  }
}
