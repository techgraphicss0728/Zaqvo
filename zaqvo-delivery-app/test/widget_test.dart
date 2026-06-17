import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/core/auth/auth_session.dart';
import 'package:zaqvo_delivery_app/features/auth/presentation/pages/login_page.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

void main() {
  testWidgets('Login page shows welcome title', (WidgetTester tester) async {
    final state = DeliveryAppState(
      AuthSession(),
      Dio(BaseOptions(baseUrl: 'https://example.test')),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<DeliveryAppState>.value(
        value: state,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
