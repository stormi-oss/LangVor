import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/online/translation_cache.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}

class SetThemeMode extends SettingsEvent {
  final ThemeMode themeMode;
  const SetThemeMode(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class SetFontSize extends SettingsEvent {
  final double fontSize;
  const SetFontSize(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

/// Toggles whether translations are checked against the MyMemory online API
/// in addition to the always-on offline heuristics.
class SetOnlineCheckingEnabled extends SettingsEvent {
  final bool enabled;
  const SetOnlineCheckingEnabled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

/// Optional contact email sent as MyMemory's `de=` parameter, which raises
/// the free daily quota. Never required.
class SetContactEmail extends SettingsEvent {
  final String email;
  const SetContactEmail(this.email);
  @override
  List<Object?> get props => [email];
}

class ClearOnlineCache extends SettingsEvent {
  const ClearOnlineCache();
}

// ─── State ──────────────────────────────────────────────────────────────────

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final double fontSize;
  final bool onlineCheckingEnabled;
  final String contactEmail;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.fontSize = 16.0,
    this.onlineCheckingEnabled = true,
    this.contactEmail = '',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    bool? onlineCheckingEnabled,
    String? contactEmail,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      onlineCheckingEnabled:
          onlineCheckingEnabled ?? this.onlineCheckingEnabled,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }

  @override
  List<Object?> get props =>
      [themeMode, fontSize, onlineCheckingEnabled, contactEmail];
}

// ─── BLoC ───────────────────────────────────────────────────────────────────

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const _keyTheme = 'theme_mode';
  static const _keyFontSize = 'font_size';
  static const _keyOnlineChecking = 'online_checking_enabled';
  static const _keyContactEmail = 'contact_email';

  final TranslationCache _onlineCache;

  SettingsBloc({TranslationCache? onlineCache})
      : _onlineCache = onlineCache ?? TranslationCache(),
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<SetThemeMode>(_onSetThemeMode);
    on<SetFontSize>(_onSetFontSize);
    on<SetOnlineCheckingEnabled>(_onSetOnlineCheckingEnabled);
    on<SetContactEmail>(_onSetContactEmail);
    on<ClearOnlineCache>(_onClearOnlineCache);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_keyTheme) ?? 2; // default dark
    final fontSize = prefs.getDouble(_keyFontSize) ?? 16.0;
    final onlineChecking = prefs.getBool(_keyOnlineChecking) ?? true;
    final contactEmail = prefs.getString(_keyContactEmail) ?? '';

    emit(SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      fontSize: fontSize,
      onlineCheckingEnabled: onlineChecking,
      contactEmail: contactEmail,
    ));
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, newMode.index);
  }

  Future<void> _onSetThemeMode(
    SetThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, event.themeMode.index);
  }

  Future<void> _onSetFontSize(
    SetFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(fontSize: event.fontSize));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, event.fontSize);
  }

  Future<void> _onSetOnlineCheckingEnabled(
    SetOnlineCheckingEnabled event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(onlineCheckingEnabled: event.enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnlineChecking, event.enabled);
  }

  Future<void> _onSetContactEmail(
    SetContactEmail event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(contactEmail: event.email));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyContactEmail, event.email);
  }

  Future<void> _onClearOnlineCache(
    ClearOnlineCache event,
    Emitter<SettingsState> emit,
  ) async {
    await _onlineCache.clear();
  }
}
