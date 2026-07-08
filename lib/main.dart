import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/database.dart';
import 'domain/dictionary_seeder.dart';
import 'domain/offline_analyzer.dart';
import 'domain/nlp/english_wordlist.dart';
import 'app.dart';
import 'presentation/bloc/translation/translation_bloc.dart';
import 'presentation/bloc/vocabulary/vocabulary_bloc.dart';
import 'presentation/bloc/settings/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime fetching of fonts to prevent SocketExceptions and support 100% offline use
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize database
  final database = AppDatabase();

  // Seed dictionary and grammar rules on first launch (async, non-blocking UI)
  final seeder = DictionarySeeder(database);
  () async {
    try {
      await seeder.seedAll();
    } catch (_) {
      // Dictionary/grammar assets may not exist yet — silently skip
    }
  }();

  // Load the English spell-check wordlist in the background — SpellChecker
  // returns no errors until this completes, so it never blocks the UI.
  EnglishWordlist.instance.load();

  // Create offline analyzer
  final analyzer = OfflineAnalyzer();

  // Run the app with BLoC providers
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsBloc()..add(const LoadSettings()),
        ),
        BlocProvider(
          create: (_) => TranslationBloc(database, analyzer: analyzer),
        ),
        BlocProvider(
          create: (_) => VocabularyBloc(database),
        ),
      ],
      child: const LangVorApp(),
    ),
  );
}
