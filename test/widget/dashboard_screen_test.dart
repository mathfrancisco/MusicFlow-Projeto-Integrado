import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/core/providers/query_providers.dart';
import 'package:musicflow/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  testWidgets(
      'estado vazio mantém a ação principal do FAB alcançável em tela baixa',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsProvider.overrideWith((ref) async => []),
          clientsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Novo projeto'), findsOneWidget);
    expect(tester.getRect(find.text('Novo projeto')).bottom,
        lessThanOrEqualTo(480));
  });
}
