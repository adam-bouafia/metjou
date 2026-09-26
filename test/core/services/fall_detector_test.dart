import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:metjou/core/services/fall_detector.dart';

/// Feeds (g, duration) segments at 50 Hz; returns how often a fall fired.
int run(List<(double Function(int i), Duration)> segments) {
  final d = FallDetector();
  var t = Duration.zero;
  var falls = 0;
  const step = Duration(milliseconds: 20);
  for (final (g, length) in segments) {
    final n = length.inMilliseconds ~/ 20;
    for (var i = 0; i < n; i++) {
      if (d.add(g(i), t)) falls++;
      t += step;
    }
  }
  return falls;
}

double still(int _) => 1.0;
Duration ms(int v) => Duration(milliseconds: v);

void main() {
  test('free fall, hard impact, lying still: one fall', () {
    expect(
      run([
        (still, ms(1000)),
        ((_) => 0.1, ms(400)),
        ((_) => 4.0, ms(60)),
        (still, ms(5000)),
      ]),
      1,
    );
  });

  test('dropped phone that is picked up again: no fall', () {
    expect(
      run([
        (still, ms(1000)),
        ((_) => 0.1, ms(400)),
        ((_) => 4.0, ms(60)),
        (still, ms(800)),
        ((i) => 1 + 0.8 * sin(i / 3), ms(2000)),
        (still, ms(3000)),
      ]),
      0,
    );
  });

  test('walking and jogging: no fall', () {
    expect(run([((i) => 1 + 0.6 * sin(i / 2), ms(20000))]), 0);
  });

  test('a very short dip: no fall', () {
    expect(
      run([
        (still, ms(1000)),
        ((_) => 0.2, ms(40)),
        ((_) => 3.0, ms(60)),
        (still, ms(5000)),
      ]),
      0,
    );
  });

  test('free fall without an impact (soft landing): no fall', () {
    expect(
      run([
        (still, ms(1000)),
        ((_) => 0.1, ms(400)),
        ((_) => 1.4, ms(200)),
        (still, ms(5000)),
      ]),
      0,
    );
  });
}
