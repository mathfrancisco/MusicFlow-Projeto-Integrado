import 'package:flutter_test/flutter_test.dart';
import 'package:musicflow/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('requiredText rejeita vazio', () => expect(Validators.requiredText('', field: 'Nome'), 'Nome é obrigatório.'));
    test('requiredText aceita preenchido', () => expect(Validators.requiredText('Ana', field: 'Nome'), isNull));
    test('email aceita vazio', () => expect(Validators.email(''), isNull));
    test('email rejeita inválido', () => expect(Validators.email('teste@'), isNotNull));
    test('email aceita válido', () => expect(Validators.email('teste@exemplo.com'), isNull));
    test('telefone valida comprimento', () { expect(Validators.phone('1234'), isNotNull); expect(Validators.phone('(19) 99999-9999'), isNull); });
  });
}
