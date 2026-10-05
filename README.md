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

    flutter pub get
    flutter run

No account or backend is needed; contacts and settings stay on the device.

## Wear OS app

`android/wear` is a small watch app with one SOS button. It sends the press to the paired phone (Wearable Data Layer), which starts the SOS countdown. It shares the phone app's application ID and must be signed with the same key.

    cd android && ./gradlew :wear:assembleDebug

## Project structure

Feature-first layout:

    lib/
      main.dart            startup, shake handler
      app.dart             MaterialApp, theme, localisation
      core/                shared by all features
        localization/      locale controller, language picker
        services/          background alerts (SMS, location, notifications), phone calls
        theme/             brand colours and theme
        widgets/           shared widgets
      features/<feature>/  onboarding, splash, home, emergency, safe_places,
                           get_home_safe, contacts, resources, settings, legal,
                           tracker_watch
        data/              models and storage
        presentation/      screens, widgets/ for feature-only widgets
      l10n/                ARB translations and generated code
    plugins/audio_background_record/   local plugin: foreground-service audio recorder
    plugins/tracker_scan/              local plugin: filtered Bluetooth LE scan
    android/wear/          Wear OS SOS app (native Kotlin)
    test/                  mirrors lib/

## Tracker watch

Finds AirTags, Samsung SmartTags, Tile, Chipolo, Pebblebee and Google Find Hub tags near the phone, and warns when one that is away from its owner travels along. Everything stays on the phone.

- Scan now: one 10-second scan, a list of what is near and whether each tag is with its owner.
- Watching in the background: a Workmanager task scans about every 15 minutes and stores tags that are not known to be with their owner, with the time and place (`sightings.jsonl` in the app's folder, kept 14 days). The warning comes when the same tag was seen at least 3 times, over at least an hour, at 3 places more than 150 m apart, within a day. In discreet mode there is no notification, only the warning in the app.
- Per tracker: a finder that shows the signal strength, Play sound (AirTag, Find My, Google and Pebblebee tags), save to the diary, ignore, and what to do.

It needs a real phone (no emulator) with Bluetooth and location on, and for the background watch location set to Allow all the time. In a debug build every match is printed with its raw bytes (`tracker_scan ...` in the log), to check the recognition against a real tag.

## Credits

Tracker watch: the advert patterns, the sound commands and the rule for a tracker that travels along follow [AirGuard](https://github.com/seemoo-lab/AirGuard) (TU Darmstadt, Apache-2.0).

The help and information carousel shows previews of the organisations' own websites (Veilig Thuis, Centrum Seksueel Geweld, Slachtofferhulp Nederland, 113 Zelfmoordpreventie, Switchboard, Politie, Rijksoverheid), taken from their Open Graph images or homepage headers. They remain the property of those organisations.

Font: Readex Pro, SIL Open Font License 1.1 (assets/fonts/OFL.txt).

Colours: Catppuccin (Latte for light, Mocha for dark), MIT licence, catppuccin.com.

## Origin

Based on the [M3ak prototype](https://github.com/adam-bouafia/M3ak-Mobile-Application-Prototype), originally developed in Tunisia in 2022.
