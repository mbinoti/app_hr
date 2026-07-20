import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'info_card.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 46),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7558EF), Color(0xFF4A2CCB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.rows});

  final String title;
  final List<DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          InfoCard(
            child: Column(
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Icon(row.icon, size: 16, color: AppColors.muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            row.label,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            row.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRowData {
  const DetailRowData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class MetricColumn extends StatelessWidget {
  const MetricColumn({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
