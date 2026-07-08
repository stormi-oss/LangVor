import 'package:flutter_test/flutter_test.dart';
import 'package:langvor/domain/srs_engine.dart';

void main() {
  test('SrsEngine SM-2 calculation smoke test', () {
    final result = SrsEngine.calculate(
      quality: 4,
      currentRepetitions: 0,
      currentInterval: 0,
      currentEaseFactor: 2.5,
    );

    expect(result.repetitions, 1);
    expect(result.interval, 1);
    expect(result.easeFactor, 2.5);
  });
}
