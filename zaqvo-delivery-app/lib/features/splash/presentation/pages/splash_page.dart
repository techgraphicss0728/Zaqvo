import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

const _kLogoAsset = 'lib/assets/LOGO_ZAQVO.png';

/// First screen — water delivery partner branding; no progress bar.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      if (!mounted) return;
      context.read<DeliveryAppState>().initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF043D5C),
              Color(0xFF0A5A8C),
              Color(0xFF1E8BC0),
              Color(0xFF3EC6F7),
            ],
            stops: [0, 0.35, 0.72, 1],
          ),
        ),
        child: Stack(
          children: [
            // Soft “water” highlights
            Positioned(
              top: -60,
              right: -40,
              child: _glowBlob(200, 0.18),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: _glowBlob(180, 0.12),
            ),
            Positioned(
              bottom: -30,
              right: 20,
              child: _glowBlob(120, 0.1),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Image.asset(
                          _kLogoAsset,
                          height: 108,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.water_drop_rounded,
                              size: 72,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SlideTransition(
                      position: _slide,
                      child: FadeTransition(
                        opacity: _fade,
                        child: const Column(
                          children: [
                            Text(
                              'WATER DELIVERY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.2,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Partner',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Every drop, every doorstep —\npure water on your route.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xD9FFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        'ZAQVO · 2026',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBlob(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
