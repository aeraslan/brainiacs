import 'package:flutter/material.dart';

/// A named Stroop color with a saturated Flutter [Color] for readability on sky.
class StroopColor {
  const StroopColor({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final Color color;
}

/// Predefined Stroop palette used by Color Clash.
abstract final class StroopPalette {
  static const StroopColor red = StroopColor(
    id: 'red',
    name: 'Red',
    color: Color(0xFFE53935),
  );

  static const StroopColor blue = StroopColor(
    id: 'blue',
    name: 'Blue',
    color: Color(0xFF1E88E5),
  );

  static const StroopColor green = StroopColor(
    id: 'green',
    name: 'Green',
    color: Color(0xFF43A047),
  );

  static const StroopColor yellow = StroopColor(
    id: 'yellow',
    name: 'Yellow',
    color: Color(0xFFFFD400),
  );

  static const StroopColor pink = StroopColor(
    id: 'pink',
    name: 'Pink',
    color: Color(0xFFFF2E9A),
  );

  static const StroopColor purple = StroopColor(
    id: 'purple',
    name: 'Purple',
    color: Color(0xFF8E24AA),
  );

  static const List<StroopColor> all = [
    red,
    blue,
    green,
    yellow,
    pink,
    purple,
  ];

  static StroopColor byId(String id) {
    for (final entry in all) {
      if (entry.id == id) {
        return entry;
      }
    }
    return red;
  }
}
