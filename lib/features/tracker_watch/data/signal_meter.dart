import 'package:metjou/features/tracker_watch/data/tracker_signature.dart';

enum SignalTrend { closer, steady, further }

/// Turns the jumpy signal readings of one tracker into a steady level and a
/// direction, to walk towards it.
///
/// It keeps a fast and a slow moving average: the fast one is the level
/// shown, and the gap between the two tells whether the signal is rising.
class SignalMeter {
  /// Gap in dB between the averages before a trend is reported.
  static const _trendGap = 3.0;

  double? _fast;
  double? _slow;

  void add(int rssi) {
    _fast = _fast == null ? rssi.toDouble() : _fast! * 0.6 + rssi * 0.4;
    _slow = _slow == null ? rssi.toDouble() : _slow! * 0.9 + rssi * 0.1;
  }

  /// Smoothed signal strength in dBm, or null before the first reading.
  double? get level => _fast;

  /// 0 at the edge of range (-100 dBm) to 1 right next to it (-40 dBm).
  double get strength => (((_fast ?? -100) + 100) / 60).clamp(0, 1).toDouble();

  Proximity get proximity => proximityOf(_fast ?? -100);

  SignalTrend get trend {
    final gap = (_fast ?? 0) - (_slow ?? 0);
    if (gap > _trendGap) return SignalTrend.closer;
    if (gap < -_trendGap) return SignalTrend.further;
    return SignalTrend.steady;
  }
}
