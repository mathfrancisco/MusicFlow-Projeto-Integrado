import 'package:flutter/material.dart';
import '../domain/project_status.dart';

class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) => Chip(label: Text(status.label), visualDensity: VisualDensity.compact);
}
