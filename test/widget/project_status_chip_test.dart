import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/features/projects/domain/project_status.dart';
import 'package:musicflow/features/projects/presentation/project_status_chip.dart';

void main() {
  testWidgets('chip mostra o rótulo', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: ProjectStatusChip(status: ProjectStatus.inProduction))));
    expect(find.text('Em produção'), findsOneWidget);
  });

  testWidgets('usa a cor de status aprovada em cada status conhecido', (
    tester,
  ) async {
    const expectedColors = {
      ProjectStatus.scheduled: Color(0xFF64A5FF),
      ProjectStatus.inProduction: Color(0xFFFFB454),
      ProjectStatus.completed: Color(0xFF5DD39E),
      ProjectStatus.cancelled: Color(0xFFFF6B6B),
    };

    for (final entry in expectedColors.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProjectStatusChip(status: entry.key)),
        ),
      );

      final label = tester.widget<Text>(find.text(entry.key.label));
      expect(label.style?.color, entry.value, reason: entry.key.name);
    }
  });
}
