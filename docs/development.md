# Development

## What you need

- Flutter 3.47 or later (Dart 3.9 or later)
- JDK 21. With `flutter config --jdk-dir <path>` Flutter uses it regardless of the system Java.
- Android SDK with API 37
- A real phone for anything with SMS, sensors or Bluetooth. The tracker watch does not work in an emulator.

```sh
flutter pub get
tool/dev.sh run
```

## Building with little free memory

A debug build needs about 4.5 GB next to everything else that is open. It was measured at a peak of 4.2 GB for Gradle, the Kotlin daemon, the Dart compiler and the Flutter tool together. On a machine with 16 GB and no swap that is enough to freeze the desktop when a browser and an editor are open too.

`tool/dev.sh` wraps the Flutter commands:

```sh
tool/dev.sh run        # flutter run
tool/dev.sh build      # flutter build apk --debug
tool/dev.sh test       # flutter test, two files at a time
tool/dev.sh analyze    # dart analyze lib test
tool/dev.sh mem        # who uses the memory right now
tool/dev.sh tidy       # stop Gradle and Kotlin daemons
```

Each command runs in its own systemd scope with a memory limit and at low priority. If it grows past the limit, the kernel stops that command and leaves the desktop alone. It refuses to start when too little memory is free and then prints who is using it; `FORCE=1` skips that check. Arguments are passed on, for example `tool/dev.sh test test/features/tracker_watch`.

Three settings in the repository keep memory free:

- `android/gradle.properties` caps the Gradle heap at 4 GB and the Kotlin daemon at 1 GB, and lets the Gradle daemon exit two minutes after a build instead of after three hours.
- `.vscode/settings.json` runs the Java extension of VS Code in syntax-only mode and stops the Gradle extension from scanning for tasks. Left alone they import every `android/` folder and keep five to seven Gradle daemons running, about 4 GB.
- Tests run two files at a time. The Flutter default is one per CPU core.

On the machine itself, a tool such as earlyoom stops the largest program before the system freezes:

```sh
sudo dnf install earlyoom && sudo systemctl enable --now earlyoom
```

## Tests

```sh
tool/dev.sh test
tool/dev.sh test test/features/tracker_watch/data
```

Tests mirror `lib/`: `lib/features/x/data/y.dart` is tested in `test/features/x/data/y_test.dart`. The local plugin has its own tests in `plugins/tracker_scan/test`.

Conventions:

- Rules are plain functions and are tested with tables of cases (`fall_detector`, `low_battery`, `follow_detector`).
- Real behaviour over mocks. Only Android is faked: a platform channel gets a mock handler, storage on disk gets an in-memory fake.
- Screens take their platform calls as a parameter with a real default (`TrackerActions`), so a test passes its own.
- Layout tests run each screen at a small size (360 x 780) with text scaled to 1.3, in all five languages.

Things that bite in widget tests:

- Real file reads never finish under the test's fake clock. Use the fakes in `test/features/tracker_watch/support.dart`.
- `pumpAndSettle` never returns while the PIN sheet is open, because its cursor blinks. Use `pump` with a duration.
- Awaiting `StreamController.close()` inside `testWidgets` hangs.
- Do not render the animated onboarding in a test. It never settles and uses a lot of memory.

## Translations

Texts are in `lib/l10n/app_<lang>.arb`: English is the template, Dutch is the app's default language, and French, Arabic and Spanish follow.

1. Add the key to `app_en.arb`, with a `@key` entry when it has placeholders.
2. Add the same key to the other four files.
3. Run `flutter gen-l10n`. The generated Dart files are committed.

Tone: informal in Dutch ("je") and Spanish ("tú"), formal in French ("vous"). Arabic is right to left, so check a screen in Arabic when you change its layout.

## Adding a feature

1. Create `lib/features/<name>/data` and `presentation`.
2. Put rules and storage in `data`, with tests. Keep rules free of plugins where you can.
3. Put screens in `presentation`. Use `context.l10n` for every text.
4. Add the entry point: a card or tile on the home screen (`features/home`), or a setting.
5. If it needs Android code that must also run in the background, make it a local plugin under `plugins/`. Otherwise add a method to the `metjou/device` channel in `MainActivity`.
6. If it stores or sends anything new, update the privacy policy in `assets/legal` (English and Dutch).

## Android build notes

| What | Version |
| --- | --- |
| Android Gradle Plugin | 9.4.1 |
| Gradle | 9.8.0 |
| Kotlin | 2.4.20 |
| compileSdk | 37 |
| minSdk | 24 |

- The modules of this repository (`app`, `wear` and the two local plugins) do not apply the Kotlin Gradle Plugin themselves. The Flutter Gradle plugin adds Kotlin support to them.
- A build still prints one warning that names five plugins: `another_telephony`, `flutter_native_contact_picker`, `flutter_phone_direct_caller`, `sensors_plus` and `workmanager_android`. Their build files apply the Kotlin Gradle Plugin, which a future Flutter version will refuse. Nothing breaks today, and `android.builtInKotlin` stays `false` in `gradle.properties` until they are updated.
- Where each one stands: `workmanager_android` already applies it only when needed and is listed because the check reads the build file as text; `sensors_plus` 7 has the fix but is held at 6 by `shake`; the other three have no fixed release yet.
- A release build is signed with `android/key.properties` when that file exists, and with the debug key otherwise.
- The Wear OS app is a separate module: `cd android && ./gradlew :wear:assembleDebug`. It must be signed with the same key as the phone app.

## Checking on a phone

```sh
tool/dev.sh run
adb logcat -s flutter
```

In a debug build the tracker scan prints every advert that passes its filters, on lines that start with `tracker_scan`. See [Tracker watch](tracker-watch.md).

## Documentation

The pages in `docs/` build into a site with MkDocs and the Material theme.

```sh
docs/serve.sh
```

The script creates a Python virtual environment in `docs/.venv`, installs MkDocs there and serves the site on <http://127.0.0.1:8000>. Diagrams are Mermaid, which GitHub and the site both render.
