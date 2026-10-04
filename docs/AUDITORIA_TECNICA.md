# Auditoria técnica do MusicFlow

> Atualização de 2026-10-04: as correções dos defeitos P1/P2 documentados
> abaixo foram implementadas e receberam regressões automatizadas. Consulte
> [CORRECOES_E_OTIMIZACOES.md](CORRECOES_E_OTIMIZACOES.md) para o estado atual;
> os trechos seguintes preservam o registro da auditoria e suas pendências de
> produto, acessibilidade, dados e profiling.

**Escopo:** revisão estática de documentação, código Dart, testes, dependências e
scripts de preparação. A auditoria não altera o comportamento do aplicativo.

**Estado da execução (2026-10-04):** dependências, testes unitários/widget,
integração Android, build APK debug e abertura manual no emulador foram
confirmados. `flutter analyze` concluiu com cinco informações de APIs
obsoletas. `flutter doctor -v` reconheceu o toolchain Android; o aviso de
Visual Studio aplica-se somente ao alvo desktop Windows.

## Resumo executivo

A estrutura do MVP corresponde ao desenho documentado: telas Flutter usam
providers Riverpod, repositórios e fontes locais SQLite. O escopo também está
coerente com o MVP offline, que exclui backend, login remoto e sincronização.

A revisão estática identificou um defeito P1 e dois P2 reproduzíveis no ciclo
de projetos: edição pode multiplicar o valor por 100 e persistir o dado
incorreto; um prazo no mesmo dia pode ser rejeitado por diferença de horário;
e a criação navega para detalhes sem voltar à lista nem exibir navegação
principal. Também há riscos de recuperação
e consistência de UI, uma divergência entre o diagrama de status e o seletor
livre, cobertura de testes insuficiente para fluxos críticos e pontos de
acessibilidade, localização e escala que precisam de validação.

Não há evidência suficiente para afirmar que o app tem problemas de
desempenho. As recomendações de desempenho abaixo são hipóteses de escala a
medir, não resultados de profiling.

## Metodologia e limites

- Leitura dos documentos em `docs/`, `README.md`, `pubspec.yaml`, opções de
  análise e scripts de bootstrap.
- Inspeção estática de `lib/`, `test/` e `integration_test/`, cruzando o que os
  documentos prometem com os fluxos implementados.
- Os números de linha apontam para a versão inspecionada e podem mudar após
  alterações.
- A inspeção estática não executou testes, `flutter analyze`, build nem
  profiling. Resultados posteriores de instalação e verificações do ambiente
  estão separados na seção de validação ao final. `flutter doctor -v` reconheceu
  Android SDK 36, JDK Temurin 21.0.12.1, licenças aceitas e emulador Android
  17/API 37; Visual Studio ausente afeta apenas builds desktop Windows, fora do
  alvo testado.
- Ausência de backend, autenticação remota, nuvem, pagamentos, notificações e
  upload de áudio não é defeito do MVP: `docs/MVP.md` os lista como fora de
  escopo.
- A preparação do ambiente gerou a plataforma Android sem alterar a lógica do
  app: a comparação de hashes confirmou `pubspec.yaml` preservado e nenhum
  arquivo em `lib/` ou `test/` alterado.

## Defeitos confirmados

Os itens abaixo têm comportamento observável pela leitura do código e devem
ser confirmados por teste de regressão quando o ambiente estiver pronto.

### P1 — Edição de valor pode multiplicar o valor por 100

**Local:** [formulário de projeto](../lib/features/projects/presentation/project_form_screen.dart#L45)
(carregamento e parsing em `55-56`).

**Reprodução:** cadastre um projeto de `R$ 350,00`, abra a edição e salve sem
alterar o campo. Ao carregar, o valor vira o texto `350.00`. Ao salvar, o
código remove todos os pontos, converte vírgula em ponto e analisa `35000`.
Assim, o valor persistido passa a ser R$ 35.000,00.

**Causa:** o formato de apresentação com ponto decimal é interpretado como
separador de milhar.

**Correção recomendada:** centralizar parsing e formatação monetária para
aceitar consistentemente a entrada `pt_BR` e preencher a edição com o mesmo
formato que o parser espera. Não remover separadores indiscriminadamente.

**Aceitação:** criar e editar `350,00`, `1.234,56`, `0,50` e campo vazio
preserva os valores esperados; salvar sem editar mantém o valor exatamente.

### P2 — Data inicial e prazo no mesmo dia podem ser comparados incorretamente

**Local:** [formulário de projeto](../lib/features/projects/presentation/project_form_screen.dart#L31)
(comparação e seletores em `53`, `106-108`).

**Reprodução:** mantenha a data inicial padrão, que é hoje com o horário atual,
e escolha hoje como prazo. `showDatePicker` retorna a data escolhida à
meia-noite. Ao comparar esse prazo com a data inicial contendo o horário atual,
`isBefore` considera o mesmo dia como anterior. O mesmo efeito pode ocorrer
com outras datas iniciais que preservem horário diferente de meia-noite.

**Causa:** o requisito compara instantes, mas a UI coleta datas sem horário.

**Correção recomendada:** normalizar ambos os valores para ano/mês/dia ao
comparar, ou garantir que datas do domínio sejam sempre normalizadas.

**Aceitação:** data inicial e prazo no mesmo dia são aceitos em qualquer
horário em que o formulário for aberto; prazo anterior continua bloqueado.

### P2 — Após criar projeto, detalhes substituem o histórico de navegação

**Local:** [formulário de projeto](../lib/features/projects/presentation/project_form_screen.dart#L71);
[rotas](../lib/core/routes/app_router.dart#L20).

**Reprodução:** abra **Novo projeto** pela lista ou dashboard, salve e tente
voltar. A criação usa `context.go('/projects/${p.id}')`; detalhes não têm barra
inferior e a rota substitui o histórico. A tela não oferece retorno explícito
à lista ou ao dashboard.

**Causa:** navegação de substituição é usada no fim de um fluxo iniciado por
push, e a tela de detalhes não fornece destino principal.

**Correção recomendada:** definir um retorno coerente com a origem (por
exemplo, pop para a lista quando houver histórico) ou manter navegação
principal nos detalhes e fornecer ação de retorno clara.

**Aceitação:** depois de criar, usuário alcança lista/dashboard e continua a
navegar sem reiniciar o app; editar projeto continua retornando aos detalhes.

## Robustez e recuperação: cenários condicionados a validar

Os padrões abaixo são observáveis no código. Os impactos descritos dependem de
falhas ou condições específicas e precisam de teste direcionado antes de serem
tratados como ocorrências confirmadas em runtime.

### P2 — Falha ao mudar status deixa a exceção sem tratamento nem feedback

**Local:** [detalhes do projeto](../lib/features/projects/presentation/project_details_screen.dart#L15)
(ação em `52`).

`_changeStatus` aguarda a gravação SQLite sem `try/catch`, estado de operação
ou desabilitação do botão. Se a operação falhar, o fluxo propaga erro e não
mostra mensagem de recuperação. Recomenda-se capturar a falha, mostrar estado
com mensagem e retry e impedir submissões concorrentes. Critério: simular falha
de atualização e confirmar que o detalhe continua utilizável e comunica como
recuperar.

### P3 — O retorno do seletor pode chamar `setState` após descarte externo da tela

**Local:** [formulário de projeto](../lib/features/projects/presentation/project_form_screen.dart#L106).

Os callbacks aguardam o seletor e chamam `setState` sem verificar `mounted`.
O retorno após descarte externo do formulário poderia usar estado descartado;
no fluxo normal, voltar fecha o seletor antes da tela, então esse cenário não
foi reproduzido nesta revisão. Recomenda-se verificar `mounted` após cada
`await` como proteção defensiva. Critério: um teste que remova a rota enquanto
o seletor está pendente não produz erro de estado descartado.

### P2 — Telas consumidoras confundem carregamento/erro de clientes com cliente ausente

**Local:** [lista de projetos](../lib/features/projects/presentation/project_list_screen.dart#L20),
[detalhes do projeto](../lib/features/projects/presentation/project_details_screen.dart#L31), e
[agenda](../lib/features/calendar/presentation/calendar_screen.dart#L18).

Essas telas transformam `clientsProvider.valueOrNull` ausente em lista vazia.
Enquanto clientes carregam ou quando falham, elas podem exibir “Cliente não
encontrado”, embora o vínculo possa estar correto. Recomenda-se tratar
`loading`, `error` e `data` separadamente, com retry quando necessário.
Critério: falha temporária ao carregar clientes não é apresentada como dado
órfão nem como sucesso silencioso.

## Requisitos e decisões de produto

### Fluxo de status precisa de uma decisão explícita

[`STATUS_FLOW.md`](STATUS_FLOW.md) descreve transições direcionadas. Porém,
`ProjectStatus.values` contém os estados e
`project_form_screen.dart:112` permite selecionar qualquer estado ao editar;
`project_details_screen.dart:15-26` também aceita qualquer seleção disponível.
Não existe validador de transição no domínio/repositório.

Isso é divergência entre documentação e comportamento, mas não é possível
classificá-la como defeito até decidir se o diagrama é regra de negócio
obrigatória ou apenas um fluxo de referência. Decisão necessária: restringir
transições (e definir exceções, como cancelamento/reabertura) ou atualizar o
diagrama para refletir alteração livre. Critério: documentar a decisão e cobrir
transições permitidas e recusadas.

### Critérios não funcionais ainda estão sem medição

[`REQUIREMENTS.md`](REQUIREMENTS.md) pede responsividade e testes automatizados, mas não
define dispositivos, larguras, escala de fonte nem meta de cobertura. Definir
uma matriz mínima de telas/dispositivos e critérios verificáveis antes de
declarar esses requisitos atendidos.

## Revisão por tela e experiência

| Área | Evidência e ponto de atenção | Melhoria e critério de aceitação |
|---|---|---|
| Dashboard | Carrega projetos com spinner e retry em erro; usa `ListView(children)` e mostra os próximos trabalhos. No AVD desta sessão, o estado vazio mostrou o CTA inferior “Novo projeto” parcialmente coberto pela bottom navigation/FAB; também há outro CTA “Novo projeto”. | Corrigir o recorte/cobertura com área rolável e padding compatível com SafeArea, bottom navigation e FAB. Validar alturas de tela e escala de fonte; testar contadores e navegação com dados vazios, muitos dados e falha SQLite, com rótulos acessíveis. |
| Clientes | Busca lista carregada em memória; lista e formulário têm estado de carregamento/erro. `client_list_screen.dart` cria os itens em `ListView(children)`. | Validar busca vazia, sem resultados, nomes longos, teclado e escalas de texto. Para grandes volumes, adotar lista lazy e medir antes/depois. |
| Projetos | Busca e chips de status; associação de clientes pode aparecer ausente durante carregamento/erro. A lista cria todos os cards de uma vez. | Cobrir busca por título/serviço/cliente e combinação de filtros. Usar lista lazy se medições ou limite funcional justificarem. |
| Formulário de projeto | Formulário longo em lista rolável; contém os defeitos de valor e datas acima. Erros de carregamento de clientes/projeto exibem texto sem ação retry. | Cobrir validações e salvamento com falha; adicionar retry para carregamento; verificar teclado, foco, orientação, escala de fonte e telas estreitas. Preservar o que o usuário digitou após erro de gravação. |
| Detalhes | Exibe dados e ações para editar/status; erro de leitura não apresenta retry; status não tem estado de submissão. | Exibir retry para erro de leitura e operação; confirmar ações de status segundo regra decidida; manter caminho de volta e leitura por leitor de tela. |
| Agenda | Agrupa projetos ativos pelo prazo ou data inicial; datas são formatadas com `intl`. Cliente ausente é usado como fallback inclusive durante carga/erro. | Testar vários projetos no mesmo dia, sem prazo, datas passadas e mudança de mês/ano. Separar falha de cliente de vínculo inexistente; verificar leitura dos grupos por leitor de tela. |

### Acessibilidade

Os widgets Material fornecem semântica básica, mas a revisão de código não
prova conformidade. Fazer teste manual com TalkBack e validação automatizada
de contraste, ordem de foco, alvos de toque, rótulos de ícones, mensagens de
erro e escala de fonte. Chips de status usam texto e cor padrão, mas o status
deve continuar compreensível sem depender só de cor. Critério: fluxos centrais
podem ser concluídos por leitor de tela e com fonte ampliada sem conteúdo ou
ações cortados.

### Responsividade e localização

O app define tema Material, mas `MaterialApp.router` em `lib/app.dart` não
declara `supportedLocales` nem delegados de localização. `Formatters` fixa
`pt_BR` para moeda/data, enquanto os textos da interface são literais
portugueses. Isso não comprova uma falha em todos os dispositivos, mas deixa
localização, idioma do seletor de datas e consistência do locale sem contrato
explícito. Definir suporte de locale deliberadamente e validar picker, teclado,
datas e moeda em aparelho configurado em português.

Validar em larguras compactas e amplas, orientação, barras do sistema e
configuração de fonte grande. No desktop/tablet, avaliar largura máxima de
formulários e colunas/listas; manter ações e filtros acessíveis sem overflow.

### Estados da interface

Há indicadores de loading e um widget com retry (`AsyncErrorView`), mas as
telas não o aplicam uniformemente. Dashboard, lista de clientes, projetos e
agenda permitem retry; detalhes e carregamentos de formulário mostram apenas
texto de erro. Falhas de gravação de cliente/projeto mostram SnackBar; alteração
de status não tem tratamento explícito. Uniformizar estados `loading`, `error`,
`empty`, `success` e `retry`, sem substituir dados existentes por mensagens de
“não encontrado” durante carregamento.

## Dados, SQLite e privacidade

- `AppDatabase` cria schema versão 1 e índices para `client_id`, `status` e
  `due_date` ([implementação do banco](../lib/core/database/app_database.dart#L9)). Não há
  `onUpgrade` ou estratégia de migração. Para o estado atual, não há evidência
  de migração faltando em uma instalação nova; é um risco futuro assim que o
  schema mudar. Critério: cada mudança de schema incrementa versão e tem teste
  de upgrade preservando dados.
- Não há fluxo documentado/implementado de exportação, backup, restauração ou
  exclusão completa dos dados. Como o MVP é local, informar ao usuário onde os
  dados ficam e o efeito de desinstalar/trocar aparelho; decidir e documentar
  backup/restauração antes de depender dos dados em uso real.
- `onConfigure` habilita chaves estrangeiras; `projects.client_id` referencia
  `clients.id`, mas as operações de exclusão de clientes/projetos não aparecem
  na UI inspecionada. Se exclusão for adicionada, definir política explícita
  (bloquear, cascata ou desvincular) e validá-la com `foreign_keys` ativos.
- Clientes guardam nome, telefone, e-mail e observações; projetos guardam
  valores e notas. O banco é local e não há sincronização no escopo. Definir
  aviso de privacidade, minimização de dados, proteção por bloqueio do aparelho
  e procedimento de remoção. A auditoria não verificou criptografia do
  armazenamento e não afirma que ela exista.
- Valores são armazenados como `REAL`; para um MVP, isso pode servir, mas
  valores financeiros que exijam precisão decimal devem ser avaliados em
  centavos inteiros ou representação decimal controlada, com migração/testes
  se a decisão mudar.

## Testes e cobertura

`docs/TESTING.md` lista testes de validação, enum, repositório, dois widgets e
inicialização. Os arquivos presentes confirmam esses focos, mas não cobrem
formulários, fluxo de navegação, SQLite real, dashboard, clientes, agenda,
erros/retry ou a sequência de transições. O repositório de projetos usa fonte
fake; isso verifica lógica isolada, não integração com SQLite.

Ordem recomendada de cobertura:

1. Testes unitários para parsing/formatação de valores e comparação de datas.
2. Testes de formulário para criar/editar e preservar valor sem alteração.
3. Testes de navegação para criação, edição, detalhes e retorno à navegação
   principal.
4. Testes de erro e retry para clientes, projeto e mudança de status.
5. Testes de repositório com SQLite em memória ou mecanismo equivalente,
   incluindo chave estrangeira e migração de versão.
6. Testes de integração dos principais fluxos completos em emulador.

Critério: o defeito P1 e os P2 têm regressão automatizada; testes do banco verificam
round-trip e integridade; os fluxos MVP passam em um dispositivo Android alvo.
Não há meta de cobertura numérica definida; estabelecê-la por área em vez de
usar percentual sem relação com risco.

## Otimização e escalabilidade

Não foi executado profiling; portanto, não há gargalo de desempenho confirmado.
Há três oportunidades para medir conforme o volume esperado:

- `project_list_screen.dart`, `client_list_screen.dart`, `dashboard_screen.dart`
  e `calendar_screen.dart` constroem elementos com `ListView(children)` ou listas
  de grupos. Com poucos registros isso pode ser adequado; para muitos registros,
  medir tempo de construção, memória e rolagem e considerar `ListView.builder`
  ou slivers.
- Busca e junção projeto/cliente acontecem em memória após `getAll`. Para dados
  maiores, medir tempo de abertura e busca; então avaliar consultas filtradas,
  paginação e índices compatíveis com os filtros reais. Índices atuais cobrem
  algumas colunas, mas não demonstram necessidade nem ganho sem dados de uso.
- Providers de lista carregam coleções completas. Se os volumes crescerem,
  permitir consultas paginadas e invalidar apenas os dados afetados. Medir
  duração de consulta e reconstruções antes de mudar a arquitetura.

Critério: definir conjunto representativo (por exemplo, pequeno e grande, com
quantidades registradas), medir em dispositivo alvo e guardar baseline de
abertura, busca e rolagem antes de otimizar. Não afirmar melhoria sem comparar
medições equivalentes.

## Ambiente, dependências e documentação

- `pubspec.yaml` requer Dart `>=3.4.0 <4.0.0` e usa Flutter, Riverpod,
  go_router, sqflite, path, intl e uuid. Registrar versão efetiva do Flutter,
  Dart, Android SDK, JDK e Gradle depois da preparação; compatibilidade não pode
  ser concluída só pelo `pubspec.yaml`.
- O README orienta gerar `android/` e `ios/` com `flutter create .` e depois
  executar `flutter pub get`. O script PowerShell chama `flutter create` e
  `flutter pub get`, mas `$ErrorActionPreference = "Stop"` pode não interromper
  todas as versões/configurações do PowerShell diante de código de saída nativo
  não zero. Verificar `$LASTEXITCODE` explicitamente antes de anunciar sucesso.
- O bootstrap cria as plataformas Android e iOS inclusive no Windows. Para
  testar Android, Android Studio sozinho não basta: Flutter SDK e componentes
  Android (SDK Platform/Build Tools, Platform Tools e emulator ou dispositivo)
  precisam estar instalados e reconhecidos pelo `flutter doctor`. A validação
  do ambiente Android foi concluída nesta sessão, conforme as saídas registradas na seção de resultados.
- Consulte o [guia oficial de instalação manual do Flutter](https://docs.flutter.dev/install/manual),
  a [configuração oficial de Android](https://docs.flutter.dev/platform-integration/android/setup)
  e a [documentação de `sqflite`](https://pub.dev/packages/sqflite) para os
  requisitos atuais do SDK e do plugin.
- `mocktail` está listado como dependência de desenvolvimento, mas os testes
  inspecionados usam fake manual e não importam mocktail. Confirmar se é
  dependência planejada ou removê-la em uma revisão posterior.
- Há comandos de testes no README e `docs/TESTING.md`; a sequência prática de
  setup e validação Android está em [`AMBIENTE_TESTE.md`](AMBIENTE_TESTE.md).

## Roadmap recomendado

| Ordem | Entrega | Critério de conclusão |
|---|---|---|
| 1 | Preparar e registrar ambiente Flutter/Android | Concluído para Android: `flutter doctor -v` reconhece SDK/JDK/licenças e AVD Android 17/API 37. Visual Studio ausente não afeta o alvo Android. |
| 2 | Corrigir valor, datas e retorno após criação | Testes de regressão reproduzem os três cenários e passam; usuário mantém valor, pode usar mesmo dia e chega à navegação principal após criar. |
| 3 | Fechar erros assíncronos e feedback | Falhas de status e leituras têm retry/mensagem; callbacks após `await` respeitam `mounted`; clientes em loading/error não parecem ausentes. |
| 4 | Decidir e alinhar fluxo de status | Produto decide transições permitidas; diagrama, formulário, detalhes, domínio e testes expressam a mesma regra. |
| 5 | Validar responsividade, localização e acessibilidade | Matriz Android e fontes ampliadas executada; TalkBack, foco, contraste, textos, teclado e datas verificados; problemas registrados e corrigidos. |
| 6 | Aumentar testes nos fluxos críticos | CRUD de cliente/projeto, filtros, calendário, falha/retry, navegação e persistência têm testes; integração Android percorre um fluxo completo. |
| 7 | Definir ciclo de vida local dos dados | Política de migração, backup/restauração, exclusão e privacidade documentada e testada; decisões compatíveis com uso esperado. |
| 8 | Medir escala e otimizar se necessário | Baseline em volume representativo; mudança só é aceita quando melhora métrica definida sem regressão funcional. |

## Resultados de validação desta sessão

Resultados registrados em 2026-10-04. Testes unitários/widget e de integração,
build e abertura manual do app Android passaram; a análise concluiu com cinco
informações de depreciação.

| Verificação | Resultado |
|---|---|
| Flutter/Dart e Android toolchain | `flutter doctor -v` reconheceu Flutter 3.47.6 stable, Dart 3.13.5, Android SDK 36.0.0, JDK Temurin 21.0.12.1 configurado no Flutter, licenças aceitas, emulador `emulator-5554` Android 17/API 37 e recursos de rede disponíveis. Único X: Visual Studio ausente para alvo desktop Windows; não bloqueia Android. |
| Dependências (`flutter pub get`) | Sucesso: `Changed 55 dependencies!`; 10 pacotes têm versões mais novas incompatíveis com as restrições atuais. |
| Análise estática (`flutter analyze`) | Concluiu em 25,1 s com 5 informações `deprecated_member_use`, sem erros ou avisos no relatório. Veja detalhes abaixo; não é uma análise sem apontamentos. |
| Testes unitários/widget (`flutter test`) | Saída: `All tests passed!` (12 casos reportados pelo runner). |
| Dispositivo Android | `adb devices` listou `emulator-5554` como `device`. |
| Build APK de depuração | Sucesso: `flutter build apk --debug` gerou `build/app/outputs/flutter-apk/app-debug.apk` (Gradle `assembleDebug`, 514,3 s); um rebuild posterior gerou o APK usado no teste manual. |
| Teste de integração Android | Sucesso: `app_launch_test.dart` instalou e abriu o app no emulador; 1/1 passou e encontrou `MusicFlow` e `Visão geral`. |
| Execução manual do app | Sucesso após rebuild com `lib/main.dart`: dashboard exibido no emulador. O screenshot também revelou o CTA inferior parcialmente coberto no estado vazio, registrado na revisão por tela. |

### Informações do analisador

As cinco informações indicam APIs Flutter obsoletas para versões futuras, não
falhas de compilação observadas nesta análise:

- `RadioListTile.groupValue` e `onChanged` em
  `project_details_screen.dart:21` devem migrar para `RadioGroup`.
- `DropdownButtonFormField.value` em `project_form_screen.dart:98,102,112`
  deve migrar para `initialValue`.

Planeje a atualização e rode o analisador novamente após a migração. O Flutter
também atualizou `analysis_options.yaml` para excluir diretórios de build e
plataformas geradas.
