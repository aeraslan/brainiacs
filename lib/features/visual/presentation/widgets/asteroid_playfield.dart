import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/asteroid.dart';
import '../visual_colors.dart';
import '../visual_sort_notifier.dart';
import '../../../../shared/widgets/animated_orbital_rings.dart';
import 'asteroid_sprite.dart';

class AsteroidPlayfield extends ConsumerStatefulWidget {
  const AsteroidPlayfield({super.key, this.asteroidKeys});

  final Map<int, GlobalKey>? asteroidKeys;

  @override
  ConsumerState<AsteroidPlayfield> createState() => _AsteroidPlayfieldState();
}

class _AsteroidPlayfieldState extends ConsumerState<AsteroidPlayfield>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Size _playfieldSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    final dt = delta.inMicroseconds / 1000000;
    if (dt <= 0 || dt > 0.08) {
      return;
    }
    if (_playfieldSize.shortestSide < 8) {
      return;
    }

    final asteroids = ref.read(visualSortProvider).asteroids;
    if (asteroids.isEmpty) {
      return;
    }

    var moved = false;
    for (final asteroid in asteroids) {
      if (asteroid.isPopped) {
        continue;
      }
      _advanceAsteroid(asteroid, dt, _playfieldSize);
      moved = true;
    }
    _resolveCollisions(asteroids, _playfieldSize);

    if (moved && mounted) {
      setState(() {});
    }
  }

  void _advanceAsteroid(Asteroid asteroid, double dt, Size bounds) {
    asteroid.position += asteroid.velocity * dt;
    asteroid.angle += asteroid.angularVelocity * dt;
    _clampToBounds(asteroid, bounds);
  }

  void _resolveCollisions(List<Asteroid> asteroids, Size bounds) {
    final active = [
      for (final asteroid in asteroids)
        if (!asteroid.isPopped) asteroid,
    ];

    for (var i = 0; i < active.length; i++) {
      for (var j = i + 1; j < active.length; j++) {
        _bounceIfOverlapping(active[i], active[j]);
      }
    }

    for (final asteroid in active) {
      _clampToBounds(asteroid, bounds);
    }
  }

  void _bounceIfOverlapping(Asteroid first, Asteroid second) {
    final delta = second.position - first.position;
    var distance = delta.distance;
    final minDistance = first.radius + second.radius;
    if (distance >= minDistance) {
      return;
    }

    final Offset normal;
    if (distance < 0.001) {
      normal = const Offset(1, 0);
      distance = 0.001;
    } else {
      normal = delta / distance;
    }

    final overlap = minDistance - distance;
    first.position -= normal * (overlap * 0.5);
    second.position += normal * (overlap * 0.5);

    final relativeVelocity = second.velocity - first.velocity;
    final approaching =
        relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;
    if (approaching >= 0) {
      return;
    }

    final firstMass = first.radius * first.radius;
    final secondMass = second.radius * second.radius;
    final impulse = (2 * approaching) / (firstMass + secondMass);
    first.velocity += normal * (impulse * secondMass);
    second.velocity -= normal * (impulse * firstMass);
  }

  void _clampToBounds(Asteroid asteroid, Size bounds) {
    var next = asteroid.position;
    var velocity = asteroid.velocity;

    final minX = asteroid.radius;
    final maxX = bounds.width - asteroid.radius;
    final minY = asteroid.radius;
    final maxY = bounds.height - asteroid.radius;

    if (next.dx < minX) {
      next = Offset(minX, next.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    } else if (maxX >= minX && next.dx > maxX) {
      next = Offset(maxX, next.dy);
      velocity = Offset(velocity.dx.abs() * -1, velocity.dy);
    }

    if (next.dy < minY) {
      next = Offset(next.dx, minY);
      velocity = Offset(velocity.dx, -velocity.dy.abs());
    } else if (maxY >= minY && next.dy > maxY) {
      next = Offset(next.dx, maxY);
      velocity = Offset(velocity.dx, velocity.dy.abs() * -1);
    }

    asteroid.position = next;
    asteroid.velocity = velocity;
  }

  void _scheduleSpawn(Size size) {
    final alreadySpawned =
        size == _playfieldSize &&
        ref.read(visualSortProvider).asteroids.isNotEmpty;
    _playfieldSize = size;
    if (alreadySpawned) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(visualSortProvider.notifier).ensureSpawned(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asteroids = ref.watch(visualSortProvider.select((s) => s.asteroids));
    final boardGeneration = ref.watch(
      visualSortProvider.select((s) => s.boardGeneration),
    );
    final shakingAsteroidId = ref.watch(
      visualSortProvider.select((s) => s.shakingAsteroidId),
    );
    final shakeToken = ref.watch(
      visualSortProvider.select((s) => s.shakeToken),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _scheduleSpawn(size);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedOrbitalRings(ringColor: VisualColors.ring),
            ),
            for (final asteroid in asteroids)
              Positioned(
                key: ValueKey('$boardGeneration-${asteroid.id}'),
                left: asteroid.position.dx - asteroid.radius,
                top: asteroid.position.dy - asteroid.radius,
                child: KeyedSubtree(
                  key: widget.asteroidKeys?[asteroid.id],
                  child: AsteroidSprite(
                    asteroid: asteroid,
                    isShaking: shakingAsteroidId == asteroid.id,
                    shakeToken: shakeToken,
                    onTapped: ref
                        .read(visualSortProvider.notifier)
                        .onAsteroidTapped,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
