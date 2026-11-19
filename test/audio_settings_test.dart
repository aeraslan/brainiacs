import 'package:brainiacs_flutter/core/audio/audio_controller_provider.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container([Map<String, dynamic>? initial]) {
  return ProviderContainer(
    overrides: [
      localStorageProvider.overrideWithValue(
        LocalStorageService.memory(initial),
      ),
    ],
  );
}

void main() {
  // Intentionally no TestWidgetsFlutterBinding — AudioController skips
  // platform channels and records accepted plays for assertions.

  test('hydrates bgm/sfx from storage and defaults to true', () {
    final defaults = _container();
    addTearDown(defaults.dispose);
    expect(defaults.read(audioControllerProvider).bgmEnabled, isTrue);
    expect(defaults.read(audioControllerProvider).sfxEnabled, isTrue);

    final muted = _container({
      LocalStorageService.bgmEnabledKey: false,
      LocalStorageService.sfxEnabledKey: false,
    });
    addTearDown(muted.dispose);
    expect(muted.read(audioControllerProvider).bgmEnabled, isFalse);
    expect(muted.read(audioControllerProvider).sfxEnabled, isFalse);
  });

  test('four Music/SFX combinations gate playback independently', () async {
    final container = _container();
    addTearDown(container.dispose);
    final audio = container.read(audioControllerProvider.notifier);

    Future<void> assertCombo({
      required bool bgm,
      required bool sfx,
    }) async {
      audio.debugAcceptedPlays.clear();
      await audio.setBgmEnabled(bgm);
      await audio.setSfxEnabled(sfx);
      await audio.playMenuBGM();
      await audio.playCorrect();
      await audio.playCountdown();
      await audio.playTimeUpAlarm();
      await audio.playSlotSpin();

      final plays = audio.debugAcceptedPlays;
      if (bgm) {
        expect(plays, contains(AudioAssets.bgmMenu));
      } else {
        expect(plays, isNot(contains(AudioAssets.bgmMenu)));
      }
      if (sfx) {
        expect(plays, contains(AudioAssets.correct));
        expect(plays, contains(AudioAssets.countdown));
        expect(plays, contains(AudioAssets.timeUpAlarm));
        expect(plays, contains(AudioAssets.slotSpin));
      } else {
        expect(plays, isNot(contains(AudioAssets.correct)));
        expect(plays, isNot(contains(AudioAssets.countdown)));
        expect(plays, isNot(contains(AudioAssets.timeUpAlarm)));
        expect(plays, isNot(contains(AudioAssets.slotSpin)));
      }
    }

    await assertCombo(bgm: true, sfx: true);
    await assertCombo(bgm: true, sfx: false);
    await assertCombo(bgm: false, sfx: true);
    await assertCombo(bgm: false, sfx: false);
  });

  test('muted BGM at startup does not accept menu music', () async {
    final container = _container({
      LocalStorageService.bgmEnabledKey: false,
    });
    addTearDown(container.dispose);
    final audio = container.read(audioControllerProvider.notifier);
    await audio.playMenuBGM();
    expect(audio.debugAcceptedPlays, isEmpty);
    expect(container.read(audioControllerProvider).activeBgm, BgmTrack.menu);
  });

  test('disabling SFX stops slot spin and persists preference', () async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);
    final audio = container.read(audioControllerProvider.notifier);

    await audio.playSlotSpin();
    expect(audio.debugAcceptedPlays, contains(AudioAssets.slotSpin));

    await audio.setSfxEnabled(false);
    expect(container.read(audioControllerProvider).sfxEnabled, isFalse);
    expect(storage.sfxEnabled, isFalse);

    audio.debugAcceptedPlays.clear();
    await audio.playSlotSpin();
    expect(audio.debugAcceptedPlays, isEmpty);
  });

  test('toggleBGM remains compatible and setBgmEnabled is idempotent', () async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);
    final audio = container.read(audioControllerProvider.notifier);

    await audio.toggleBGM();
    expect(container.read(audioControllerProvider).bgmEnabled, isFalse);
    expect(storage.bgmEnabled, isFalse);

    await audio.setBgmEnabled(false);
    expect(container.read(audioControllerProvider).bgmEnabled, isFalse);

    await audio.setBgmEnabled(true);
    expect(container.read(audioControllerProvider).bgmEnabled, isTrue);
    expect(storage.bgmEnabled, isTrue);
  });
}
