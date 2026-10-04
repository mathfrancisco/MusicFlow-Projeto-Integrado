import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/core/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState exibe conteúdo e ação', (tester) async {
    var pressed = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: EmptyState(icon: Icons.music_note, title: 'Sem projetos', message: 'Cadastre o primeiro projeto.', actionLabel: 'Cadastrar', onAction: () => pressed = true))));
    expect(find.text('Sem projetos'), findsOneWidget);
    await tester.tap(find.text('Cadastrar'));
    expect(pressed, isTrue);
  });
}
