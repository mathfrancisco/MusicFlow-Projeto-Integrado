import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:musicflow/core/providers/app_providers.dart';
import 'package:musicflow/features/clients/data/client_local_data_source.dart';
import 'package:musicflow/features/clients/data/client_repository.dart';
import 'package:musicflow/features/clients/domain/client.dart';
import 'package:musicflow/features/projects/data/project_local_data_source.dart';
import 'package:musicflow/features/projects/data/project_repository.dart';
import 'package:musicflow/features/projects/domain/project.dart';
import 'package:musicflow/features/projects/domain/project_status.dart';
import 'package:musicflow/features/projects/presentation/project_details_screen.dart';
import 'package:musicflow/features/projects/presentation/project_form_screen.dart';

void main() {
  final client = Client(
      id: 'c1',
      name: 'Ana',
      phone: '11999999999',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026));

  testWidgets('editar e salvar sem alterar mantém o valor monetário',
      (tester) async {
    _setTallViewport(tester);
    final projects = _Projects();
    final original = Project(
      id: 'p1',
      clientId: client.id,
      title: 'Single',
      serviceType: 'Mixagem',
      requestedDate: DateTime(2026, 10, 4),
      amount: 350,
      status: ProjectStatus.requested,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    projects.values[original.id] = original;

    final router = _router(client, '/projects/p1/edit');
    await tester.pumpWidget(_app(router, client, projects));
    await tester.pumpAndSettle();

    expect(find.text('350,00'), findsWidgets);
    final saveButton = find.text('Salvar projeto');
    await tester.dragFrom(const Offset(400, 500), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(projects.values['p1']?.amount, 350);
  });

  testWidgets(
      'criar projeto substitui formulário por detalhes e preserva retorno',
      (tester) async {
    _setTallViewport(tester);
    final projects = _Projects();
    final router = _router(client, '/');
    await tester.pumpWidget(_app(router, client, projects));
    router.push('/projects/new');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana').last);
    await tester.enterText(find.byType(TextFormField).first, 'Novo single');
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mixagem').last);
    final saveButton = find.text('Salvar projeto');
    await tester.dragFrom(const Offset(400, 500), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do projeto'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Origem'), findsOneWidget);
  });
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

GoRouter _router(Client client, String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
          path: '/', builder: (_, __) => const Scaffold(body: Text('Origem'))),
      GoRoute(
          path: '/projects/new', builder: (_, __) => const ProjectFormScreen()),
      GoRoute(
          path: '/projects/:id/edit',
          builder: (_, state) =>
              ProjectFormScreen(projectId: state.pathParameters['id'])),
      GoRoute(
          path: '/projects/:id',
          builder: (_, state) =>
              ProjectDetailsScreen(projectId: state.pathParameters['id']!)),
    ],
  );
}

Widget _app(GoRouter router, Client client, _Projects projects) {
  final clients = _Clients([client]);
  return ProviderScope(
    overrides: [
      clientRepositoryProvider.overrideWithValue(ClientRepository(clients)),
      projectRepositoryProvider.overrideWithValue(ProjectRepository(projects)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _Clients implements ClientDataSource {
  _Clients(this.values);
  final List<Client> values;
  @override
  Future<void> delete(String id) async =>
      values.removeWhere((client) => client.id == id);
  @override
  Future<List<Client>> getAll() async => values;
  @override
  Future<Client?> getById(String id) async =>
      values.where((client) => client.id == id).cast<Client?>().firstOrNull;
  @override
  Future<void> insert(Client client) async => values.add(client);
  @override
  Future<void> update(Client client) async {
    final index = values.indexWhere((value) => value.id == client.id);
    values[index] = client;
  }
}

class _Projects implements ProjectDataSource {
  final values = <String, Project>{};
  @override
  Future<void> delete(String id) async => values.remove(id);
  @override
  Future<List<Project>> getAll() async => values.values.toList();
  @override
  Future<Project?> getById(String id) async => values[id];
  @override
  Future<void> insert(Project project) async => values[project.id] = project;
  @override
  Future<void> update(Project project) async => values[project.id] = project;
}
