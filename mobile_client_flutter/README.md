Vinci flutter client

user authentication with Auth0
leverages a GraphQL backend

currently, only the Android deploy is tested
web needs to implement the authentication flow

## Getting Started

1. Install Flutter on your machine using these [instructions](https://flutter.dev/docs/get-started/install).

2. Optionally enable [web support](https://flutter.dev/docs/get-started/web) by switching to the beta channel.

3. Run `flutter pub get` to install dependencies.

4. `flutter run` to launch your app in debug mode. Or use the Flutter tools in your IDE.
e.g. flutter run -d emulator-5554 (for Android Studio > AVD Manager > run emulator)
flutter run -d chrome (web, opens Chrome window)
flutter run -d 71b653b5 --release (on phone connected via cable)

## Build

If you change `lib/model/model.dart` you will need to regenerate the JSON serialization code by running this command:

```
flutter pub run build_runner build
```

If you wish to change the app icon in `assets/icons` you will need to update the source file in `pubspec.yaml`. This updates Android and iOS icons, web must be done manually. Run the following command:

```
flutter pub run flutter_launcher_icons:main
```
