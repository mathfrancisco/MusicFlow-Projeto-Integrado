import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/features/projects/domain/project_status.dart';
import 'package:musicflow/features/projects/presentation/project_status_chip.dart';

void main() {
  testWidgets('chip mostra o rótulo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ProjectStatusChip(status: ProjectStatus.inProduction))));
    expect(find.text('Em produção'), findsOneWidget);
  });
}
