# MetJou

MetJou ("met jou", Dutch for "with you") is a personal safety app for Android, built with Flutter. One press or a shake sends an SMS with your location to up to three people you trust. Around that it has tools for getting home safely, for getting out of a bad situation and for keeping evidence.

## Principles

- **Nothing leaves the phone unless you send it.** There is no account, no server and no analytics. Contacts, the diary, recordings and tracker sightings stay in the app's own storage.
- **An alert is an SMS.** It goes through your own mobile provider, so it also works without mobile data. The location is a Google Maps link in the text.
- **An alert never waits.** If no location fix arrives within ten seconds, the message goes out without one.
- **Mistakes can be undone.** Alerts that start without a deliberate press (shake, fall, tile, widget, watch) run a countdown first.
- **The phone may be checked by someone else.** A PIN protects the sensitive screens, and discreet mode hides the app.

## Pages

| Page | What it covers |
| --- | --- |
| [Features](features.md) | Every feature: what it does, how it behaves and where its code is |
| [Architecture](architecture.md) | Layers, the alert sequence, background tasks, channels, storage, permissions |
| [Tracker watch](tracker-watch.md) | How trackers are recognised and when the app warns |
| [Development](development.md) | Setup, building with little memory, tests, translations, Android build notes |

## Status

In development, not in a store yet. The app runs on a Samsung S22 Ultra with Android 16. The tracker watch has scanned on that phone, but has not been tested against a real tag that is away from its owner.

## Origin

MetJou is a rebuild of the M3ak prototype, made in Tunisia in 2022, adapted for the Netherlands: Dutch emergency numbers and help organisations, and Dutch as the default language.
