import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/shared/widgets/app_logo.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.mobile});

  final String mobile;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String get _apiMobile => '91${widget.mobile.replaceAll(RegExp(r"\D"), '')}';

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final success = await appState.verifyLoginOtp(
      mobileNumber: _apiMobile,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;
    if (!success) {
      Fluttertoast.showToast(
        msg: appState.statusMessage?.isNotEmpty ?? false
            ? appState.statusMessage!
            : 'Incorrect OTP. Please try again.',
        gravity: ToastGravity.BOTTOM,
      );
      appState.clearStatusMessage();
    }
    // On success, the router redirect sends the now-authenticated user home.
  }

  Future<void> _resendOtp() async {
    final appState = context.read<AppState>();
    if (appState.isBusy) return;
    final sent = await appState.sendLoginOtp(_apiMobile);
    if (!mounted) return;
    Fluttertoast.showToast(
      msg: sent
          ? 'OTP resent'
          : (appState.statusMessage ?? 'Unable to resend OTP.'),
      gravity: ToastGravity.BOTTOM,
    );
    if (!sent) appState.clearStatusMessage();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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
                          const SizedBox(height: 8),
                          const Text(
                            'Verification',
                            style: TextStyle(
                              color: Color(0xFF2A88C8),
                              fontWeight: FontWeight.w600,
                              fontSize: 24 / 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: const BoxDecoration(
                                    color: AppColors.skyBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Enter OTP',
                                  style: TextStyle(
                                    color: Color(0xFF14416B),
                                    fontSize: 38 / 1.4,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "We've sent a 6-digit code to\nyour Mobile Number",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    fontSize: 32 / 1.4,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _otpController,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  decoration:
                                      const InputDecoration(counterText: ''),
                                  validator: (value) {
                                    if ((value ?? '').trim().length != 6) {
                                      return 'Enter 6-digit OTP';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2684C6),
                                          Color(0xFF36C2F0),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x552684C6),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: FilledButton(
                                      onPressed:
                                          appState.isBusy ? null : _verify,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: appState.isBusy
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Verify & continue ->',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextButton(
                                  onPressed: appState.isBusy ? null : _resendOtp,
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: AppColors.skyBlue,
                                      fontWeight: FontWeight.w700,
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
                          fontSize: 18,
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
