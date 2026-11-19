import 'dart:math';
import 'dart:ui';

class Asteroid {
  Asteroid({
    required this.id,
    required this.value,
    required this.radius,
    required this.color,
    required this.angularVelocity,
    required this.position,
    required this.velocity,
    required this.angle,
    this.letterLabel,
    this.showsNumberWord = false,
    this.isPopped = false,
  });

  final int id;
  final int value;

  /// Non-null for letter boards (Latin A–Z gameplay labels).
  final String? letterLabel;

  /// When true, UI may show a localized number word for [value].
  final bool showsNumberWord;

  final double radius;
  final Color color;
  final double angularVelocity;

  Offset position;
  Offset velocity;
  double angle;
  bool isPopped;
}

abstract final class AsteroidField {
  static const double minSpeed = 18;
  static const double maxSpeed = 42;
  static const double minAngularSpeed = 0.12;
  static const double maxAngularSpeed = 0.55;
  static const double spawnPadding = 8;
  static const int maxPlacementAttempts = 80;

  /// Vibrant rock fills — bright enough for dark labels, no sky-like blues.
  static const List<Color> palette = [
    Color(0xFFFF6B6B), // coral
    Color(0xFFFF9F1C), // orange
    Color(0xFFFFE66D), // sunny yellow
    Color(0xFF2EC4B6), // teal
    Color(0xFFC77DFF), // light violet
    Color(0xFFFF85A1), // rose pink
    Color(0xFF80ED99), // lime
    Color(0xFFFF7F51), // peach
  ];

  static const List<String> letterPool = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  /// Words longer than this get cramped inside typical asteroid radii.
  static const int maxNumberWordLength = 6;

  static List<Asteroid> generate(int level, Size playfield, [Random? random]) {
    final rng = random ?? Random();
    final safeLevel = level < 1 ? 1 : level;
    final count = _countForLevel(safeLevel, rng);
    final entries = _useLetterBoard(safeLevel, rng)
        ? _uniqueLetters(count, rng)
        : _uniqueNumberEntries(safeLevel, count, rng);
    final radii = _radiiForCount(count, playfield, rng);
    final colors = _uniqueColorsForCount(entries.length, rng);

    final asteroids = <Asteroid>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final radius = radii[i];
      final position = _placeWithoutOverlap(
        playfield: playfield,
        radius: radius,
        placed: asteroids,
        rng: rng,
      );
      final color = colors[i];

      asteroids.add(
        Asteroid(
          id: i,
          value: entry.value,
          letterLabel: entry.letterLabel,
          showsNumberWord: entry.showsNumberWord,
          radius: radius,
          color: color,
          angularVelocity: _randomSignedSpeed(
            rng,
            minAngularSpeed,
            maxAngularSpeed,
          ),
          position: position,
          velocity: _randomVelocity(rng),
          angle: rng.nextDouble() * pi * 2,
        ),
      );
    }

    return asteroids;
  }

  static bool _useLetterBoard(int level, Random rng) {
    if (level < 7) {
      return false;
    }
    if (level <= 9) {
      return rng.nextDouble() < 0.32;
    }
    final chance = (0.4 + (level - 10) * 0.05).clamp(0.4, 0.55);
    return rng.nextDouble() < chance;
  }

  static int _countForLevel(int level, Random rng) {
    if (level <= 3) {
      return 3;
    }
    if (level <= 6) {
      return rng.nextBool() ? 3 : 4;
    }
    if (level <= 9) {
      return rng.nextBool() ? 4 : 5;
    }
    return rng.nextBool() ? 5 : 6;
  }

  /// One distinct color per asteroid in the level (no sky-like blues).
  static List<Color> _uniqueColorsForCount(int count, Random rng) {
    final pool = List<Color>.from(palette)..shuffle(rng);
    final safeCount = count.clamp(1, pool.length);
    return pool.sublist(0, safeCount);
  }

  static List<_AsteroidEntry> _uniqueNumberEntries(
    int level,
    int count,
    Random rng,
  ) {
    final minValue = level <= 4
        ? 1
        : level <= 7
        ? -20
        : -35;
    final maxValue = level <= 4 ? 40 : 50;
    final values = <int>{};

    var attempts = 0;
    while (values.length < count && attempts < 400) {
      attempts++;
      final value = minValue + rng.nextInt(maxValue - minValue + 1);
      if (value == 0) {
        continue;
      }
      values.add(value);
    }

    var fallback = minValue == 0 ? 1 : minValue;
    while (values.length < count) {
      if (fallback != 0) {
        values.add(fallback);
      }
      fallback++;
    }

    return [
      for (final value in values)
        _AsteroidEntry(
          value: value,
          showsNumberWord: _shouldShowNumberWord(
            value: value,
            allowWords: level >= 8,
            rng: rng,
          ),
        ),
    ];
  }

  static List<_AsteroidEntry> _uniqueLetters(int count, Random rng) {
    final pool = List<String>.from(letterPool)..shuffle(rng);
    final safeCount = count.clamp(1, pool.length);
    return [
      for (var i = 0; i < safeCount; i++)
        _AsteroidEntry(
          value: pool[i].codeUnitAt(0),
          letterLabel: pool[i],
        ),
    ];
  }

  static List<double> _radiiForCount(int count, Size playfield, Random rng) {
    final packFactor = switch (count) {
      <= 3 => 2.7,
      4 => 3.2,
      5 => 3.7,
      _ => 4.2,
    };
    final maxByWidth = playfield.width / packFactor;
    final maxByHeight = playfield.height / (packFactor * 0.9);
    final maxRadius = min(maxByWidth, maxByHeight).clamp(52.0, 108.0);
    final minFraction = switch (count) {
      <= 3 => 0.76,
      4 => 0.68,
      _ => 0.6,
    };
    final minRadius = (maxRadius * minFraction).clamp(44.0, 86.0);
    if (minRadius >= maxRadius) {
      return List<double>.filled(count, maxRadius);
    }

    return List<double>.generate(
      count,
      (_) => minRadius + rng.nextDouble() * (maxRadius - minRadius),
    );
  }

  static Offset _placeWithoutOverlap({
    required Size playfield,
    required double radius,
    required List<Asteroid> placed,
    required Random rng,
  }) {
    for (var attempt = 0; attempt < maxPlacementAttempts; attempt++) {
      final candidate = _randomPosition(playfield, radius, rng);
      final overlaps = placed.any((other) {
        final minDistance = other.radius + radius + spawnPadding;
        return (other.position - candidate).distance < minDistance;
      });
      if (!overlaps) {
        return candidate;
      }
    }
    return _randomPosition(playfield, radius, rng);
  }

  static Offset _randomPosition(Size playfield, double radius, Random rng) {
    final minX = radius + spawnPadding;
    final maxX = playfield.width - radius - spawnPadding;
    final minY = radius + spawnPadding;
    final maxY = playfield.height - radius - spawnPadding;

    final x = maxX <= minX
        ? playfield.width / 2
        : minX + rng.nextDouble() * (maxX - minX);
    final y = maxY <= minY
        ? playfield.height / 2
        : minY + rng.nextDouble() * (maxY - minY);
    return Offset(x, y);
  }

  static Offset _randomVelocity(Random rng) {
    final speed = minSpeed + rng.nextDouble() * (maxSpeed - minSpeed);
    final heading = rng.nextDouble() * pi * 2;
    return Offset(cos(heading) * speed, sin(heading) * speed);
  }

  static double _randomSignedSpeed(Random rng, double min, double max) {
    final magnitude = min + rng.nextDouble() * (max - min);
    return rng.nextBool() ? magnitude : -magnitude;
  }

  static bool _shouldShowNumberWord({
    required int value,
    required bool allowWords,
    required Random rng,
  }) {
    if (!allowWords || value < 1 || value > 20) {
      return false;
    }
    return rng.nextDouble() <= 0.34;
  }
}

class _AsteroidEntry {
  const _AsteroidEntry({
    required this.value,
    this.letterLabel,
    this.showsNumberWord = false,
  });

  final int value;
  final String? letterLabel;
  final bool showsNumberWord;
}
