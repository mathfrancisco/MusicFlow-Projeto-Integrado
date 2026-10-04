import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/query_providers.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/client.dart';

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo cliente'),
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            AsyncErrorView(onRetry: () => ref.invalidate(clientsProvider)),
        data: (clients) {
          final query = _query.trim().toLowerCase();
          final filtered = clients
              .where((client) =>
                  query.isEmpty ||
                  client.name.toLowerCase().contains(query) ||
                  (client.artisticName ?? '').toLowerCase().contains(query))
              .toList();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(clientsProvider);
              await ref.read(clientsProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              hintText: 'Buscar por nome ou nome artístico',
                              prefixIcon: Icon(Icons.search)),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (clients.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.people_outline,
                      title: 'Nenhum cliente cadastrado',
                      message: 'Cadastre o primeiro cliente para começar.',
                      actionLabel: 'Cadastrar cliente',
                      onAction: () => context.push('/clients/new'),
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                        icon: Icons.search_off,
                        title: 'Nenhum resultado',
                        message: 'Tente outro termo de busca.'),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _ClientCard(client: filtered[index]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});
  final Client client;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: ListTile(
            leading: CircleAvatar(
                child: Text(
                    client.name.isEmpty ? '?' : client.name[0].toUpperCase())),
            title: Text(client.name),
            subtitle: Text([
              if ((client.artisticName ?? '').isNotEmpty) client.artisticName!,
              client.phone
            ].join(' • ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/clients/${client.id}/edit'),
          ),
        ),
      );
}
