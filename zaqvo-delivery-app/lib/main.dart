import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/app.dart';
import 'package:zaqvo_delivery_app/core/api/api_client.dart';
import 'package:zaqvo_delivery_app/core/auth/auth_session.dart';
import 'package:zaqvo_delivery_app/core/config/app_config.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

const String _defaultApiBaseUrl = 'http://localhost:8000/api/v1';

String _resolveApiBaseUrl() {
  final v = dotenv.env['API_BASE_URL'];
  if (v == null) return _defaultApiBaseUrl;
  final trimmed = v.trim();
  return trimmed.isEmpty ? _defaultApiBaseUrl : trimmed;
}

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(
    fileName: '.env',
    isOptional: true,
    mergeWith: {'API_BASE_URL': _defaultApiBaseUrl},
  );
  final config = AppConfig(apiBaseUrl: _resolveApiBaseUrl());
  final authSession = AuthSession();
  await authSession.load();

  late final DeliveryAppState appState;
  final dio = createApiClient(
    config,
    authSession,
    onUnauthorized: () {
      appState.handleUnauthorized();
    },
  );
  appState = DeliveryAppState(authSession, dio);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        Provider<AuthSession>.value(value: authSession),
        Provider<Dio>.value(value: dio),
        ChangeNotifierProvider<DeliveryAppState>.value(value: appState),
      ],
      child: const ZaqvoDeliveryApp(),
    ),
  );
}
