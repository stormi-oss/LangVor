import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared bordered card container — the same visual pattern originally
/// duplicated across Settings, Vocabulary, and the translation workspace.
class AppCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: padding != null
            ? Padding(padding: padding!, child: Column(children: children))
            : Column(children: children),
      ),
    );
  }
}

/// A clickable card that lifts slightly and deepens its shadow on hover —
/// the standard interactive surface for project/vocabulary/folder tiles.
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap; // right-click / context menu
  final EdgeInsetsGeometry padding;
  final bool selected;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.onSecondaryTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.selected = false,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = widget.selected
        ? AppColors.primary
        : (isDark ? AppColors.darkDivider : AppColors.lightDivider);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onSecondaryTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? AppColors.hoverShadow(isDark)
                : AppColors.cardShadow(isDark),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A section label with a leading icon, used above an [AppCard] group.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const AppSectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}

/// A single row inside an [AppCard]: icon, title/subtitle, optional trailing.
class AppCardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const AppCardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
