import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';
import 'package:zaqvo_delivery_app/core/validation/phone_and_otp.dart';
import 'package:zaqvo_delivery_app/shared/widgets/app_logo.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.mobile});

  final String mobile;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool get _isFourDigitOtp =>
      RegExp(r'^\d{4}$').hasMatch(_otpController.text.trim());

  void _onOtpChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    super.dispose();
  }

  String get _displayMobile {
    final d = widget.mobile.replaceAll(RegExp(r'\D'), '');
    if (d.length == 10) {
      return '+91 $d';
    }
    return widget.mobile;
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<DeliveryAppState>();
    await appState.verifyLoginOtp(
      mobile: widget.mobile,
      otp: _otpController.text.trim(),
    );
    if (!mounted) return;
    if (appState.isAuthenticated) {
      return;
    }
    if (appState.statusMessage != null && appState.statusMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.statusMessage!)),
      );
      appState.clearStatusMessage();
    }
  }

  Future<void> _resend() async {
    final appState = context.read<DeliveryAppState>();
    if (PhoneAndOtp.normalizeIndianMobile(widget.mobile) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid number. Go back and re-enter.')),
        );
        context.pop();
      }
      return;
    }
    await appState.sendLoginOtp(widget.mobile);
    if (!mounted) return;
    if (appState.statusMessage != null && appState.statusMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.statusMessage!)),
      );
      appState.clearStatusMessage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<DeliveryAppState>();

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF2A88C8),
                  ),
                ),
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
                                  "Enter the 4-digit code for\n$_displayMobile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    fontSize: 32 / 1.4,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _otpController,
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [AutofillHints.oneTimeCode],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  buildCounter: (
                                    context, {
                                    required int currentLength,
                                    required int? maxLength,
                                    required bool isFocused,
                                  }) =>
                                      const SizedBox.shrink(),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    hintText: '••••',
                                    hintStyle: TextStyle(
                                        letterSpacing: 12, color: Colors.black26),
                                  ),
                                  validator: PhoneAndOtp.validateOtpField,
                                ),
                                const SizedBox(height: 16),
                                Builder(
                                  builder: (context) {
                                    final ready = _isFourDigitOtp;
                                    return SizedBox(
                                      width: double.infinity,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: ready
                                                ? const [
                                                    Color(0xFF2684C6),
                                                    Color(0xFF36C2F0),
                                                  ]
                                                : const [
                                                    Color(0xFF9AC4E0),
                                                    Color(0xFFB0DAEE),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: ready
                                              ? const [
                                                  BoxShadow(
                                                    color: Color(0x552684C6),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: FilledButton(
                                          onPressed: ready && !appState.isBusy
                                              ? _verify
                                              : null,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
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
                                              : Text(
                                                  'Verify & continue ->',
                                                  style: TextStyle(
                                                    color: ready
                                                        ? Colors.white
                                                        : const Color(0xFF5A7A8E),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextButton(
                                  onPressed: appState.isBusy ? null : _resend,
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
