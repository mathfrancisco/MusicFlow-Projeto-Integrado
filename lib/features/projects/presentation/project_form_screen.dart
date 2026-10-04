import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/query_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/async_error_view.dart';
import '../domain/project.dart';
import '../domain/project_status.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen(
      {super.key, this.projectId, this.preselectedClientId});
  final String? projectId;
  final String? preselectedClientId;
  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  static const serviceTypes = [
    'Produção musical',
    'Arranjo',
    'Gravação',
    'Edição',
    'Mixagem',
    'Masterização',
    'Produção para evento',
    'Outro'
  ];
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String? _clientId;
  String? _serviceType;
  ProjectStatus _status = ProjectStatus.requested;
  late DateTime _requestedDate = Formatters.day(DateTime.now());
  DateTime? _dueDate;
  DateTime? _createdAt;
  bool _initialLoaded = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _clientId = widget.preselectedClientId;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _load(Project p) {
    if (_initialLoaded) {
      return;
    }
    _initialLoaded = true;
    _clientId = p.clientId;
    _title.text = p.title;
    _serviceType = p.serviceType;
    _description.text = p.description ?? '';
    _requestedDate = Formatters.day(p.requestedDate);
    _dueDate = p.dueDate == null ? null : Formatters.day(p.dueDate!);
    _amount.text = Formatters.currencyInput(p.amount);
    _status = p.status;
    _notes.text = p.notes ?? '';
    _createdAt = p.createdAt;
  }

  Future<DateTime?> _pick(DateTime initial) => showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null || _serviceType == null) return;
    if (_dueDate != null &&
        Formatters.day(_dueDate!).isBefore(Formatters.day(_requestedDate))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('O prazo não pode ser anterior à data inicial.')));
      return;
    }

    final value = Formatters.parseCurrencyInput(_amount.text);
    if (_amount.text.trim().isNotEmpty && value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe um valor válido.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final p = Project(
        id: widget.projectId ?? const Uuid().v4(),
        clientId: _clientId!,
        title: _title.text.trim(),
        serviceType: _serviceType!,
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        requestedDate: _requestedDate,
        dueDate: _dueDate,
        amount: value,
        status: _status,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: _createdAt ?? now,
        updatedAt: now,
      );
      await ref.read(projectRepositoryProvider).save(p);
      ref.invalidate(projectsProvider);
      ref.invalidate(projectByIdProvider(p.id));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projeto salvo com sucesso.')));
      widget.projectId == null
          ? context.pushReplacement('/projects/${p.id}')
          : context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Não foi possível salvar o projeto.')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final projectAsync = widget.projectId == null
        ? const AsyncValue<Project?>.data(null)
        : ref.watch(projectByIdProvider(widget.projectId!));
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.projectId == null ? 'Novo projeto' : 'Editar projeto')),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            AsyncErrorView(onRetry: () => ref.invalidate(clientsProvider)),
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
                child: FilledButton(
                    onPressed: () => context.push('/clients/new'),
                    child: const Text('Cadastrar cliente primeiro')));
          }
          return projectAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => AsyncErrorView(
                onRetry: () =>
                    ref.invalidate(projectByIdProvider(widget.projectId!))),
            data: (project) {
              if (widget.projectId != null && project == null) {
                return const Center(child: Text('Projeto não encontrado.'));
              }
              if (project != null) {
                _load(project);
              }
              if (_clientId != null && !clients.any((c) => c.id == _clientId)) {
                _clientId = null;
              }
              return Form(
                key: _formKey,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  DropdownButtonFormField<String>(
                      initialValue: _clientId,
                      decoration: const InputDecoration(
                          labelText: 'Cliente *',
                          prefixIcon: Icon(Icons.person_outline)),
                      items: clients
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _clientId = v),
                      validator: (v) =>
                          v == null ? 'Selecione um cliente.' : null),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(
                          labelText: 'Título *', prefixIcon: Icon(Icons.title)),
                      validator: (v) =>
                          Validators.requiredText(v, field: 'Título')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                      initialValue: _serviceType,
                      decoration: const InputDecoration(
                          labelText: 'Tipo de serviço *',
                          prefixIcon: Icon(Icons.music_note_outlined)),
                      items: serviceTypes
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _serviceType = v),
                      validator: (v) =>
                          v == null ? 'Selecione o serviço.' : null),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          labelText: 'Descrição', alignLabelWithHint: true)),
                  const SizedBox(height: 12),
                  _DateField(
                      label: 'Data inicial *',
                      value: _requestedDate,
                      onTap: () async {
                        final d = await _pick(_requestedDate);
                        if (!mounted || d == null) return;
                        setState(() => _requestedDate = Formatters.day(d));
                      }),
                  const SizedBox(height: 12),
                  _DateField(
                      label: 'Prazo',
                      value: _dueDate,
                      allowClear: true,
                      onClear: () => setState(() => _dueDate = null),
                      onTap: () async {
                        final d = await _pick(_dueDate ?? _requestedDate);
                        if (!mounted || d == null) return;
                        setState(() => _dueDate = Formatters.day(d));
                      }),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Valor',
                          prefixIcon: Icon(Icons.payments_outlined),
                          hintText: '350,00')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ProjectStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                          labelText: 'Status *',
                          prefixIcon: Icon(Icons.track_changes)),
                      items: ProjectStatus.values
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
                      }),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: _notes,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          labelText: 'Observações', alignLabelWithHint: true)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                      onPressed: _loading ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_loading ? 'Salvando...' : 'Salvar projeto')),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.label,
      required this.value,
      required this.onTap,
      this.allowClear = false,
      this.onClear});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool allowClear;
  final VoidCallback? onClear;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.event_outlined),
              suffixIcon: allowClear && value != null
                  ? IconButton(
                      onPressed: onClear, icon: const Icon(Icons.clear))
                  : const Icon(Icons.chevron_right)),
          child: Text(Formatters.date(value)),
        ),
      );
}
