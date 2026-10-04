import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clients/domain/client.dart';
import '../../features/projects/domain/project.dart';
import 'app_providers.dart';

final clientsProvider = FutureProvider<List<Client>>((ref) => ref.watch(clientRepositoryProvider).getAll());
final projectsProvider = FutureProvider<List<Project>>((ref) => ref.watch(projectRepositoryProvider).getAll());
final clientByIdProvider = FutureProvider.family<Client?, String>((ref, id) => ref.watch(clientRepositoryProvider).getById(id));
final projectByIdProvider = FutureProvider.family<Project?, String>((ref, id) => ref.watch(projectRepositoryProvider).getById(id));
