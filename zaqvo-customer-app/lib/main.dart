import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/app.dart';
import 'package:zaqvo_customer_app/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    Provider<AppConfig>(
      create: (_) => AppConfig(
        apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1',
      ),
      child: const ZaqvoCustomerApp(),
    ),
  );
}
