enum ProjectStatus {
  requested('requested', 'Solicitado'),
  awaitingConfirmation('awaitingConfirmation', 'Aguardando confirmação'),
  scheduled('scheduled', 'Agendado'),
  inProduction('inProduction', 'Em produção'),
  completed('completed', 'Finalizado'),
  cancelled('cancelled', 'Cancelado');

  const ProjectStatus(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static ProjectStatus fromDb(String value) => ProjectStatus.values.firstWhere((s) => s.dbValue == value, orElse: () => ProjectStatus.requested);
}
