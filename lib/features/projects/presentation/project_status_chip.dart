import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/project_status.dart';

class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ProjectStatus.scheduled => const Color(0xFF64A5FF),
      ProjectStatus.inProduction => const Color(0xFFFFB454),
      ProjectStatus.completed => const Color(0xFF5DD39E),
      ProjectStatus.cancelled => const Color(0xFFFF6B6B),
      _ => AppTheme.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
