import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_delivery_app/core/router/app_routes.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';

/// Shown for unknown routes or routing failures — no stack traces, no "Page Not Found" developer UI.
class RouteFallbackPage extends StatelessWidget {
  const RouteFallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Something went wrong with navigation. '
                  "We've taken you back to a safe screen.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.splash),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
