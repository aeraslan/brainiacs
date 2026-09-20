import 'package:flutter/material.dart';

/// Native emoji glyph via [Text] — never Icons or custom icon fonts.
///
/// Explicit [FontWeight.normal] and platform emoji font fallbacks avoid tofu
/// boxes when the theme would otherwise pick a non-emoji face or bold weight.
class EmojiText extends StatelessWidget {
  const EmojiText(
    this.emoji, {
    super.key,
    required this.size,
    this.textAlign = TextAlign.center,
  });

  final String emoji;
  final double size;
  final TextAlign textAlign;

  static const List<String> fontFamilyFallback = [
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Noto Color Emoji',
    'Noto Emoji',
  ];

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size,
        height: 1,
        fontWeight: FontWeight.normal,
        fontFamilyFallback: fontFamilyFallback,
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      strutStyle: StrutStyle(
        fontSize: size,
        height: 1,
        forceStrutHeight: true,
      ),
    );
  }
}
