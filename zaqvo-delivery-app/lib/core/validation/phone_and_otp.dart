/// Normalizes and validates mobile numbers (India) and OTPs for the delivery app.
class PhoneAndOtp {
  const PhoneAndOtp._();

  /// Returns 10 digits for a valid Indian mobile, or `null` if invalid.
  static String? normalizeIndianMobile(String? input) {
    if (input == null) return null;
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) return null;
    if (!RegExp(r'^[6-9]\d{9}').hasMatch(digits)) return null;
    return digits;
  }

  /// `null` if valid, otherwise an error string for [TextFormField.validator].
  static String? validateMobileField(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your mobile number';
    final normalized = normalizeIndianMobile(v);
    if (normalized == null) {
      if (v.replaceAll(RegExp(r'\D'), '').isEmpty) {
        return 'Enter a valid 10-digit mobile number';
      }
      return 'Enter a valid Indian mobile number (10 digits, starts with 6–9)';
    }
    return null;
  }

  /// Digits from [value] — use after [validateMobileField] passes.
  static String mobileDigitsForApi(String? value) {
    return normalizeIndianMobile(value) ?? value!.replaceAll(RegExp(r'\D'), '');
  }

  /// `null` if valid, otherwise error (dev: any 4 digits accepted in app state).
  static String? validateOtpField(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Enter the OTP';
    if (t.length != 4) return 'Enter the 4-digit OTP';
    if (!RegExp(r'^\d{4}$').hasMatch(t)) return 'OTP must be 4 digits';
    return null;
  }
}
