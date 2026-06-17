class AppException implements Exception {
  const AppException({
    required this.userMessage,
    this.debugMessage,
  });

  final String userMessage;
  final String? debugMessage;

  @override
  String toString() => debugMessage ?? userMessage;
}
