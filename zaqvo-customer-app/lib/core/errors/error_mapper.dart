import 'package:dio/dio.dart';
import 'package:zaqvo_customer_app/core/errors/app_exception.dart';

class ErrorMapper {
  const ErrorMapper._();

  static String toUserMessage(Object error) {
    if (error is AppException) return error.userMessage;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check and retry.';
        case DioExceptionType.badResponse:
          return 'Something went wrong on our side. Please try again shortly.';
        default:
          return 'Unable to complete your request right now.';
      }
    }

    return 'Something unexpected happened. Please try again.';
  }
}
