import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  DateTime? _selectedDob;
  bool _isEditMode = false;
  String? _lastHydratedUserId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _hydrateFromUser(AppState appState) {
    final user = appState.currentUser;
    if (user == null) return;
    if (_lastHydratedUserId == user.id && _nameController.text.isNotEmpty) {
      return;
    }
    _lastHydratedUserId = user.id;
    _nameController.text = user.name;
    _phoneController.text = user.phoneNumber;
    _emailController.text = user.email;
    _selectedDob = user.dateOfBirth;
    _dobController.text = user.dateOfBirth == null
        ? ''
        : DateFormat('MMM d, yyyy').format(user.dateOfBirth!);
  }

  Future<void> _pickDate(BuildContext context) async {
    if (!_isEditMode) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1999, 5, 14),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 12, now.month, now.day),
    );
    if (picked == null) return;
    setState(() {
      _selectedDob = picked;
      _dobController.text = DateFormat('MMM d, yyyy').format(picked);
    });
  }

  Future<void> _saveProfile(BuildContext context, AppState appState) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth.')),
      );
      return;
    }

    await appState.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dateOfBirth: _selectedDob!,
    );

    if (!mounted) return;
    if (appState.statusMessage?.isNotEmpty ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.statusMessage!)),
      );
      return;
    }
    setState(() => _isEditMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _hydrateFromUser(appState);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE3ECF3)),
                ),
                child: IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).maybePop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF2F3D4A),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(
            color: Color(0xFF203447),
            fontWeight: FontWeight.w700,
            fontSize: 22 / 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => setState(() => _isEditMode = !_isEditMode),
              child: Text(
                _isEditMode ? 'Cancel' : 'Edit',
                style: TextStyle(
                  color: AppColors.skyBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: WaterRefreshWrapper(
        onRefresh: appState.refreshData,
        child: Skeletonizer(
          enabled: appState.isBusy,
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.skyBlue,
                            width: 3,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('lib/assets/FEVICON_ZAQVO.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    _nameController.text.trim().isEmpty
                        ? 'Customer'
                        : _nameController.text.trim(),
                    style: const TextStyle(
                      color: Color(0xFF26384A),
                      fontSize: 30 / 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _ProfileInputField(
                  label: 'Full Name',
                  controller: _nameController,
                  enabled: _isEditMode,
                  hint: 'Enter full name',
                  icon: Icons.person_outline_rounded,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Full name is required';
                    if (text.length < 3) return 'Enter at least 3 characters';
                    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(text)) {
                      return 'Use letters only';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                _ProfileInputField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  enabled: _isEditMode,
                  hint: '+91 1234567890',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _ProfileInputField(
                  label: 'Email Address',
                  controller: _emailController,
                  enabled: _isEditMode,
                  hint: 'example@email.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$')
                        .hasMatch(text)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _ProfileInputField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  enabled: false,
                  hint: 'Select date of birth',
                  icon: Icons.calendar_today_outlined,
                  validator: (_) {
                    if (_selectedDob == null) return 'Date of birth is required';
                    return null;
                  },
                  onTap: () => _pickDate(context),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A9BD4), Color(0xFF50C7ED)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: FilledButton(
                      onPressed: _isEditMode && !appState.isBusy
                          ? () => _saveProfile(context, appState)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                              _isEditMode ? 'Save Details' : 'Enable Edit Mode',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
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

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.onTap,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7D8E),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled && onTap == null,
          readOnly: onTap != null,
          onTap: onTap,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE6EDF3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2A9BD4), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE6EDF3)),
            ),
            suffixIcon: Icon(icon, color: const Color(0xFFCAD4DE), size: 20),
          ),
        ),
      ],
    );
  }
}
