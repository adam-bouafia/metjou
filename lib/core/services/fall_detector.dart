/// Recognises a fall in accelerometer readings: free fall, then a hard
/// impact shortly after, then the phone lying still. Pure logic, fed with
/// the acceleration magnitude in g and a timestamp, so it can be tested.
class FallDetector {
  /// Below this the phone is falling (weightless).
  static const freeFallG = 0.4;
  static const minFreeFall = Duration(milliseconds: 80);

  /// An impact this hard must follow the free fall...
  static const impactG = 2.5;
  static const impactWindow = Duration(milliseconds: 1000);

  /// ...and then the phone must stay still (close to 1 g) for a while.
  static const settle = Duration(milliseconds: 600);
  static const stillFor = Duration(seconds: 3);
  static const stillTolerance = 0.35;

  _State _state = _State.idle;
  Duration? _since;

  void reset() {
    _state = _State.idle;
    _since = null;
  }

  /// Returns true once, when a complete fall pattern was seen.
  bool add(double g, Duration t) {
    switch (_state) {
      case _State.idle:
        if (g < freeFallG) {
          _state = _State.falling;
          _since = t;
        }
      case _State.falling:
        if (g < freeFallG) break;
        if (t - _since! >= minFreeFall) {
          _state = _State.awaitingImpact;
          _since = t;
          // The reading that ended the free fall may be the impact itself.
          return add(g, t);
        }
        reset();
      case _State.awaitingImpact:
        if (g >= impactG) {
          _state = _State.settling;
          _since = t;
        } else if (t - _since! > impactWindow) {
          reset();
        }
      case _State.settling:
        if (t - _since! >= settle) {
          _state = _State.watchingStill;
          _since = t;
        }
      case _State.watchingStill:
        if ((g - 1).abs() > stillTolerance) {
          // Moving again: the person is fine, or it was the phone that fell.
          reset();
        } else if (t - _since! >= stillFor) {
          reset();
          return true;
        }
    }
    return false;
  }
}

enum _State { idle, falling, awaitingImpact, settling, watchingStill }
