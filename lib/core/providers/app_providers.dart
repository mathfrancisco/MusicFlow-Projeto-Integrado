import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clients/data/client_local_data_source.dart';
import '../../features/clients/data/client_repository.dart';
import '../../features/projects/data/project_local_data_source.dart';
import '../../features/projects/data/project_repository.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);
final clientDataSourceProvider = Provider<ClientDataSource>((ref) => ClientLocalDataSource(ref.watch(databaseProvider)));
final clientRepositoryProvider = Provider<ClientRepository>((ref) => ClientRepository(ref.watch(clientDataSourceProvider)));
final projectDataSourceProvider = Provider<ProjectDataSource>((ref) => ProjectLocalDataSource(ref.watch(databaseProvider)));
final projectRepositoryProvider = Provider<ProjectRepository>((ref) => ProjectRepository(ref.watch(projectDataSourceProvider)));
