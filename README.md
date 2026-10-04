# MusicFlow

Projeto Integrado — Desenvolvimento Mobile  
Curso: Tecnólogo em Análise e Desenvolvimento de Sistemas — UNIFEOB

Aplicativo Flutter para **gestão de clientes, projetos/serviços, agenda e andamento de trabalhos de produção musical**.

## Empresa beneficiada

- CNPJ: `66.251.531/0001-65`
- Atividade informada: `90.01-9/02 — Produção musical`

> A descrição final do problema empresarial deve ser validada diretamente com a empresa beneficiada antes da entrega acadêmica.

## Funcionalidades implementadas

- Dashboard com contadores de projetos.
- Cadastro, edição, listagem e busca de clientes.
- Cadastro, edição e listagem de projetos.
- Filtro de projetos por status.
- Alteração de status.
- Detalhes do projeto.
- Agenda por data.
- Persistência local com SQLite.
- Validações de formulário.
- Riverpod para estado e dependências.
- go_router para navegação.
- Testes unitários e de widgets.
- Teste de integração de inicialização.

## Arquitetura

```text
Screens / Widgets
      ↓
Riverpod Providers
      ↓
Repositories
      ↓
Local Data Sources
      ↓
SQLite
```

## Preparar o projeto

O ZIP contém todo o código Dart/Flutter do MVP. As pastas nativas (`android/` e `ios/`) são geradas automaticamente pelo Flutter.

Depois de descompactar:

```bash
cd musicflow-flutter
flutter create . --platforms=android,ios
flutter pub get
flutter run
```

No Windows PowerShell também existe `scripts/bootstrap.ps1`.

## Testes

```bash
flutter test
flutter test integration_test
```

## Fluxo de demonstração

1. Cadastrar cliente.
2. Cadastrar projeto.
3. Abrir detalhes.
4. Alterar status para Em produção.
5. Voltar ao dashboard e conferir os indicadores.
6. Abrir agenda.
7. Executar os testes.

## Documentação

- [Guia para preparar o ambiente e testar no Android](docs/AMBIENTE_TESTE.md)
- [Auditoria técnica, achados e roadmap](docs/AUDITORIA_TECNICA.md)
- [Correções e otimizações aplicadas](docs/CORRECOES_E_OTIMIZACOES.md)
- Consulte os demais documentos em `docs/` para arquitetura, modelagem,
  requisitos, telas, testes e roteiro do vídeo.
