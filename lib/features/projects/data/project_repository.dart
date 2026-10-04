import '../domain/project.dart';
import '../domain/project_status.dart';
import 'project_local_data_source.dart';

class ProjectRepository {
  ProjectRepository(this._dataSource);
  final ProjectDataSource _dataSource;
  Future<List<Project>> getAll() => _dataSource.getAll();
  Future<Project?> getById(String id) => _dataSource.getById(id);

  Future<void> save(Project project) async {
    final existing = await _dataSource.getById(project.id);
    if (existing == null) { await _dataSource.insert(project); } else { await _dataSource.update(project); }
  }

  Future<void> updateStatus(String id, ProjectStatus status) async {
    final project = await _dataSource.getById(id);
    if (project == null) return;
    await _dataSource.update(project.copyWith(status: status, updatedAt: DateTime.now()));
  }

  Future<void> delete(String id) => _dataSource.delete(id);
}
