import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:musicflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('abre no dashboard', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('MusicFlow'), findsOneWidget);
    expect(find.text('Visão geral'), findsOneWidget);
  });
}
