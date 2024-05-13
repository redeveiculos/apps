# redeveiculos_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Passos iOS
cd /Users/marcelosoares
export PATH=$PWD/flutter/bin:$PATH
export PATH="$PATH:`pwd`/flutter/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutter pub cache repair
cd /Users/marcelosoares/Dropbox/v5/iOS_Android_flutter/spintec_flutter_default/redeveiculos_flutter
flutter clean
flutter pub get
flutter pub upgrade (flutter pub upgrade --major-versions) (flutter pub outdated)
flutter pub upgrade --major-versions
flutter pub run flutter_launcher_icons:main (fundo não pode ser transparente)
cd ios
pod repo update
pod install --repo-update
pod update OneSignalXCFramework
flutter build ios
flutter build ipa (para subir no Xcode)

Passos Android
cd /Users/marcelosoares
export PATH=$PWD/flutter/bin:$PATH
export PATH="$PATH:`pwd`/flutter/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutter pub cache repair
cd /Users/marcelosoares/Dropbox/v5/iOS_Android_flutter/spintec_flutter_default/redeveiculos_flutter
flutter clean
flutter pub get
flutter pub upgrade (flutter pub upgrade --major-versions) (flutter pub outdated)
flutter pub upgrade --major-versions
flutter pub run flutter_launcher_icons:main
cd android
flutter build apk
flutter build appbundle (para subir no Google Play)


Android
Criar chave
Alterar chave em key.properties
Alterar nomes empresa