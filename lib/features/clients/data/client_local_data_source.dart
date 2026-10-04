import '../../../core/database/app_database.dart';
import '../domain/client.dart';

abstract class ClientDataSource {
  Future<List<Client>> getAll();
  Future<Client?> getById(String id);
  Future<void> insert(Client client);
  Future<void> update(Client client);
  Future<void> delete(String id);
}

class ClientLocalDataSource implements ClientDataSource {
  ClientLocalDataSource(this._database);
  final AppDatabase _database;

  @override
  Future<List<Client>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('clients', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Client.fromMap).toList();
  }

  @override
  Future<Client?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query('clients', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Client.fromMap(rows.first);
  }

  @override
  Future<void> insert(Client client) async { final db = await _database.database; await db.insert('clients', client.toMap()); }
  @override
  Future<void> update(Client client) async { final db = await _database.database; await db.update('clients', client.toMap(), where: 'id = ?', whereArgs: [client.id]); }
  @override
  Future<void> delete(String id) async { final db = await _database.database; await db.delete('clients', where: 'id = ?', whereArgs: [id]); }
}
