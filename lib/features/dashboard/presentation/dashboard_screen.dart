import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/query_providers.dart';
import '../../../core/theme/app_theme.dart';
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
                    SizedBox(
                      height: 72,
                      child: ClipRect(
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 56,
                              child: CustomPaint(
                                painter: _WaveformPainter(),
                                size: Size.infinite,
                              ),
                            ),
                            Text(
                              'Visão geral',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                        'Acompanhe clientes, agenda e andamento dos trabalhos.'),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 620
                            ? 3
                            : constraints.maxWidth >= 340
                                ? 2
                                : 1;
                        const spacing = 12.0;
                        final width =
                            (constraints.maxWidth - spacing * (columns - 1)) /
                                columns;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            _Metric(
                              width: width,
                              label: 'Agendados',
                              value: scheduled,
                              icon: Icons.event_available_outlined,
                              color: const Color(0xFF64A5FF),
                            ),
                            _Metric(
                              width: width,
                              label: 'Em produção',
                              value: production,
                              icon: Icons.graphic_eq,
                              color: const Color(0xFFFFB454),
                            ),
                            _Metric(
                              width: width,
                              label: 'Finalizados',
                              value: completed,
                              icon: Icons.check_circle_outline,
                              color: const Color(0xFF5DD39E),
                            ),
                          ],
                        );
                      },
                    ),
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
  const _Metric({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final double width;
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(height: 12),
                    Text('$value',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Text(label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ))
                  ]))));
}

class _WaveformPainter extends CustomPainter {
  static const _heights = [
    0.24,
    0.38,
    0.31,
    0.58,
    0.42,
    0.76,
    0.52,
    0.35,
    0.66,
    0.88,
    0.57,
    0.39,
    0.72,
    0.48,
    0.3,
    0.61,
    0.82,
    0.46,
    0.34,
    0.68,
    0.51,
    0.27,
    0.73,
    0.43,
    0.59,
    0.32,
    0.78,
    0.49,
    0.36,
    0.64,
    0.41,
    0.25,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    const barWidth = 4.0;
    const gap = 6.0;
    final count = (size.width / (barWidth + gap)).floor();
    final startX = size.width - count * (barWidth + gap);
    for (var index = 0; index < count; index++) {
      final barHeight = size.height * _heights[index % _heights.length];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startX + index * (barWidth + gap),
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => false;
}
