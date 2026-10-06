# Features

Paths are relative to `lib/`. Every feature folder has a `data` part (models, storage, rules) and a `presentation` part (screens).

## Alerts

### SOS button

The large button in the dock sends a help message with a Google Maps link by SMS to every SOS contact. While an alert is active the button shows STOP. Stopping asks for your PIN (when one is set) and sends "I am safe now" to the same contacts.

- Code: `features/home/presentation/dashboard.dart`, `core/services/background_services.dart` (`sendSosAlert`).
- If no location fix arrives within ten seconds the SMS goes out with "location not available".

### SOS contacts

Up to three contacts, picked from the phone's contacts or typed in. Deleting a contact asks for the PIN.

- Code: `features/contacts`.

### Safe Shake

When Safe Shake is on, shaking the phone starts the alert, also while the app is in the background. A countdown gives time to cancel: off, 3, 5 (default) or 10 seconds. Cancel on screen or from the notification.

- A foreground location service keeps the app alive in the background and keeps a recent location ready. Android shows its notification while it runs.
- Code: `main.dart` (shake handler), `core/services/alert_countdown.dart`.

### Audio recording

With audio recording on, a shake starts or stops a recording, up to the length you set. Recordings go to the app's private folder or to a folder you choose.

- Code: `plugins/audio_background_record` (foreground service), settings in `features/settings`.

### Tile, widget, shortcuts and watch

An SOS can also start from the Quick Settings tile, the home screen widget, the app icon shortcuts (SOS, fake call, siren) and the Wear OS watch app. They all run the countdown.

- Code: `core/services/launch_actions.dart`; Android side in `android/app/src/main/kotlin` (`SosTileService`, `SosWidgetProvider`, `WearSosListenerService`) and `android/wear`.

### Fall detection

While the app runs, the motion sensor is checked for a fall: a free fall, a hard impact within a second, then three seconds without movement. A fall starts the SOS countdown with at least 15 seconds to cancel.

- Code: `core/services/fall_detector.dart` (the rule, with its thresholds), `core/services/fall_detection.dart`.

### Low battery message

Every 15 minutes the battery level is checked. At 10% or lower your contacts get one message with your last location. It can fire again after the phone was charged above 20%.

- Code: `core/services/low_battery.dart`.

### Test alert

Settings has "Send a test alert", which sends a message marked as a test, so you and your contacts can check that alerts arrive.

## On the way

### Get home safe

Sends your location to one contact, either repeatedly (every 1, 5, 15 or 30 minutes, or a number you type) or once at a time you choose. "I'm home" stops it, ends a running check-in and tells your contacts you arrived.

- Code: `features/get_home_safe`.

### Check-in timer

Pick 15, 30, 60 or 120 minutes. Check in before the deadline ("I'm safe", in the app or from the notification) or add 15 minutes. If the deadline passes, your contacts get an alert with your location.

- A Workmanager task backs the timer up, so the alert is also sent when the app was closed.
- Code: `features/check_in`.

### Tracker watch

Finds AirTags, Samsung SmartTags, Tile, Chipolo, Pebblebee and Google Find Hub tags near the phone, and warns when one that is away from its owner travels with you. It has its own page: [Tracker watch](tracker-watch.md).

- Code: `features/tracker_watch`, `plugins/tracker_scan`.

### Nearby safe places

Four tiles open Google Maps with a search near you: police stations, hospitals, pharmacies and public transport.

- Code: `features/safe_places`.

## Getting out of a situation

### Fake call

Shows a realistic incoming call with the caller name you set, at once or after a delay, with the phone's own ringtone. When the app is in the background it arrives as a call notification.

- Code: `features/fake_call`.

### Siren

A loud two-tone alarm at full volume, a flashing screen and a strobing flashlight. Sound and flashlight can be switched separately. Volume and flashlight are restored when the screen closes.

- Code: `features/siren`.

### Quick exit

Opens a weather page in the browser and closes MetJou in one tap, like the quick-exit buttons on Dutch domestic violence websites.

- Code: `core/widgets/quick_exit_button.dart`.

### Discreet mode

For people whose phone may be checked by someone else:

- the launcher shows a calculator icon and name;
- status notifications are not shown, because Android prints the real app name in every notification header;
- the recent apps screen shows no preview;
- a tracker warning is not sent as a notification, only shown inside the app.

Android still lists the app as MetJou under Settings, Apps.

- Code: `core/services/discreet_mode.dart`, launcher aliases in `AndroidManifest.xml`.

## Evidence and information

### Incident diary

Notes with a date and photos. Photos are copied into the app's folder, so deleting them from the gallery keeps the record. The diary opens after the PIN and exports to a PDF that you can share.

- Code: `features/diary`.

### Medical ID

Name, date of birth, blood type, allergies, medication, conditions, an emergency contact and notes. With "Show on lock screen" on, it is a permanent notification that anyone holding the phone can read.

- Code: `features/medical_id`.

### Emergency numbers

One-tap calling: 112, 113 Suicide Prevention, police non-urgent (0900-8844), Veilig Thuis (0800-2000) and Switchboard.

- Code: `features/emergency`, `core/services/phone_call.dart`.
- A call uses the phone permission when granted, and opens the dialer otherwise, so a call never fails on a missing permission.

### Help and information

A carousel of Dutch organisations with a link to each website: Veilig Thuis, Centrum Seksueel Geweld, Slachtofferhulp Nederland, 113 Zelfmoordpreventie, Switchboard, Politie and Rijksoverheid.

- Code: `features/resources`.

## General

### PIN

The PIN stops an SOS alert and protects Settings, your contacts, the diary and the tracker screen. Without a PIN these open directly.

- Code: `core/widgets/pin_guard.dart`, `features/settings/presentation/change_pin.dart`.

### Languages and theme

Dutch (default), English, French, Arabic (right to left) and Spanish. Light and dark theme, or follow the phone.

- Code: `core/localization`, `lib/l10n`, `core/theme`.

### Onboarding and legal texts

The first start explains the permissions before asking for them. The privacy policy and terms are in the app in English and Dutch (`assets/legal`).
