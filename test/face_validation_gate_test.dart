import 'package:coringa_plus/helper/face_validation_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('face validation gate', () {
    test('accepts a correctly positioned face', () {
      expect(
        isFaceValidationSatisfied(
          isFacePositioned: true,
          debugBypassEnabled: false,
        ),
        isTrue,
      );
    });

    test('blocks a missing face when bypass is disabled', () {
      expect(
        isFaceValidationSatisfied(
          isFacePositioned: false,
          debugBypassEnabled: false,
        ),
        isFalse,
      );
    });

    test('allows a missing face when debug bypass is enabled', () {
      expect(
        isFaceValidationSatisfied(
          isFacePositioned: false,
          debugBypassEnabled: true,
        ),
        isTrue,
      );
    });

    test('bypass requires both a debug build and explicit opt-in', () {
      expect(
        isFaceValidationBypassEnabled(
          isDebugBuild: true,
          bypassRequested: true,
        ),
        isTrue,
      );
      expect(
        isFaceValidationBypassEnabled(
          isDebugBuild: true,
          bypassRequested: false,
        ),
        isFalse,
      );
      expect(
        isFaceValidationBypassEnabled(
          isDebugBuild: false,
          bypassRequested: true,
        ),
        isFalse,
      );
    });

    test('compile-time bypass is disabled by default', () {
      expect(isDebugFaceValidationBypassEnabled, isFalse);
    });
  });
}
