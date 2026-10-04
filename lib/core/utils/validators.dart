class Validators {
  static String? requiredText(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) return '$field é obrigatório.';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'Informe um e-mail válido.';
    return null;
  }

  static String? phone(String? value) {
    final text = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (text.isEmpty) return 'Telefone é obrigatório.';
    if (text.length < 10) return 'Informe um telefone válido.';
    return null;
  }
}
