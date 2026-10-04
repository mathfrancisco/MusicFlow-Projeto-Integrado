import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/core/utils/formatters.dart';

void main() {
  group('Formatters.currencyInput', () {
    test('formata valor salvo no padrão pt_BR', () {
      expect(Formatters.currencyInput(350), '350,00');
      expect(Formatters.currencyInput(1234.56), '1.234,56');
      expect(Formatters.currencyInput(null), isEmpty);
    });

    test('converte entrada pt_BR sem multiplicar valor ao editar', () {
      expect(Formatters.parseCurrencyInput('350,00'), 350);
      expect(Formatters.parseCurrencyInput('1.234,56'), 1234.56);
      expect(Formatters.parseCurrencyInput(Formatters.currencyInput(350)), 350);
      expect(Formatters.parseCurrencyInput('0,50'), 0.5);
      expect(Formatters.parseCurrencyInput(''), isNull);
      expect(Formatters.parseCurrencyInput('350.00'), isNull);
    });
  });

  test('day remove a hora antes de comparar datas de formulário', () {
    final requested = Formatters.day(DateTime(2026, 10, 4, 18, 30));
    final due = Formatters.day(DateTime(2026, 10, 4));

    expect(due.isBefore(requested), isFalse);
    expect(Formatters.day(DateTime(2026, 10, 3)).isBefore(requested), isTrue);
  });
}
