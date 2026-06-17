import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/core/router/app_router.dart';
import 'package:zaqvo_delivery_app/core/theme/app_theme.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

class ZaqvoDeliveryApp extends StatefulWidget {
  const ZaqvoDeliveryApp({super.key});

  @override
  State<ZaqvoDeliveryApp> createState() => _ZaqvoDeliveryAppState();
}

class _ZaqvoDeliveryAppState extends State<ZaqvoDeliveryApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= createAppRouter(context.read<DeliveryAppState>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zaqvo Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router!,
    );
  }
}
