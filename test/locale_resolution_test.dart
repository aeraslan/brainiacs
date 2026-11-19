import 'package:brainiacs_flutter/core/localization/app_language.dart';
import 'package:brainiacs_flutter/core/localization/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppLocale', () {
    test('prefers Turkish when it comes first among supported', () {
      expect(
        resolveAppLocale(const [Locale('tr'), Locale('en')]),
        const Locale('tr'),
      );
    });

    test('prefers English when it comes first among supported', () {
      expect(
        resolveAppLocale(const [Locale('en'), Locale('tr')]),
        const Locale('en'),
      );
    });

    test('falls back to English for unsupported-only preferences', () {
      expect(
        resolveAppLocale(const [Locale('de'), Locale('fr')]),
        const Locale('en'),
      );
    });

    test('skips unsupported locales until a supported one appears', () {
      expect(
        resolveAppLocale(const [Locale('ja'), Locale('tr'), Locale('en')]),
        const Locale('tr'),
      );
    });

    test('null or empty preferences fall back to English', () {
      expect(resolveAppLocale(null), const Locale('en'));
      expect(resolveAppLocale(const []), const Locale('en'));
    });
  });

  group('AppLanguage.fromStorage', () {
    test('parses valid values', () {
      expect(AppLanguage.fromStorage('system'), AppLanguage.system);
      expect(AppLanguage.fromStorage('en'), AppLanguage.en);
      expect(AppLanguage.fromStorage('tr'), AppLanguage.tr);
    });

    test('invalid values resolve to system', () {
      expect(AppLanguage.fromStorage(null), AppLanguage.system);
      expect(AppLanguage.fromStorage(''), AppLanguage.system);
      expect(AppLanguage.fromStorage('de'), AppLanguage.system);
      expect(AppLanguage.fromStorage(42), AppLanguage.system);
    });
  });

  group('localeForPreference', () {
    test('system yields null locale (follow device)', () {
      expect(localeForPreference(AppLanguage.system), isNull);
    });

    test('manual overrides map to explicit locales', () {
      expect(localeForPreference(AppLanguage.en), const Locale('en'));
      expect(localeForPreference(AppLanguage.tr), const Locale('tr'));
    });
  });
}
