import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/query_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/project.dart';
import '../domain/project_status.dart';
import 'project_status_chip.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  String _query = '';
  ProjectStatus? _status;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final clientsAsync = ref.watch(clientsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Projetos')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/new'),
        icon: const Icon(Icons.add),
        label: const Text('Novo projeto'),
      ),
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
            final query = _query.trim().toLowerCase();
            final filtered = projects.where((project) {
              final client = clientById[project.clientId] ?? '';
              final matchesQuery = query.isEmpty ||
                  project.title.toLowerCase().contains(query) ||
                  project.serviceType.toLowerCase().contains(query) ||
                  client.toLowerCase().contains(query);
              return matchesQuery &&
                  (_status == null || project.status == _status);
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              hintText: 'Buscar projeto, serviço ou cliente',
                              prefixIcon: Icon(Icons.search)),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                  label: const Text('Todos'),
                                  selected: _status == null,
                                  onSelected: (_) =>
                                      setState(() => _status = null)),
                              const SizedBox(width: 8),
                              ...ProjectStatus.values.map((status) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                        label: Text(status.label),
                                        selected: _status == status,
                                        onSelected: (_) =>
                                            setState(() => _status = status)),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (projects.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.library_music_outlined,
                      title: 'Nenhum projeto cadastrado',
                      message:
                          'Crie o primeiro projeto para acompanhar os serviços.',
                      actionLabel: 'Cadastrar projeto',
                      onAction: () => context.push('/projects/new'),
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'Nenhum projeto encontrado',
                        message: 'Altere a busca ou os filtros.'),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _ProjectCard(
                          project: filtered[index],
                          clientName: clientById[filtered[index].clientId]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.clientName});
  final Project project;
  final String? clientName;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push('/projects/${project.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(project.title,
                              style: Theme.of(context).textTheme.titleMedium)),
                      const SizedBox(width: 8),
                      ProjectStatusChip(status: project.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(project.serviceType),
                  const SizedBox(height: 4),
                  Text(clientName ?? 'Cliente não encontrado',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text('Prazo: ${Formatters.date(project.dueDate)}'),
                ],
              ),
            ),
          ),
        ),
      );
}
