import '../../../core/database/app_database.dart';
import '../domain/project.dart';

abstract class ProjectDataSource {
  Future<List<Project>> getAll();
  Future<Project?> getById(String id);
  Future<void> insert(Project project);
  Future<void> update(Project project);
  Future<void> delete(String id);
}

class ProjectLocalDataSource implements ProjectDataSource {
  ProjectLocalDataSource(this._database);
  final AppDatabase _database;

  @override
  Future<List<Project>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('projects', orderBy: 'COALESCE(due_date, requested_date) ASC');
    return rows.map(Project.fromMap).toList();
  }

  @override
  Future<Project?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query('projects', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Project.fromMap(rows.first);
  }

  @override
  Future<void> insert(Project project) async { final db = await _database.database; await db.insert('projects', project.toMap()); }
  @override
  Future<void> update(Project project) async { final db = await _database.database; await db.update('projects', project.toMap(), where: 'id = ?', whereArgs: [project.id]); }
  @override
  Future<void> delete(String id) async { final db = await _database.database; await db.delete('projects', where: 'id = ?', whereArgs: [id]); }
}
