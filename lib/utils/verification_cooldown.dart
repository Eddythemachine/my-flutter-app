import 'package:flutter/foundation.dart';

class VerificationCooldown {
  VerificationCooldown._();

  static DateTime? _lastSentAt;
  static const Duration duration = Duration(minutes: 1);

  static bool get canSend {
    if (_lastSentAt == null) return true;
    return DateTime.now().difference(_lastSentAt!) >= duration;
  }

  static int get remainingSeconds {
    if (_lastSentAt == null) return 0;
    final remaining = duration - DateTime.now().difference(_lastSentAt!);
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  static void markSent() {
    _lastSentAt = DateTime.now();
    if (kDebugMode) {
      debugPrint("Verification cooldown started: ${duration.inSeconds}s");
    }
  }

  static void reset() => _lastSentAt = null;
}
