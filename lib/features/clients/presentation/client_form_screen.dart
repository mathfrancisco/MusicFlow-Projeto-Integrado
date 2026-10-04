import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/query_providers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/async_error_view.dart';
import '../domain/client.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.clientId});
  final String? clientId;
  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _artistic = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;
  bool _initialLoaded = false;
  DateTime? _createdAt;

  @override
  void dispose() {
    _name.dispose();
    _artistic.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _load(Client c) {
    if (_initialLoaded) {
      return;
    }
    _initialLoaded = true;
    _createdAt = c.createdAt;
    _name.text = c.name;
    _artistic.text = c.artisticName ?? '';
    _phone.text = c.phone;
    _email.text = c.email ?? '';
    _notes.text = c.notes ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final client = Client(
        id: widget.clientId ?? const Uuid().v4(),
        name: _name.text.trim(),
        artisticName:
            _artistic.text.trim().isEmpty ? null : _artistic.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: _createdAt ?? now,
        updatedAt: now,
      );
      await ref.read(clientRepositoryProvider).save(client);
      ref.invalidate(clientsProvider);
      ref.invalidate(clientByIdProvider(client.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente salvo com sucesso.')));
      context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Não foi possível salvar o cliente.')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = widget.clientId == null
        ? const AsyncValue<Client?>.data(null)
        : ref.watch(clientByIdProvider(widget.clientId!));
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.clientId == null ? 'Novo cliente' : 'Editar cliente')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AsyncErrorView(
            onRetry: () =>
                ref.invalidate(clientByIdProvider(widget.clientId!))),
        data: (client) {
          if (widget.clientId != null && client == null) {
            return const Center(child: Text('Cliente não encontrado.'));
          }
          if (client != null) {
            _load(client);
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                        labelText: 'Nome *',
                        prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) =>
                        Validators.requiredText(v, field: 'Nome')),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _artistic,
                    decoration: const InputDecoration(
                        labelText: 'Nome artístico',
                        prefixIcon: Icon(Icons.music_note_outlined))),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Telefone *',
                        prefixIcon: Icon(Icons.phone_outlined)),
                    validator: Validators.phone),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined)),
                    validator: Validators.email),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _notes,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        labelText: 'Observações',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes))),
                const SizedBox(height: 24),
                FilledButton.icon(
                    onPressed: _loading ? null : _save,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: Text(_loading ? 'Salvando...' : 'Salvar cliente')),
              ],
            ),
          );
        },
      ),
    );
  }
}
