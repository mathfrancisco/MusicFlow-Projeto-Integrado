import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/query_providers.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../projects/domain/project.dart';
import '../../projects/domain/project_status.dart';
import '../../projects/presentation/project_status_chip.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final clientsAsync = ref.watch(clientsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            AsyncErrorView(onRetry: () => ref.invalidate(projectsProvider)),
        data: (projects) => clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              AsyncErrorView(onRetry: () => ref.invalidate(clientsProvider)),
          data: (clients) {
            final active = projects
                .where((project) =>
                    project.status != ProjectStatus.completed &&
                    project.status != ProjectStatus.cancelled)
                .toList()
              ..sort((a, b) => _date(a).compareTo(_date(b)));
            if (active.isEmpty) {
              return const EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'Agenda vazia',
                  message:
                      'Projetos ativos aparecerão aqui ordenados por data.');
            }

            final clientById = {
              for (final client in clients) client.id: client.name
            };
            final entries = <_CalendarEntry>[];
            DateTime? previousDay;
            for (final project in active) {
              final day = _day(_date(project));
              if (previousDay != day) {
                entries.add(_CalendarDate(day));
                previousDay = day;
              }
              entries.add(_CalendarProject(project));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                if (entry is _CalendarDate) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(DateFormat('dd/MM/yyyy').format(entry.day),
                        style: Theme.of(context).textTheme.titleMedium),
                  );
                }
                final project = (entry as _CalendarProject).project;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      onTap: () => context.push('/projects/${project.id}'),
                      leading:
                          const CircleAvatar(child: Icon(Icons.music_note)),
                      title: Text(project.title),
                      subtitle: Text(clientById[project.clientId] ??
                          'Cliente não encontrado'),
                      trailing: ProjectStatusChip(status: project.status),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static DateTime _date(Project project) =>
      project.dueDate ?? project.requestedDate;
  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

sealed class _CalendarEntry {}

class _CalendarDate extends _CalendarEntry {
  _CalendarDate(this.day);
  final DateTime day;
}

class _CalendarProject extends _CalendarEntry {
  _CalendarProject(this.project);
  final Project project;
}
