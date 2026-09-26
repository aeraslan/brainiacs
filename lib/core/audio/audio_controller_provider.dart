import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound asset paths under [assets/sounds/] (registered in pubspec.yaml).
abstract final class AudioAssets {
  // Gameplay SFX
  static const String correct = 'assets/sounds/correct.mp3';
  static const String wrong = 'assets/sounds/wrong.mp3';

  // Lifecycle SFX (full 3-2-1-GO clip — play once at countdown start)
  static const String countdown = 'assets/sounds/sfx_beep.mp3';
  static const String timeUpAlarm = 'assets/sounds/sfx_timeup.mp3';
  static const String slotSpin = 'assets/sounds/sfx_slot_spin.mp3';

  // State-based BGM
  static const String bgmMenu = 'assets/sounds/bgm_menu.mp3';
  static const String bgmGame = 'assets/sounds/bgm_game.mp3';
  static const String bgmResult = 'assets/sounds/bgm_result.mp3';
}

enum BgmTrack {
  menu,
  game,
  result,
}

class AudioControllerState {
  const AudioControllerState({
    this.bgmEnabled = true,
    this.activeBgm = BgmTrack.menu,
  });

  final bool bgmEnabled;
  final BgmTrack activeBgm;

  AudioControllerState copyWith({
    bool? bgmEnabled,
    BgmTrack? activeBgm,
  }) {
    return AudioControllerState(
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      activeBgm: activeBgm ?? this.activeBgm,
    );
  }
}

/// Centralized SFX + BGM. Missing assets never crash the app.
///
/// Uses a dedicated looping [AudioPlayer] for BGM, a dedicated slot-spin
/// player (so it can be stopped on lock), and a small SFX pool for one-shots.
class AudioController extends Notifier<AudioControllerState> {
  static const int _sfxPoolSize = 4;

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _slotSpinPlayer;
  final List<AudioPlayer> _sfxPool = <AudioPlayer>[];
  int _sfxIndex = 0;

  @override
  AudioControllerState build() {
    ref.onDispose(() {
      _bgmPlayer?.dispose();
      _bgmPlayer = null;
      _slotSpinPlayer?.dispose();
      _slotSpinPlayer = null;
      for (final player in _sfxPool) {
        player.dispose();
      }
      _sfxPool.clear();
    });
    return const AudioControllerState();
  }

  // --- Gameplay SFX ---------------------------------------------------------

  Future<void> playCorrect() => _playSfx(AudioAssets.correct);

  Future<void> playWrong() => _playSfx(
        AudioAssets.wrong,
        volume: _wrongSfxVolume,
      );

  // --- Lifecycle SFX --------------------------------------------------------

  /// Full 3-2-1-GO sequence — call once when the countdown overlay starts.
  Future<void> playCountdown() => _playSfx(AudioAssets.countdown);

  Future<void> playTimeUpAlarm() async {
    await _playSfx(
      AudioAssets.timeUpAlarm,
      volume: _timeUpSfxVolume,
    );
    // Duck BGM ~40% so the alarm cuts through (SFX is already at player max).
    await _duckBgm(factor: 1 / 1.4);
  }

  /// Combined spin + win clip. Starts with the wheel; let it finish after lock.
  Future<void> playSlotSpin() async {
    debugPrint('AudioController: play SFX → ${AudioAssets.slotSpin}');
    if (!_platformChannelsReady) {
      return;
    }
    try {
      final player = _slotSpinPlayer ??= AudioPlayer();
      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.setVolume(_slotSpinSfxVolume);
      await player.play(AssetSource(_assetSourcePath(AudioAssets.slotSpin)));
    } catch (error, stackTrace) {
      debugPrint(
        'AudioController: missing or unplayable SFX '
        '"${AudioAssets.slotSpin}": $error\n$stackTrace',
      );
    }
  }

  Future<void> stopSlotSpin() async {
    try {
      final player = _slotSpinPlayer;
      if (player == null) {
        return;
      }
      await player.stop();
      await player.release();
    } catch (error, stackTrace) {
      debugPrint('AudioController: stop slot spin failed: $error\n$stackTrace');
    }
  }

  // --- State-based BGM ------------------------------------------------------

  Future<void> playMenuBGM() => _switchBgm(BgmTrack.menu);

  Future<void> playGameBGM() => _switchBgm(BgmTrack.game);

  Future<void> playResultBGM() => _switchBgm(BgmTrack.result);

  /// Game BGM: another 40% quieter than the prior 0.6 bed → 0.36.
  static const double _gameBgmVolume = 0.36;

  /// Menu BGM at 60% (40% quieter than full).
  static const double _menuBgmVolume = 0.6;

  /// Result BGM at 60% (40% quieter than full).
  static const double _resultBgmVolume = 0.6;

  /// Wrong SFX boosted ~30% vs other SFX (others at [_defaultSfxVolume]).
  static const double _wrongSfxVolume = 1.0;

  /// Slot spin ~70% louder than default SFX (clamped to player max).
  static const double _slotSpinSfxVolume = 1.0;

  /// Time-up alarm at player max; BGM is ducked another 40% when it plays.
  static const double _timeUpSfxVolume = 1.0;

  static const double _defaultSfxVolume = 1.0 / 1.3;

  Future<void> toggleBGM() async {
    final nextEnabled = !state.bgmEnabled;
    state = state.copyWith(bgmEnabled: nextEnabled);

    if (!nextEnabled) {
      await _stopBgm();
      return;
    }

    await _startCurrentBgm();
  }

  Future<void> _switchBgm(BgmTrack track) async {
    state = state.copyWith(activeBgm: track);
    if (!state.bgmEnabled) {
      debugPrint(
        'AudioController: BGM muted — remembered ${track.name} track',
      );
      return;
    }
    await _startCurrentBgm();
  }

  Future<void> _startCurrentBgm() async {
    final assetPath = _assetForTrack(state.activeBgm);
    debugPrint('AudioController: play BGM → $assetPath');
    if (!_platformChannelsReady) {
      return;
    }
    try {
      final player = _bgmPlayer ??= AudioPlayer();
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_volumeForTrack(state.activeBgm));
      await player.play(AssetSource(_assetSourcePath(assetPath)));
    } catch (error, stackTrace) {
      debugPrint(
        'AudioController: missing or unplayable BGM "$assetPath": $error\n$stackTrace',
      );
    }
  }

  Future<void> _duckBgm({required double factor}) async {
    if (!_platformChannelsReady || _bgmPlayer == null || !state.bgmEnabled) {
      return;
    }
    try {
      final base = _volumeForTrack(state.activeBgm);
      await _bgmPlayer!.setVolume((base * factor).clamp(0.0, 1.0));
    } catch (error, stackTrace) {
      debugPrint('AudioController: duck BGM failed: $error\n$stackTrace');
    }
  }

  Future<void> _stopBgm() async {
    try {
      await _bgmPlayer?.stop();
    } catch (error, stackTrace) {
      debugPrint('AudioController: stop BGM failed: $error\n$stackTrace');
    }
  }

  static double _volumeForTrack(BgmTrack track) {
    return switch (track) {
      BgmTrack.menu => _menuBgmVolume,
      BgmTrack.game => _gameBgmVolume,
      BgmTrack.result => _resultBgmVolume,
    };
  }

  static String _assetForTrack(BgmTrack track) {
    return switch (track) {
      BgmTrack.menu => AudioAssets.bgmMenu,
      BgmTrack.game => AudioAssets.bgmGame,
      BgmTrack.result => AudioAssets.bgmResult,
    };
  }

  Future<void> _playSfx(
    String assetPath, {
    double volume = _defaultSfxVolume,
  }) async {
    debugPrint('AudioController: play SFX → $assetPath');
    if (!_platformChannelsReady) {
      return;
    }
    try {
      final player = _nextSfxPlayer();
      await player.stop();
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(AssetSource(_assetSourcePath(assetPath)));
    } catch (error, stackTrace) {
      debugPrint(
        'AudioController: missing or unplayable SFX "$assetPath": $error\n$stackTrace',
      );
    }
  }

  AudioPlayer _nextSfxPlayer() {
    if (_sfxPool.isEmpty) {
      for (var i = 0; i < _sfxPoolSize; i++) {
        _sfxPool.add(AudioPlayer());
      }
    }
    final player = _sfxPool[_sfxIndex % _sfxPool.length];
    _sfxIndex = (_sfxIndex + 1) % _sfxPool.length;
    return player;
  }

  /// [AudioPlayer] touches platform channels on construction; skip when the
  /// Flutter binding is not ready (plain unit tests without widget binding).
  static bool get _platformChannelsReady {
    try {
      ServicesBinding.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// [AssetSource] expects a path relative to the assets root (no `assets/` prefix).
  static String _assetSourcePath(String assetPath) {
    const prefix = 'assets/';
    if (assetPath.startsWith(prefix)) {
      return assetPath.substring(prefix.length);
    }
    return assetPath;
  }
}

final audioControllerProvider =
    NotifierProvider<AudioController, AudioControllerState>(
  AudioController.new,
);
