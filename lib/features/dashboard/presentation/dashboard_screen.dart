import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/query_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../projects/domain/project.dart';
import '../../projects/domain/project_status.dart';
import '../../projects/presentation/project_status_chip.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final clientsAsync = ref.watch(clientsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('MusicFlow')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/projects/new'),
          icon: const Icon(Icons.add),
          label: const Text('Novo projeto')),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            AsyncErrorView(onRetry: () => ref.invalidate(projectsProvider)),
        data: (projects) => clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              AsyncErrorView(onRetry: () => ref.invalidate(clientsProvider)),
          data: (clients) {
            final clientById = {
              for (final client in clients) client.id: client.name
            };
            final scheduled = projects
                .where((p) => p.status == ProjectStatus.scheduled)
                .length;
            final production = projects
                .where((p) => p.status == ProjectStatus.inProduction)
                .length;
            final completed = projects
                .where((p) => p.status == ProjectStatus.completed)
                .length;
            final upcoming = projects
                .where((p) =>
                    p.status != ProjectStatus.completed &&
                    p.status != ProjectStatus.cancelled)
                .toList()
              ..sort((a, b) => _date(a).compareTo(_date(b)));
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(projectsProvider);
                ref.invalidate(clientsProvider);
                await ref.read(projectsProvider.future);
              },
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Text('Visão geral',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    const Text(
                        'Acompanhe clientes, agenda e andamento dos trabalhos.'),
                    const SizedBox(height: 18),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      _Metric(
                          label: 'Agendados',
                          value: scheduled,
                          icon: Icons.event_available_outlined),
                      _Metric(
                          label: 'Em produção',
                          value: production,
                          icon: Icons.graphic_eq),
                      _Metric(
                          label: 'Finalizados',
                          value: completed,
                          icon: Icons.check_circle_outline),
                    ]),
                    const SizedBox(height: 28),
                    Row(children: [
                      Expanded(
                          child: Text('Próximos trabalhos',
                              style: Theme.of(context).textTheme.titleLarge)),
                      TextButton(
                          onPressed: () => context.go('/projects'),
                          child: const Text('Ver todos'))
                    ]),
                    const SizedBox(height: 8),
                    if (projects.isEmpty)
                      const EmptyState(
                          icon: Icons.library_music_outlined,
                          title: 'Comece cadastrando um projeto',
                          message:
                              'Use o botão Novo projeto para registrar o primeiro serviço.')
                    else if (upcoming.isEmpty)
                      const EmptyState(
                          icon: Icons.task_alt,
                          title: 'Tudo concluído',
                          message: 'Não há projetos ativos no momento.')
                    else
                      ...upcoming.take(5).map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                              child: ListTile(
                                  contentPadding: const EdgeInsets.all(14),
                                  onTap: () =>
                                      context.push('/projects/${p.id}'),
                                  title: Text(p.title),
                                  subtitle: Text(
                                      '${clientById[p.clientId] ?? 'Cliente'} • ${Formatters.date(_date(p))}'),
                                  trailing:
                                      ProjectStatusChip(status: p.status))))),
                  ]),
            );
          },
        ),
      ),
    );
  }

  static DateTime _date(Project p) => p.dueDate ?? p.requestedDate;
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 170,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon),
                    const SizedBox(height: 18),
                    Text('$value',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Text(label)
                  ]))));
}
