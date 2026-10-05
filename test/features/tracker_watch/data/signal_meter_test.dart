import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/features/tracker_watch/data/signal_meter.dart';
import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';

void main() {
  final start = DateTime(2026, 10, 5, 18);
  DateTime at(int seconds) => start.add(Duration(seconds: seconds));

  SignalMeter fed(List<int> readings) {
    final meter = SignalMeter();
    for (final (i, rssi) in readings.indexed) {
      meter.add(rssi, at(i));
    }
    return meter;
  }

  test('is lost before the first reading', () {
    final meter = SignalMeter();
    expect(meter.isLost(start), isTrue);
    expect(meter.level, isNull);
    expect(meter.strength, 0);
    expect(meter.trend, SignalTrend.steady);
  });

  test('is lost again after six seconds of silence', () {
    final meter = fed([-60]);
    expect(meter.isLost(at(6)), isFalse);
    expect(meter.isLost(at(7)), isTrue);
  });

  test('one reading sets the level', () {
    final meter = fed([-70]);
    expect(meter.level, -70);
    expect(meter.strength, 0.5);
    expect(meter.proximity, Proximity.close);
  });

  for (final (rssi, strength) in [
    (-110, 0.0),
    (-100, 0.0),
    (-40, 1.0),
    (-20, 1.0),
  ]) {
    test('strength of $rssi dBm is $strength', () {
      expect(fed([rssi]).strength, strength);
    });
  }

  test('a single spike moves the level only part of the way', () {
    final meter = fed([-80, -80, -80, -50]);
    expect(meter.level, closeTo(-68, 0.01));
  });

  test('a rising signal means getting closer', () {
    final meter = fed([-90, -88, -84, -78, -72, -66, -60]);
    expect(meter.trend, SignalTrend.closer);
    expect(meter.proximity, Proximity.close);
  });

  test('a falling signal means getting further away', () {
    expect(fed([-55, -58, -64, -70, -76, -82, -88]).trend, SignalTrend.further);
  });

  test('a jittery but level signal is steady', () {
    expect(
      fed([-70, -73, -68, -71, -69, -72, -70, -71]).trend,
      SignalTrend.steady,
    );
  });
}
