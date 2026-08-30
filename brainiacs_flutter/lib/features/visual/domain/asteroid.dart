import 'dart:math';
import 'dart:ui';

class Asteroid {
  Asteroid({
    required this.id,
    required this.value,
    required this.displayText,
    required this.radius,
    required this.color,
    required this.angularVelocity,
    required this.position,
    required this.velocity,
    required this.angle,
    this.isPopped = false,
  });

  final int id;
  final int value;
  final String displayText;
  final double radius;
  final Color color;
  final double angularVelocity;

  Offset position;
  Offset velocity;
  double angle;
  bool isPopped;

  bool get needsOrientationHint {
    return displayText == '6' || displayText == '9';
  }
}

abstract final class AsteroidField {
  static const double minSpeed = 18;
  static const double maxSpeed = 42;
  static const double minAngularSpeed = 0.12;
  static const double maxAngularSpeed = 0.55;
  static const double spawnPadding = 8;
  static const int maxPlacementAttempts = 80;

  static const List<Color> palette = [
    Color(0xFFB8E05A),
    Color(0xFFE89A9A),
    Color(0xFF8A8F99),
    Color(0xFFC8E04A),
    Color(0xFF6EC6E8),
    Color(0xFFF0B45A),
    Color(0xFFC4A4E0),
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

  static const Map<int, String> numberWords = {
    1: 'ONE',
    2: 'TWO',
    3: 'THREE',
    4: 'FOUR',
    5: 'FIVE',
    6: 'SIX',
    7: 'SEVEN',
    8: 'EIGHT',
    9: 'NINE',
    10: 'TEN',
    11: 'ELEVEN',
    12: 'TWELVE',
    13: 'THIRTEEN',
    14: 'FOURTEEN',
    15: 'FIFTEEN',
    16: 'SIXTEEN',
    17: 'SEVENTEEN',
    18: 'EIGHTEEN',
    19: 'NINETEEN',
    20: 'TWENTY',
  };

  static List<Asteroid> generate(int level, Size playfield, [Random? random]) {
    final rng = random ?? Random();
    final safeLevel = level < 1 ? 1 : level;
    final count = _countForLevel(safeLevel, rng);
    final entries = _useLetterBoard(safeLevel, rng)
        ? _uniqueLetters(count, rng)
        : _uniqueNumberEntries(safeLevel, count, rng);
    final radii = _radiiForCount(count, playfield, rng);
    final colors = List<Color>.from(palette)..shuffle(rng);

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
      final color = colors[i % colors.length];

      asteroids.add(
        Asteroid(
          id: i,
          value: entry.value,
          displayText: entry.displayText,
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
          displayText: _displayTextFor(
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
        _AsteroidEntry(value: pool[i].codeUnitAt(0), displayText: pool[i]),
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

  static String _displayTextFor({
    required int value,
    required bool allowWords,
    required Random rng,
  }) {
    if (!allowWords) {
      return '$value';
    }

    final absolute = value.abs();
    final word = numberWords[absolute];
    if (word == null || rng.nextDouble() > 0.34) {
      return '$value';
    }

    if (value < 0) {
      return 'MINUS $word';
    }
    return word;
  }
}

class _AsteroidEntry {
  const _AsteroidEntry({required this.value, required this.displayText});

  final int value;
  final String displayText;
}
