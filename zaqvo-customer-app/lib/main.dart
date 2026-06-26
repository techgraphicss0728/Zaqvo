import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/app.dart';
import 'package:zaqvo_customer_app/core/api/api_client.dart';
import 'package:zaqvo_customer_app/core/config/app_config.dart';
import 'package:zaqvo_customer_app/core/errors/error_mapper.dart';
import 'package:zaqvo_customer_app/core/services/fcm_service.dart';
import 'package:zaqvo_customer_app/core/storage/hive_boxes.dart';
import 'package:zaqvo_customer_app/core/storage/secure_storage_service.dart';
import 'package:zaqvo_customer_app/data/auth/auth_api.dart';
import 'package:zaqvo_customer_app/data/repositories/customer_repository.dart';
import 'package:zaqvo_customer_app/data/repositories/mock_customer_repository.dart';
import 'package:zaqvo_customer_app/shared/widgets/error_view.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _safeLoadEnv();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(HiveBoxes.cart);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter framework error: ${details.exceptionAsString()}');
  };

  ErrorWidget.builder = (details) {
    final message = ErrorMapper.toUserMessage(details.exception);
    return Material(
      child: ErrorView(
        message: message,
        onRetry: () {},
      ),
    );
  };

  runApp(
    riverpod.ProviderScope(
      child: MultiProvider(
        providers: [
          Provider<AppConfig>(
            create: (_) => AppConfig(
              apiBaseUrl:
                  dotenv.env['API_BASE_URL'] ?? 'https://api.zaqvo.mock/v1',
              googleMapsApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
            ),
          ),
          Provider<SecureStorageService>(
            create: (_) =>
                SecureStorageService(const FlutterSecureStorage()),
          ),
          Provider<FcmService>(
            create: (_) => FcmService(),
          ),
          Provider<AuthApi>(
            create: (context) =>
                AuthApi(createApiClient(context.read<AppConfig>())),
          ),
          Provider<CustomerRepository>(
            create: (_) => const MockCustomerRepository(),
          ),
          ChangeNotifierProvider<AppState>(
            create: (context) => AppState(
              context.read<CustomerRepository>(),
              authApi: context.read<AuthApi>(),
              secureStorage: context.read<SecureStorageService>(),
              fcmService: context.read<FcmService>(),
            ),
          ),
        ],
        child: const ZaqvoCustomerApp(),
      ),
    ),
  );
}

Future<void> _safeLoadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optional env file for local development only.
  }
}
