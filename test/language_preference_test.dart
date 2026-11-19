import 'package:brainiacs_flutter/core/localization/app_language.dart';
import 'package:brainiacs_flutter/core/localization/locale_provider.dart';
import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to system and persists manual override across restart', () async {
    final storage = LocalStorageService.memory();

    final first = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(first.dispose);

    expect(first.read(languagePreferenceProvider), AppLanguage.system);

    await first
        .read(languagePreferenceProvider.notifier)
        .setPreference(AppLanguage.tr);
    expect(first.read(languagePreferenceProvider), AppLanguage.tr);
    expect(storage.rawLanguagePreference, 'tr');

    final second = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(second.dispose);

    expect(second.read(languagePreferenceProvider), AppLanguage.tr);
  });

  test('changing language does not reset an active session', () async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(type: MiniGameType.math);
    expect(
      container.read(gameSessionProvider).phase,
      GamePhase.countdown,
    );

    await container
        .read(languagePreferenceProvider.notifier)
        .setPreference(AppLanguage.en);

    expect(
      container.read(gameSessionProvider).phase,
      GamePhase.countdown,
    );
    expect(container.read(gameSessionProvider).isPracticeMode, isTrue);
  });

  test('setPreference is idempotent', () async {
    final storage = LocalStorageService.memory({
      LocalStorageService.languagePreferenceKey: 'en',
    });
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(languagePreferenceProvider), AppLanguage.en);
    await container
        .read(languagePreferenceProvider.notifier)
        .setPreference(AppLanguage.en);
    expect(storage.rawLanguagePreference, 'en');
  });
}
