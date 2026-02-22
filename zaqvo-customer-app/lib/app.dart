import 'package:flutter/material.dart';
import 'package:zaqvo_customer_app/core/router/app_router.dart';
import 'package:zaqvo_customer_app/core/theme/app_theme.dart';

class ZaqvoCustomerApp extends StatelessWidget {
  const ZaqvoCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zaqvo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
