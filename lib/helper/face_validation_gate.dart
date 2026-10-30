import 'package:flutter/foundation.dart';

const bool _faceValidationBypassRequested = bool.fromEnvironment(
  'CORINGA_DEBUG_BYPASS_FACE',
);

bool get isDebugFaceValidationBypassEnabled => isFaceValidationBypassEnabled(
  isDebugBuild: kDebugMode,
  bypassRequested: _faceValidationBypassRequested,
);

@visibleForTesting
bool isFaceValidationBypassEnabled({
  required bool isDebugBuild,
  required bool bypassRequested,
}) {
  return isDebugBuild && bypassRequested;
}

bool isFaceValidationSatisfied({
  required bool isFacePositioned,
  required bool debugBypassEnabled,
}) {
  return isFacePositioned || debugBypassEnabled;
}
