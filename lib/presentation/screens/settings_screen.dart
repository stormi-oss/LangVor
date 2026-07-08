import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/font_settings.dart';
import '../bloc/settings/settings_bloc.dart';
import '../widgets/app_card.dart';

/// Settings screen: appearance, online translation checking, and about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 48, AppSpacing.xl, AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Settings', style: theme.textTheme.displayLarge)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Customize your learning experience',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.sm),
                    // ── Appearance ──
                    const AppSectionHeader(
                        title: 'Appearance', icon: Icons.palette_rounded),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      children: [
                        AppCardTile(
                          icon: Icons.dark_mode_rounded,
                          title: 'Dark Mode',
                          subtitle:
                              state.themeMode == ThemeMode.dark ? 'On' : 'Off',
                          trailing: Switch(
                            value: state.themeMode == ThemeMode.dark,
                            onChanged: (_) => context
                                .read<SettingsBloc>()
                                .add(const ToggleTheme()),
                            activeThumbColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),
                    // ── Typography ──
                    const AppSectionHeader(
                        title: 'Typography', icon: Icons.text_fields_rounded),
                    const SizedBox(height: AppSpacing.sm),
                    _TypographyCard(state: state)
                        .animate()
                        .fadeIn(delay: 260.ms, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),
                    // ── Online Checking ──
                    const AppSectionHeader(
                      title: 'Online Checking',
                      icon: Icons.cloud_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      children: [
                        AppCardTile(
                          icon: Icons.translate_rounded,
                          title: 'Check against a real translation',
                          subtitle: state.onlineCheckingEnabled
                              ? 'Using MyMemory Translation API — free, no key required'
                              : 'Off — using local checks only',
                          trailing: Switch(
                            value: state.onlineCheckingEnabled,
                            onChanged: (v) => context
                                .read<SettingsBloc>()
                                .add(SetOnlineCheckingEnabled(v)),
                            activeThumbColor: AppColors.primary,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: _ContactEmailField(
                            initialValue: state.contactEmail,
                            onChanged: (v) => context
                                .read<SettingsBloc>()
                                .add(SetContactEmail(v)),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        AppCardTile(
                          icon: Icons.delete_sweep_outlined,
                          title: 'Clear online cache',
                          subtitle: 'Removes cached reference translations',
                          trailing: TextButton(
                            onPressed: () => context
                                .read<SettingsBloc>()
                                .add(const ClearOnlineCache()),
                            child: const Text('Clear'),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                          child: Text(
                            'When online checking is on, the Russian text you '
                            'paste is sent to the MyMemory API to fetch a '
                            'reference translation. Turn it off to keep '
                            'everything on-device.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),
                    // ── About ──
                    const AppSectionHeader(
                        title: 'About', icon: Icons.info_rounded),
                    const SizedBox(height: AppSpacing.sm),
                    const AppCard(
                      children: [
                        AppCardTile(
                          icon: Icons.translate_rounded,
                          title: 'LangVor',
                          subtitle: 'Version 1.0.0',
                        ),
                        Divider(height: 1, indent: 56),
                        AppCardTile(
                          icon: Icons.school_rounded,
                          title: 'Target Level',
                          subtitle: 'A2-B1 → B2 English',
                        ),
                      ],
                    ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Contact-email input with its own persistent [TextEditingController] —
/// kept as a small stateful widget so the cursor/selection survives
/// SettingsBloc rebuilds triggered by every keystroke (a plain
/// `TextEditingController(text: state.contactEmail)` inline in build()
/// would be recreated on every rebuild and jump the cursor to the end).
/// The full typography controls: size (presets + slider), weight, italic,
/// and line height — all applied live and persisted.
class _TypographyCard extends StatelessWidget {
  final SettingsState state;
  const _TypographyCard({required this.state});

  static const _sizePresets = <String, double>{
    'Small': 12,
    'Normal': 14,
    'Large': 16,
    'X-Large': 18,
  };
  static const _lineHeights = [1.2, 1.5, 1.8, 2.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<SettingsBloc>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Live preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            'The quick brown fox jumps over the lazy dog.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Size presets
        _rowLabel(context, 'Size', '${state.fontSize.toInt()}px'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: _sizePresets.entries.map((e) {
            final selected = state.fontSize == e.value;
            return ChoiceChip(
              label: Text(e.key),
              selected: selected,
              onSelected: (_) => bloc.add(SetFontSize(e.value)),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Slider(
          value: state.fontSize.clamp(10, 24),
          min: 10,
          max: 24,
          divisions: 14,
          label: '${state.fontSize.toInt()}px',
          activeColor: AppColors.primary,
          onChanged: (v) => bloc.add(SetFontSize(v.roundToDouble())),
        ),
        const Divider(height: AppSpacing.xl),

        // Weight
        _rowLabel(context, 'Weight',
            FontSettings.weightLabels[state.fontWeightIndex]),
        const SizedBox(height: AppSpacing.sm),
        _SegmentedControl(
          options: FontSettings.weightLabels,
          selectedIndex: state.fontWeightIndex,
          onSelected: (i) => bloc.add(SetFontWeight(i)),
        ),
        const Divider(height: AppSpacing.xl),

        // Line height
        _rowLabel(context, 'Line spacing', '${state.lineHeight}×'),
        const SizedBox(height: AppSpacing.sm),
        _SegmentedControl(
          options: _lineHeights.map((h) => '$h×').toList(),
          selectedIndex: _lineHeights.indexOf(state.lineHeight).clamp(0, 3),
          onSelected: (i) => bloc.add(SetLineHeight(_lineHeights[i])),
        ),
        const Divider(height: AppSpacing.xl),

        // Italic
        Row(
          children: [
            Icon(Icons.format_italic_rounded,
                size: 20, color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('Italic', style: theme.textTheme.titleSmall),
            ),
            Switch(
              value: state.italic,
              onChanged: (v) => bloc.add(SetItalic(v)),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _rowLabel(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const Spacer(),
        Text(value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

/// A compact segmented button row used across the typography controls.
class _SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected
                        ? Colors.white
                        : theme.textTheme.bodySmall?.color,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ContactEmailField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _ContactEmailField({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_ContactEmailField> createState() => _ContactEmailFieldState();
}

class _ContactEmailFieldState extends State<_ContactEmailField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        labelText: 'Contact email (optional)',
        hintText: "Raises MyMemory's free daily quota",
        prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
      ),
    );
  }
}
