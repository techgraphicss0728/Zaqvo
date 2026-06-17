import 'package:dio/dio.dart';
import 'package:zaqvo_delivery_app/core/auth/auth_session.dart';
import 'package:zaqvo_delivery_app/core/config/app_config.dart';

Dio createApiClient(
  AppConfig config,
  AuthSession authSession, {
  void Function()? onUnauthorized,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = authSession.accessToken;
      if (token != null &&
          token.isNotEmpty &&
          !authSession.isDummySession) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (err, handler) {
      if (err.response?.statusCode == 401 && !authSession.isDummySession) {
        onUnauthorized?.call();
      }
      return handler.next(err);
    },
  ));
  return dio;
}
