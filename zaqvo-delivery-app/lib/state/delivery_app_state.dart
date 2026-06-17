import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zaqvo_delivery_app/core/api/dio_error_message.dart';
import 'package:zaqvo_delivery_app/core/auth/auth_session.dart';
import 'package:zaqvo_delivery_app/core/validation/phone_and_otp.dart';

class DeliveryAppState extends ChangeNotifier {
  DeliveryAppState(this._authSession, this._dio);

  final AuthSession _authSession;
  final Dio _dio;

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isBusy = false;
  String? _statusMessage;

  bool get isInitialized => _isInitialized;
  bool get isBusy => _isBusy;
  String? get statusMessage => _statusMessage;
  bool get isAuthenticated => _authSession.isLoggedIn;

  void clearStatusMessage() {
    _statusMessage = null;
    notifyListeners();
  }

  /// Splash + session restore. Matches customer splash ~2.1s wait before routing.
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    try {
      await _authSession.load();
      await Future.wait([
        if (_authSession.isLoggedIn && !_authSession.isDummySession)
          _validateSession()
        else
          Future.value(),
        Future<void>.delayed(const Duration(milliseconds: 2100)),
      ]);
      _isInitialized = true;
      notifyListeners();
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _validateSession() async {
    try {
      await _dio.get<Map<String, dynamic>>('users/me');
    } on DioException {
      await _authSession.clearPersisted();
    }
  }

  /// No backend call: navigation to OTP is immediate after 10 valid digits; optional “sending” delay for UX.
  Future<void> sendLoginOtp(String mobile) async {
    final digits = PhoneAndOtp.normalizeIndianMobile(mobile);
    if (digits == null) {
      _statusMessage = 'Invalid mobile number';
      notifyListeners();
      return;
    }
    await _runBusyAction(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
  }

  /// Dev: any 4 digits completes sign-in (dummy session; no server verification).
  Future<void> verifyLoginOtp({
    required String mobile,
    required String otp,
  }) async {
    final digits = PhoneAndOtp.normalizeIndianMobile(mobile);
    if (digits == null) {
      _statusMessage = 'Invalid mobile number';
      notifyListeners();
      return;
    }
    if (PhoneAndOtp.validateOtpField(otp) != null) {
      _statusMessage = 'Invalid OTP';
      notifyListeners();
      return;
    }
    await _runBusyAction(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _authSession.accessToken = AuthSession.kDummyAccessToken;
      _authSession.refreshToken = AuthSession.kDummyRefreshToken;
      await _authSession.save();
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _authSession.clearPersisted();
    notifyListeners();
  }

  /// Invoked from [createApiClient] on HTTP 401 (e.g. expired token).
  void handleUnauthorized() {
    unawaited(_clearSessionAfterUnauthorized());
  }

  Future<void> _clearSessionAfterUnauthorized() async {
    await _authSession.clearPersisted();
    notifyListeners();
  }

  Future<void> _runBusyAction(Future<void> Function() action) async {
    _isBusy = true;
    _statusMessage = null;
    notifyListeners();
    try {
      await action();
    } on DioException catch (e) {
      _statusMessage = dioErrorToMessage(e);
    } catch (e, st) {
      debugPrint('DeliveryAppState: $e\n$st');
      _statusMessage = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
