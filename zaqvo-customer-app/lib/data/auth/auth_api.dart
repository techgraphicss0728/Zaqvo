import 'package:dio/dio.dart';
import 'package:zaqvo_customer_app/core/errors/app_exception.dart';

/// Result of a successful OTP verification.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Authenticated customer profile as returned by `GET /users/me`.
class AuthProfile {
  const AuthProfile({required this.id, this.name, this.mobileNumber});

  final String id;
  final String? name;
  final String? mobileNumber;
}

/// Thin client for the backend customer auth + profile endpoints.
///
/// All methods translate backend error payloads into [AppException] so the
/// existing [ErrorMapper] / UI can surface a clean message.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<void> sendLoginOtp(String mobileNumber) async {
    try {
      await _dio.post(
        '/auth/customer/login/send-otp',
        data: {'mobile_number': mobileNumber},
      );
    } on DioException catch (error) {
      throw _toAppException(
        error,
        fallback: 'Unable to send OTP. Please try again.',
      );
    }
  }

  Future<AuthTokens> verifyLoginOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/customer/login/verify-otp',
        data: {'mobile_number': mobileNumber, 'otp': otp},
      );
      final data = response.data as Map;
      return AuthTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
    } on DioException catch (error) {
      throw _toAppException(error, fallback: 'Invalid OTP. Please try again.');
    }
  }

  Future<AuthProfile> fetchProfile(String accessToken) async {
    final response = await _dio.get(
      '/users/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final data = response.data as Map;
    return AuthProfile(
      id: data['id'] as String,
      name: data['name'] as String?,
      mobileNumber: data['mobile_number'] as String?,
    );
  }

  Future<void> registerFcmToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    await _dio.post(
      '/users/me/fcm-token',
      data: {'fcm_token': fcmToken},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  AppException _toAppException(DioException error, {required String fallback}) {
    final apiMessage = _extractApiMessage(error.response?.data);
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return AppException(
        userMessage: apiMessage,
        debugMessage: error.message,
      );
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException(
        userMessage: 'Cannot reach server. Check Wi‑Fi and that the backend is running.',
        debugMessage: error.message,
      );
    }
    return AppException(userMessage: fallback, debugMessage: error.message);
  }

  /// Supports both FastAPI default `{detail}` and Zaqvo `{error: {message}}`.
  static String? _extractApiMessage(dynamic data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    final error = data['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }
}
