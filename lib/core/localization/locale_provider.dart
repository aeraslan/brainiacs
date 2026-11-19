import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage_provider.dart';
import 'app_language.dart';

/// Supported app locales (English fallback).
const List<Locale> appSupportedLocales = [
  Locale('en'),
  Locale('tr'),
];

/// Walks [preferred] in OS order and returns the first supported locale.
/// Falls back to English when nothing matches.
Locale resolveAppLocale(List<Locale>? preferred) {
  if (preferred == null || preferred.isEmpty) {
    return const Locale('en');
  }
  for (final locale in preferred) {
    final languageCode = locale.languageCode.toLowerCase();
    if (languageCode == 'tr') {
      return const Locale('tr');
    }
    if (languageCode == 'en') {
      return const Locale('en');
    }
  }
  return const Locale('en');
}

class LanguagePreferenceNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    try {
      final storage = ref.read(localStorageProvider);
      return AppLanguage.fromStorage(storage.rawLanguagePreference);
    } catch (_) {
      return AppLanguage.system;
    }
  }

  /// Idempotent preference update; persists immediately.
  Future<void> setPreference(AppLanguage preference) async {
    if (state == preference) {
      return;
    }
    state = preference;
    try {
      await ref
          .read(localStorageProvider)
          .setLanguagePreference(preference.storageValue);
    } catch (_) {
      // Persistence failures must not crash UI; state already updated.
    }
  }
}

final languagePreferenceProvider =
    NotifierProvider<LanguagePreferenceNotifier, AppLanguage>(
  LanguagePreferenceNotifier.new,
);

/// Explicit [Locale] for MaterialApp, or null for System Default.
Locale? localeForPreference(AppLanguage preference) {
  return switch (preference) {
    AppLanguage.system => null,
    AppLanguage.en => const Locale('en'),
    AppLanguage.tr => const Locale('tr'),
  };
}
