import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/shared/widgets/app_logo.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().initialize();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.backgroundLight),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.skyBlue,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const AppLogo(size: 70, showText: false),
                const SizedBox(height: 8),
                const Text(
                  'PURE HYDRATION DELIVERED',
                  style: TextStyle(
                    color: AppColors.slate700,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500,
                    fontSize: 28 / 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 26 / 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: 'LOADING YOUR FRESH SUPPLY '),
                      TextSpan(
                        text: '35%',
                        style: TextStyle(color: AppColors.purpleAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, _) {
                      return Align(
                        alignment:
                            Alignment(-1 + (_waveController.value * 0.7), 0),
                        child: Container(
                          width: 95,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF32B8E8), Color(0xFF4CC9F0)],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  appState.statusMessage ?? '© 2026 ZAQVO Water Delivery',
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
