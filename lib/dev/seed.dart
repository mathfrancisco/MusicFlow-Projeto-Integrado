import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../features/clients/data/client_local_data_source.dart';
import '../features/clients/data/client_repository.dart';
import '../features/clients/domain/client.dart';
import '../features/projects/data/project_local_data_source.dart';
import '../features/projects/data/project_repository.dart';
import '../features/projects/domain/project.dart';
import '../features/projects/domain/project_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase.instance;
  final clientRepository = ClientRepository(ClientLocalDataSource(database));
  final projectRepository = ProjectRepository(ProjectLocalDataSource(database));
  final existingClients = await clientRepository.getAll();
  final existingProjects = await projectRepository.getAll();

  if (existingClients.isNotEmpty || existingProjects.isNotEmpty) {
    // ignore: avoid_print
    print(
      'Seed: banco já possui dados (${existingClients.length} clientes, '
      '${existingProjects.length} projetos) — pulando',
    );
    exit(0);
  }

  const uuid = Uuid();
  final now = DateTime.now();
  final clients = [
    Client(
      id: uuid.v4(),
      name: 'Mariana Oliveira',
      artisticName: 'Mari O.',
      phone: '(11) 98765-4321',
      email: 'mariana.oliveira@example.com',
      notes: 'Cantora e compositora de MPB.',
      createdAt: now,
      updatedAt: now,
    ),
    Client(
      id: uuid.v4(),
      name: 'Rafael Santos',
      artisticName: 'Rafa Santos',
      phone: '(21) 97654-3210',
      email: 'rafael.santos@example.com',
      notes: 'Artista independente de pop.',
      createdAt: now,
      updatedAt: now,
    ),
    Client(
      id: uuid.v4(),
      name: 'Camila Ferreira',
      artisticName: 'Cami Fê',
      phone: '(31) 96543-2109',
      email: 'camila.ferreira@example.com',
      notes: 'Vocalista de banda de rock alternativo.',
      createdAt: now,
      updatedAt: now,
    ),
    Client(
      id: uuid.v4(),
      name: 'Lucas Almeida',
      artisticName: 'Lukinha',
      phone: '(41) 95432-1098',
      email: 'lucas.almeida@example.com',
      notes: 'Produtor e artista de hip-hop.',
      createdAt: now,
      updatedAt: now,
    ),
    Client(
      id: uuid.v4(),
      name: 'Beatriz Costa',
      artisticName: 'Bia Costa',
      phone: '(51) 94321-0987',
      email: 'beatriz.costa@example.com',
      notes: 'Cantora de samba e pagode.',
      createdAt: now,
      updatedAt: now,
    ),
    Client(
      id: uuid.v4(),
      name: 'Pedro Rodrigues',
      artisticName: 'Pedro Rô',
      phone: '(61) 93210-9876',
      email: 'pedro.rodrigues@example.com',
      notes: 'Compositor e intérprete de sertanejo.',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final client in clients) {
    await clientRepository.save(client);
  }

  final projects = [
    Project(
      id: uuid.v4(),
      clientId: clients[0].id,
      title: 'Mixagem EP',
      serviceType: 'Mixagem',
      description: 'Mixagem de cinco faixas para lançamento digital.',
      requestedDate: now.subtract(const Duration(days: 12)),
      dueDate: now.add(const Duration(days: 3)),
      amount: 1800.00,
      status: ProjectStatus.inProduction,
      notes: 'Aguardar aprovação da primeira faixa.',
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[1].id,
      title: 'Masterização single',
      serviceType: 'Masterização',
      description: 'Master estéreo para plataformas de streaming.',
      requestedDate: now.subtract(const Duration(days: 2)),
      dueDate: now.add(const Duration(days: 5)),
      amount: 450.00,
      status: ProjectStatus.scheduled,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[2].id,
      title: 'Gravação de demo',
      serviceType: 'Gravação',
      description: 'Gravação de voz e instrumentos para demo.',
      requestedDate: now.subtract(const Duration(days: 20)),
      dueDate: now.subtract(const Duration(days: 14)),
      amount: 900.00,
      status: ProjectStatus.completed,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[3].id,
      title: 'Produção jingle',
      serviceType: 'Produção musical',
      description: 'Produção de jingle para campanha local.',
      requestedDate: now.subtract(const Duration(days: 4)),
      dueDate: now.add(const Duration(days: 8)),
      amount: 2200.00,
      status: ProjectStatus.inProduction,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[4].id,
      title: 'Captação de voz',
      serviceType: 'Gravação',
      description: 'Captação vocal para faixa de pagode.',
      requestedDate: now,
      dueDate: now.add(const Duration(days: 2)),
      amount: 350.00,
      status: ProjectStatus.scheduled,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[5].id,
      title: 'Edição de podcast musical',
      serviceType: 'Edição de áudio',
      description: 'Edição e limpeza de áudio de episódio.',
      requestedDate: now.subtract(const Duration(days: 3)),
      dueDate: now.subtract(const Duration(days: 1)),
      amount: 280.00,
      status: ProjectStatus.completed,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[0].id,
      title: 'Pré-produção de álbum',
      serviceType: 'Pré-produção',
      description: 'Arranjos e preparação de repertório autoral.',
      requestedDate: now.add(const Duration(days: 1)),
      dueDate: now.add(const Duration(days: 15)),
      amount: 3200.00,
      status: ProjectStatus.scheduled,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[2].id,
      title: 'Mixagem single',
      serviceType: 'Mixagem',
      description: 'Mixagem de single de rock alternativo.',
      requestedDate: now.subtract(const Duration(days: 7)),
      dueDate: now.add(const Duration(days: 1)),
      amount: 650.00,
      status: ProjectStatus.inProduction,
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[4].id,
      title: 'Remix ao vivo',
      serviceType: 'Remix',
      description: 'Remix de apresentação ao vivo para divulgação.',
      requestedDate: now.subtract(const Duration(days: 6)),
      dueDate: now.subtract(const Duration(days: 2)),
      amount: 750.00,
      status: ProjectStatus.cancelled,
      notes: 'Projeto pausado a pedido do cliente.',
      createdAt: now,
      updatedAt: now,
    ),
    Project(
      id: uuid.v4(),
      clientId: clients[1].id,
      title: 'Gravação de vocal',
      serviceType: 'Gravação',
      description: 'Sessão de gravação vocal para novo single.',
      requestedDate: now.subtract(const Duration(days: 5)),
      dueDate: now.add(const Duration(days: 10)),
      amount: 500.00,
      status: ProjectStatus.cancelled,
      notes: 'Sessão cancelada pelo cliente.',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final project in projects) {
    await projectRepository.save(project);
  }

  final insertedClients = await clientRepository.getAll();
  final insertedProjects = await projectRepository.getAll();
  // ignore: avoid_print
  print(
    'Seed: ${insertedClients.length} clientes, '
    '${insertedProjects.length} projetos inseridos',
  );
  exit(0);
}
