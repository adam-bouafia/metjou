# tracker_scan

Local plugin for MetJou: one filtered Bluetooth LE scan on Android.

The plugin knows nothing about trackers. The app passes the filters (which
advert bytes to match) and gets the matching adverts back, so all tracker
knowledge stays in Dart where it can be unit-tested.

It is a plugin, not a channel in MainActivity, because background tasks run
in their own Flutter engine, where only plugins are available.
