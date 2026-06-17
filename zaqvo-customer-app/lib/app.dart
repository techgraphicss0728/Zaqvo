import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/router/app_router.dart';
import 'package:zaqvo_customer_app/core/theme/app_theme.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class ZaqvoCustomerApp extends StatefulWidget {
  const ZaqvoCustomerApp({super.key});

  @override
  State<ZaqvoCustomerApp> createState() => _ZaqvoCustomerAppState();
}

class _ZaqvoCustomerAppState extends State<ZaqvoCustomerApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= createAppRouter(context.read<AppState>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zaqvo Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router!,
    );
  }
}
