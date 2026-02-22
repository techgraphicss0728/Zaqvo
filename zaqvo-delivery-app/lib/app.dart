import 'package:flutter/material.dart';
import 'package:zaqvo_delivery_app/core/router/app_router.dart';
import 'package:zaqvo_delivery_app/core/theme/app_theme.dart';

class ZaqvoDeliveryApp extends StatelessWidget {
  const ZaqvoDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zaqvo Delivery',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
