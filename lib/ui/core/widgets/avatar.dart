import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.take(2).map((part) => part[0]).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC7A7), Color(0xFF6E4AE8)],
        ),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
