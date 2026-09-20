import 'package:flutter/material.dart';

/// Renders a Balance Logic weight object from an asset path.
class BalanceObjectImage extends StatelessWidget {
  const BalanceObjectImage({
    super.key,
    required this.assetPath,
    required this.size,
  });

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image_outlined,
            size: size * 0.7,
            color: Colors.black26,
          );
        },
      ),
    );
  }
}
