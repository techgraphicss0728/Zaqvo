import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/core/router/app_routes.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';
import 'package:zaqvo_delivery_app/core/validation/phone_and_otp.dart';
import 'package:zaqvo_delivery_app/shared/widgets/app_logo.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  bool get _isTenDigitMobile =>
      PhoneAndOtp.normalizeIndianMobile(_mobileController.text) != null;

  void _onMobileChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_onMobileChanged);
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onMobileChanged);
    _mobileController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isTenDigitMobile) return;
    final mobile = _mobileController.text;
    final digits = PhoneAndOtp.mobileDigitsForApi(mobile);
    context.push('${AppRoutes.otp}?mobile=${Uri.encodeComponent(digits)}');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<DeliveryAppState>();
    final ready = _isTenDigitMobile;

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
                                  'Enter your 10-digit mobile number to continue',
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
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [AutofillHints.telephoneNumber],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  buildCounter: (
                                    context, {
                                    required int currentLength,
                                    required int? maxLength,
                                    required bool isFocused,
                                  }) =>
                                      const SizedBox.shrink(),
                                  decoration: InputDecoration(
                                    hintText: '9876543210',
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
                                      borderSide: BorderSide(
                                        color: const Color(0xFF2A7ABB),
                                        width: ready ? 2 : 1.5,
                                      ),
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
                                  validator: PhoneAndOtp.validateMobileField,
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: ready
                                            ? const [
                                                Color(0xFF4A9FDC),
                                                Color(0xFF6AD2F0),
                                              ]
                                            : const [
                                                Color(0xFFAACDE6),
                                                Color(0xFFC8E0ED),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: ready
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x442A7ABB),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: FilledButton(
                                      onPressed: ready && !appState.isBusy
                                          ? _onContinue
                                          : null,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        'Continue →',
                                        style: TextStyle(
                                          color: ready
                                              ? Colors.white
                                              : const Color(0xFF6B8A9E),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
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
