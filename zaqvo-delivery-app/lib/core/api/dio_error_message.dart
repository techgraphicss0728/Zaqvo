import 'package:dio/dio.dart';

String dioErrorToMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['detail'] != null) {
    return data['detail'].toString();
  }
  if (e.message != null && e.message!.isNotEmpty) {
    return e.message!;
  }
  return 'Something went wrong. Please try again.';
}
