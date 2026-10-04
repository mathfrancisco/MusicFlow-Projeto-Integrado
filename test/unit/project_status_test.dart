import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/features/projects/domain/project_status.dart';

void main() {
  test('converte status persistido', () => expect(ProjectStatus.fromDb('inProduction'), ProjectStatus.inProduction));
  test('fallback para requested', () => expect(ProjectStatus.fromDb('unknown'), ProjectStatus.requested));
}
