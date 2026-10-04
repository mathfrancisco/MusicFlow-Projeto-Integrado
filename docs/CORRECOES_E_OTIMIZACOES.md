# Correções e otimizações — 2026-10-04

Esta entrega corrige os defeitos confirmados na auditoria sem ampliar o escopo
do MVP offline. O snapshot anterior está em `.local/pre-correcoes-20261004`
e não contém `build/`, SDKs ou emuladores.

## Correções aplicadas

- O formulário preenche e interpreta dinheiro no mesmo padrão `pt_BR`.
  `350,00`, `1.234,56`, `0,50` e campo vazio são tratados de forma explícita;
  salvar um projeto editado sem alterar o valor preserva o número.
- Datas de projeto são normalizadas para dia, eliminando a rejeição indevida de
  prazo no mesmo dia por diferença de horário. O retorno do seletor verifica
  `mounted` antes de atualizar a tela.
- Depois de criar um projeto, o formulário é substituído pelos detalhes mantendo
  a tela de origem no histórico. Os detalhes têm Voltar explícito e usam a lista
  de projetos como destino seguro quando não houver histórico.
- Alteração de status ganhou estado de envio, captura de falha, mensagem de
  recuperação e `RadioGroup`, removendo APIs Flutter obsoletas. O MVP continua
  permitindo alteração livre de status; `STATUS_FLOW.md` agora o descreve como
  fluxo sugerido, não como bloqueio de regra de negócio.
- Dashboard, lista de projetos, detalhes e agenda distinguem carregamento e
  falha de clientes de cliente inexistente, sempre oferecendo retry nas falhas.
- Listas de clientes, projetos e agenda usam builders/slivers; a junção de
  cliente é feita por mapa em cada tela. Isto remove construção antecipada de
  todos os cards, mas não é uma medição de desempenho.
- O dashboard removeu o CTA duplicado do estado vazio. O FAB é a única ação de
  criação e permanece visível em tela baixa. A localidade material do app é
  declarada como `pt_BR`.
- `bootstrap.ps1` interrompe a execução se `flutter create` ou `flutter pub get`
  terminarem com código diferente de zero.

## Pendências reais

- Não houve profiling com base de dados representativa; paginação, índices e
  métricas só devem ser introduzidos depois de medir abertura, busca e rolagem.
- Acessibilidade ainda requer validação manual com TalkBack, fontes ampliadas,
  foco por teclado e contraste em dispositivo alvo.
- Política de migração, exportação/backup, exclusão e retenção de dados SQLite
  continua uma decisão de produto. Nenhuma funcionalidade de dados foi criada
  nesta correção.
