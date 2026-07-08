import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
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
                        const Divider(height: 1, indent: 56),
                        AppCardTile(
                          icon: Icons.text_fields_rounded,
                          title: 'Font Size',
                          subtitle: '${state.fontSize.toInt()}px',
                          trailing: SizedBox(
                            width: 160,
                            child: Slider(
                              value: state.fontSize,
                              min: 12,
                              max: 24,
                              divisions: 6,
                              label: '${state.fontSize.toInt()}px',
                              onChanged: (v) => context
                                  .read<SettingsBloc>()
                                  .add(SetFontSize(v)),
                              activeColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

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
