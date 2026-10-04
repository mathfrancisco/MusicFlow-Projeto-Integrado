import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/features/projects/data/project_local_data_source.dart';
import 'package:musicflow/features/projects/data/project_repository.dart';
import 'package:musicflow/features/projects/domain/project.dart';
import 'package:musicflow/features/projects/domain/project_status.dart';

void main() {
  late _Fake ds; late ProjectRepository repo;
  setUp(() { ds = _Fake(); repo = ProjectRepository(ds); });
  test('save insere projeto inexistente', () async { final p = sample(); await repo.save(p); expect(await repo.getById(p.id), isNotNull); });
  test('updateStatus altera status', () async { final p = sample(); await repo.save(p); await repo.updateStatus(p.id, ProjectStatus.inProduction); expect((await repo.getById(p.id))?.status, ProjectStatus.inProduction); });
}

Project sample() { final now = DateTime(2026,10,3); return Project(id:'p1', clientId:'c1', title:'Produção single', serviceType:'Produção musical', requestedDate:now, dueDate:now.add(const Duration(days:10)), status:ProjectStatus.requested, createdAt:now, updatedAt:now); }

class _Fake implements ProjectDataSource {
  final map = <String,Project>{};
  @override Future<void> delete(String id) async { map.remove(id); }
  @override Future<List<Project>> getAll() async => map.values.toList();
  @override Future<Project?> getById(String id) async => map[id];
  @override Future<void> insert(Project p) async { map[p.id] = p; }
  @override Future<void> update(Project p) async { map[p.id] = p; }
}
