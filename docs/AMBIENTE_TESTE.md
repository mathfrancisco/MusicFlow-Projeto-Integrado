# Ambiente para testar o MusicFlow

Este guia registra a configuração preparada para executar o MVP em Android a
partir do Windows. Abra um terminal novo depois de qualquer alteração no PATH
para que ele reconheça as ferramentas instaladas.

## Ferramentas registradas

| Ferramenta | Versão/caminho informado |
|---|---|
| Flutter | 3.47.6 em `C:\Users\mathf\develop\flutter` |
| Dart | 3.13.5, incluído no Flutter SDK |
| Java/JDK | Temurin 21.0.12.1 em `C:\Users\mathf\develop\jdk-21` |
| Android SDK | `C:\Users\mathf\AppData\Local\Android\Sdk` |

As variáveis de usuário `JAVA_HOME` e `ANDROID_HOME` e os caminhos Flutter,
JDK e Android foram configurados. O diretório do JDK 21 também foi configurado
para uso pelo Flutter. Um Java mais antigo no PATH de sistema pode ter
precedência para o comando `java`; confira no resultado detalhado de
`flutter doctor -v` qual JDK o Flutter selecionou.

Essas versões e caminhos foram informados durante a preparação do ambiente.
O projeto Android foi gerado. A configuração gerada registra Android Gradle
Plugin 9.1.0, Kotlin 2.4.0 e Gradle 9.3.1. As licenças dos pacotes do SDK foram
aceitas, e a plataforma Android SDK 36 revision 2 foi instalada. `flutter doctor
-v` reconheceu Flutter 3.47.6 stable, Dart 3.13.5, Android SDK 36.0.0, JDK
Temurin 21.0.12.1 configurado no Flutter, licenças aceitas e o emulador
`emulator-5554` Android 17/API 37. Visual Studio não está instalado; isso só
afeta builds desktop Windows e não bloqueia teste Android.

## Verificar a instalação

Em um terminal PowerShell novo, execute:

```powershell
flutter --version
dart --version
flutter doctor -v
flutter devices
```

Se o Flutter selecionou outro JDK, configure explicitamente o diretório
informado e rode `flutter doctor -v` novamente. Isso define o JDK usado pelo
Flutter mesmo que o comando `java` ainda encontre outro caminho no PATH:

```powershell
flutter config --jdk-dir "C:\Users\mathf\develop\jdk-21"
```

Confirme que `flutter doctor -v` reconhece o toolchain Android e que
`flutter devices` lista o emulador ou aparelho USB que você pretende usar.
Nesta sessão, `adb devices` listou `emulator-5554` como `device`; isso confirma
que o ADB detecta o emulador, mas ainda não confirma o build nem a abertura do
app.
Para um aparelho físico, instale o driver USB fornecido pelo fabricante (OEM)
se o Windows não reconhecer o dispositivo e habilite a depuração USB no
Android.

## Baixar dependências e abrir o aplicativo

Na raiz do repositório, execute:

```powershell
Set-Location 'C:\Users\mathf\Documents\GitHub\musicflow-flutter-completo\musicflow-flutter'
flutter pub get
flutter run -d <device-id>
```

Substitua `<device-id>` pelo identificador exibido por `flutter devices`.
Nesta sessão, o emulador apareceu como `emulator-5554`, então o comando de
execução é `flutter run -d emulator-5554`; o identificador pode mudar entre
sessões. Para selecionar o dispositivo conectado automaticamente, use
`flutter run` sem o argumento `-d`. Se precisar reiniciar ou iniciar o
emulador, use o **Device Manager** do Android Studio.

## Executar verificações

```powershell
flutter analyze
flutter test
flutter test integration_test -d <device-id>
```

O teste de integração precisa de um dispositivo ou emulador Android ativo.
Resultado registrado: `flutter test` concluiu com `All tests passed!` para os
testes unitários e de widgets existentes. `flutter analyze` concluiu com cinco
informações de APIs Flutter obsoletas; consulte os detalhes na
[auditoria técnica](AUDITORIA_TECNICA.md). A integração Android `app_launch_test.dart`
também passou (1/1) no emulador e encontrou os títulos `MusicFlow` e `Visão
geral`. Isso valida o fluxo automatizado de inicialização, mas ainda falta
confirmar a execução manual do app.

## Gerar APK de depuração

Com o Android SDK configurado, execute na raiz do app:

```powershell
flutter build apk --debug -t lib/main.dart
```

O arquivo gerado é
`build/app/outputs/flutter-apk/app-debug.apk`. Nesta sessão,
`flutter build apk --debug` concluiu com sucesso após 514,3 segundos no Gradle;
um rebuild posterior com `-t lib/main.dart` também concluiu. Use `-t
lib/main.dart` ao recompilar após `flutter test integration_test`, pois o teste
pode substituir o APK de saída por um harness de integração. O APK foi
instalado e o dashboard abriu no emulador. No estado vazio, o screenshot
mostrou o CTA inferior “Novo projeto” parcialmente coberto pela
bottom navigation/FAB; consulte a
[auditoria técnica](AUDITORIA_TECNICA.md) para o achado e recomendação.

## Limite de plataforma

O projeto é Flutter, mas o build e a execução de iOS exigem macOS com Xcode.
Este ambiente Windows pode preparar/testar Android; não pode compilar nem
executar o alvo iOS localmente.

Para os defeitos de código, critérios de aceitação, limites e roadmap da
revisão, consulte a [auditoria técnica](AUDITORIA_TECNICA.md).

## Estado da preparação

**Ambiente Android validado.** Flutter 3.47.6, Dart 3.13.5, JDK 21.0.12.1 e
os caminhos de SDK foram confirmados; o JDK do Flutter foi configurado, as
licenças Android foram aceitas, a plataforma Android SDK 36 revision 2 foi
instalada e o projeto Android foi gerado. `flutter pub get` resolveu 55 dependências, com 10
pacotes que têm versões mais novas incompatíveis com as restrições atuais.
`flutter test` passou nos 12 testes unitários/widget existentes. `flutter analyze`
terminou com cinco informações de depreciação, sem erros ou avisos reportados.
Esses resultados não cobrem os cenários dos defeitos descritos na auditoria.
O APK debug foi compilado e o app abriu manualmente no emulador; o teste de
integração Android também passou (1/1, abertura do dashboard). `flutter doctor
-v` reconhece a configuração Android; o X de Visual Studio se aplica somente
ao alvo desktop Windows.

O Android gerado usa `com.example.musicflow` e assinatura de debug. Isso é
adequado para teste local; antes de distribuir, defina o identificador final
do aplicativo e configure assinatura de release.
