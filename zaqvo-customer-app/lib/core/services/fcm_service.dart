import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Cloud Messaging so the rest of the app stays decoupled from
/// the plugin and never crashes when Firebase has not been configured yet
/// (e.g. before `google-services.json` / `GoogleService-Info.plist` are added).
class FcmService {
  bool _initialized = false;

  /// Initializes Firebase once. Safe to call repeatedly; failures are swallowed
  /// so the app keeps working without a Firebase config during early setup.
  Future<void> init() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _initialized = true;
    } catch (error) {
      debugPrint('FcmService: Firebase not configured yet ($error)');
    }
  }

  /// Requests notification permission and returns the device FCM token, or
  /// `null` if Firebase is unavailable / the token cannot be obtained.
  Future<String?> getToken() async {
    await init();
    if (!_initialized) return null;
    try {
      await FirebaseMessaging.instance.requestPermission();
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('FcmService: unable to get FCM token ($error)');
      return null;
    }
  }
}
