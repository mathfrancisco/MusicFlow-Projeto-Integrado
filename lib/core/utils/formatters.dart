import 'package:intl/intl.dart';

class Formatters {
  static final _date = DateFormat('dd/MM/yyyy');
  static final _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final _currencyInput = NumberFormat('#,##0.00', 'pt_BR');

  static String date(DateTime? value) =>
      value == null ? '—' : _date.format(value);
  static String currency(double? value) =>
      value == null ? '—' : _currency.format(value);

  static String currencyInput(double? value) =>
      value == null ? '' : _currencyInput.format(value);

  static double? parseCurrencyInput(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return null;
    }
    if (!RegExp(r'^\d{1,3}(?:\.\d{3})*(?:,\d{1,2})?$|^\d+(?:,\d{1,2})?$')
        .hasMatch(text)) {
      return null;
    }
    final value =
        double.tryParse(text.replaceAll('.', '').replaceAll(',', '.'));
    return value?.isFinite == true ? value : null;
  }

  static DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
