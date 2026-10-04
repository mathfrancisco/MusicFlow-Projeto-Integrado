$ErrorActionPreference = "Stop"
flutter create . --platforms=android,ios
if ($LASTEXITCODE -ne 0) { throw "flutter create falhou com código $LASTEXITCODE." }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get falhou com código $LASTEXITCODE." }
Write-Host "Projeto preparado. Execute: flutter run"
