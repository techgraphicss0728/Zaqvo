import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/shared/widgets/app_logo.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    final mobile = _mobileController.text.trim();
    context.push('${AppRoutes.otp}?mobile=${Uri.encodeComponent(mobile)}');
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEF9FF), Color(0xFFDCECF6)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const AppLogo(size: 56, showText: false),
                          ),
                          const SizedBox(height: 34),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    color: Color(0xFF2A7ABB),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Enter your mobile number to continue',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: '+91 1234567894',
                                    hintStyle:
                                        const TextStyle(color: Colors.black26),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDDE6EF), width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2A7ABB), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.redAccent, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.redAccent, width: 1.5),
                                    ),
                                  ),
                                  validator: (value) {
                                    final phone =
                                        value?.replaceAll(RegExp(r'\D'), '');
                                    if (phone == null || phone.length < 10) {
                                      return 'Enter a valid mobile number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6AAFD6),
                                          Color(0xFF8DCEE8)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: FilledButton(
                                      onPressed: _onContinue,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        'Continue →',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Center(
                                  child: Text(
                                    'By continuing, you agree to our\nTerms & Privacy Policy',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: AppColors.skyBlue,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Pure Water Delivered to your doorstep',
                        style: TextStyle(
                          color: Color(0xFF2A88C8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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