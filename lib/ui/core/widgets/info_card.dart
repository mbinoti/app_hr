import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .028),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(14),
          child: child,
        ),
      ),
    );
  }
}

class ListSurface extends StatelessWidget {
  const ListSurface({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: child,
      ),
    );
  }
}
