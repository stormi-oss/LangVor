import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/bloc/settings/settings_bloc.dart';
import 'presentation/bloc/translation/translation_bloc.dart';
import 'presentation/screens/rich_translation_workspace.dart';
import 'presentation/screens/vocabulary_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/theme/app_colors.dart';
import 'presentation/widgets/keyboard_shortcuts_wrapper.dart';
import 'presentation/widgets/new_project_dialog.dart';

/// Root application widget with theme management and adaptive navigation.
class LangVorApp extends StatelessWidget {
  const LangVorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          title: 'LangVor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.onlineCheckingEnabled !=
                    current.onlineCheckingEnabled ||
                previous.contactEmail != current.contactEmail,
            listener: (context, settings) {
              context.read<TranslationBloc>().add(SyncOnlineCheckSettings(
                    enabled: settings.onlineCheckingEnabled,
                    contactEmail: settings.contactEmail,
                  ));
            },
            child: const _AppShell(),
          ),
        );
      },
    );
  }
}

/// Adaptive navigation shell — uses NavigationRail on desktop,
/// NavigationBar on mobile.
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    RichTranslationWorkspace(),
    VocabularyScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.translate_rounded),
      selectedIcon: Icon(Icons.translate_rounded),
      label: 'Translate',
    ),
    NavigationDestination(
      icon: Icon(Icons.style_outlined),
      selectedIcon: Icon(Icons.style_rounded),
      label: 'Vocabulary',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  static const _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.translate_rounded),
      selectedIcon: Icon(Icons.translate_rounded),
      label: Text('Translate'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.style_outlined),
      selectedIcon: Icon(Icons.style_rounded),
      label: Text('Vocabulary'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: Text('Settings'),
    ),
  ];

  void _openNewProjectDialog() {
    setState(() => _currentIndex = 0);
    showDialog(
      context: context,
      builder: (dialogContext) => NewProjectDialog(
        onSubmit: (text) {
          context.read<TranslationBloc>().add(CreateProject(text));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardShortcutsWrapper(
      onSubmitTranslation: () =>
          context.read<TranslationBloc>().add(const RunAnalysis()),
      onNewProject: _openNewProjectDialog,
      onEscape: () => Navigator.of(context).maybePop(),
      child: _buildShell(context, isWide, isDark),
    );
  }

  Widget _buildShell(BuildContext context, bool isWide, bool isDark) {
    if (isWide) {
      // Desktop: NavigationRail on the left
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) =>
                  setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'L',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              destinations: _railDestinations,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.darkDivider
                  : AppColors.lightDivider,
            ),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    // Mobile: Bottom NavigationBar
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _destinations,
        height: 65,
      ),
    );
  }
}
