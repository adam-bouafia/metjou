# MetJou

MetJou ("met jou", Dutch for "with you") is a personal safety app built with Flutter.

Shake your phone when you are in danger and MetJou sends an SMS with your live location to up to three trusted contacts. The app also gives one-tap access to emergency numbers (police, ambulance, fire brigade) and nearby safe spots such as police stations, hospitals and pharmacies.

## Status

Work in progress. The codebase is being modernised from the 2022 prototype:

- Rebrand from M3ak/Dhayen to MetJou
- Dependency upgrade to current Flutter and Dart 3 (null safety)
- Localisation: Dutch (default), English, French, Arabic, Spanish
- Emergency numbers and content adapted for the Netherlands (112, 0900-8844)

## Setup

Firebase config files are not committed. Generate them for your own Firebase project:

    dart pub global activate flutterfire_cli
    flutterfire configure

This creates `lib/firebase_options.dart`, `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`, all of which are gitignored.

## Origin

Based on the [M3ak prototype](https://github.com/adam-bouafia/M3ak-Mobile-Application-Prototype), originally developed in Tunisia in 2022.
