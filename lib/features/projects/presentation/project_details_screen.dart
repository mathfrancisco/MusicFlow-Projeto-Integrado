import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/query_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_error_view.dart';
import '../domain/project_status.dart';
import 'project_status_chip.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  bool _updatingStatus = false;

  Future<void> _changeStatus(ProjectStatus current) async {
    final selected = await showModalBottomSheet<ProjectStatus>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<ProjectStatus>(
          groupValue: current,
          onChanged: (value) => Navigator.pop(sheetContext, value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                  title: Text('Alterar status',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              ...ProjectStatus.values.map((status) =>
                  RadioListTile<ProjectStatus>(
                      value: status, title: Text(status.label))),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null || selected == current) {
      return;
    }

    setState(() => _updatingStatus = true);
    try {
      await ref
          .read(projectRepositoryProvider)
          .updateStatus(widget.projectId, selected);
      ref.invalidate(projectsProvider);
      ref.invalidate(projectByIdProvider(widget.projectId));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Status atualizado.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Não foi possível atualizar o status. Tente novamente.')));
      }
    } finally {
      if (mounted) {
        setState(() => _updatingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectByIdProvider(widget.projectId));
    final clientsAsync = ref.watch(clientsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/projects'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Detalhes do projeto'),
        actions: [
          IconButton(
              tooltip: 'Editar projeto',
              onPressed: () =>
                  context.push('/projects/${widget.projectId}/edit'),
              icon: const Icon(Icons.edit_outlined))
        ],
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AsyncErrorView(
            onRetry: () =>
                ref.invalidate(projectByIdProvider(widget.projectId))),
        data: (project) {
          if (project == null) {
            return const Center(child: Text('Projeto não encontrado.'));
          }
          return clientsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                AsyncErrorView(onRetry: () => ref.invalidate(clientsProvider)),
            data: (clients) {
              final clientById = {
                for (final client in clients) client.id: client.name
              };
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.title,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 10),
                          ProjectStatusChip(status: project.status),
                          const SizedBox(height: 18),
                          _Info(
                              label: 'Cliente',
                              value: clientById[project.clientId] ??
                                  'Cliente não encontrado'),
                          _Info(label: 'Serviço', value: project.serviceType),
                          _Info(
                              label: 'Data inicial',
                              value: Formatters.date(project.requestedDate)),
                          _Info(
                              label: 'Prazo',
                              value: Formatters.date(project.dueDate)),
                          _Info(
                              label: 'Valor',
                              value: Formatters.currency(project.amount)),
                        ],
                      ),
                    ),
                  ),
                  if ((project.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Section(title: 'Descrição', text: project.description!),
                  ],
                  if ((project.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Section(title: 'Observações', text: project.notes!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _updatingStatus
                        ? null
                        : () => _changeStatus(project.status),
                    icon: const Icon(Icons.sync_alt),
                    label: Text(
                        _updatingStatus ? 'Atualizando...' : 'Alterar status'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/projects/${widget.projectId}/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar projeto'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 95,
                child:
                    Text(label, style: Theme.of(context).textTheme.bodySmall)),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(text)
            ],
          ),
        ),
      );
}
