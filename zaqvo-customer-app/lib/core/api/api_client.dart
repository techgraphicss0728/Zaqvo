import 'package:dio/dio.dart';
import 'package:zaqvo_customer_app/core/config/app_config.dart';

Dio createApiClient(AppConfig config) {
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // TODO: attach access token from auth storage
      return handler.next(options);
    },
    onError: (err, handler) {
      if (err.response?.statusCode == 401) {
        // TODO: refresh token or navigate to login
      }
      return handler.next(err);
    },
  ));
  return dio;
}
