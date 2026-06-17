import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

/// Hub screen for account: opens from the profile icon; "Personal Details"
/// navigates to the editable profile form ([ProfilePage]).
class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key});

  static const _versionLabel = '1.0.0';

  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final last10 = digits.substring(digits.length - 10);
      return '+91 $last10';
    }
    return raw.isEmpty ? '—' : raw;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final name = user?.name.trim().isNotEmpty == true ? user!.name : 'Customer';
    final phone = user != null ? _formatPhone(user.phoneNumber) : '—';

    final memberSince = DateFormat('MMMM yyyy').format(DateTime.now());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            _Header(
              name: name,
              phone: phone,
              memberSince: memberSince,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Personal Details',
                          onTap: () => context.push(
                            '${AppRoutes.home}/profile/personal-details',
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.location_on_outlined,
                          label: 'Saved Addresses',
                          onTap: () => context.go(
                            '${AppRoutes.home}/saved-addresses',
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.autorenew_rounded,
                          label: 'Manage Subscription',
                          onTap: () =>
                              context.go('${AppRoutes.home}/schedule'),
                        ),
                        _MenuTile(
                          icon: Icons.credit_card_outlined,
                          label: 'Payment Methods',
                          onTap: () => context.push(
                            '${AppRoutes.home}/payment-methods',
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () => context.push(
                            '${AppRoutes.home}/notifications',
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & Support',
                          onTap: () => context.push(
                            '${AppRoutes.home}/help-support',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _LogoutButton(
                      onPressed: () {
                        appState.signOut();
                        context.go(AppRoutes.login);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Version $_versionLabel',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.phone,
    required this.memberSince,
  });

  final String name;
  final String phone;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0D47A1);
    const midBlue = Color(0xFF1565C0);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A3D7A), deepBlue, midBlue],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                color: Colors.lightBlue.shade100,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Member Since',
                                    style: TextStyle(
                                      color: Colors.lightBlue.shade100,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    memberSince,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border.withValues(alpha: 0.7),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1565C0), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF203447),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate400,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: red,
        side: const BorderSide(color: red, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white,
      ),
      icon: const Icon(Icons.logout_rounded, size: 22),
      label: const Text(
        'Logout',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
