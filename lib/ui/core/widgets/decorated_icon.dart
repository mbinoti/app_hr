import 'package:flutter/material.dart';

class DecoratedIcon extends StatelessWidget {
  const DecoratedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.small = false,
    this.tiny = false,
  });

  final IconData icon;
  final Color color;
  final bool small;
  final bool tiny;

  @override
  Widget build(BuildContext context) {
    final size = tiny ? 26.0 : (small ? 36.0 : 52.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: tiny ? 14 : (small ? 18 : 25)),
    );
  }
}
