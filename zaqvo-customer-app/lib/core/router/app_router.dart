import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_customer_app/features/home/presentation/pages/home_page.dart';
import 'package:zaqvo_customer_app/features/auth/presentation/pages/login_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
  ],
);
