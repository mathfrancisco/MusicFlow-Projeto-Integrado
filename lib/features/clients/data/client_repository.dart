import '../domain/client.dart';
import 'client_local_data_source.dart';

class ClientRepository {
  ClientRepository(this._dataSource);
  final ClientDataSource _dataSource;
  Future<List<Client>> getAll() => _dataSource.getAll();
  Future<Client?> getById(String id) => _dataSource.getById(id);

  Future<void> save(Client client) async {
    final existing = await _dataSource.getById(client.id);
    if (existing == null) { await _dataSource.insert(client); } else { await _dataSource.update(client); }
  }

  Future<void> delete(String id) => _dataSource.delete(id);
}
