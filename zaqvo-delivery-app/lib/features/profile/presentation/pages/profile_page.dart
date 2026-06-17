import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_delivery_app/core/router/app_routes.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

/// Partner profile — Figma: gradient header, summary card, stats, details, logout.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _name = 'Venu';
  static const _phone = '+91 98765 43200';
  static const _initial = 'V';
  static const _rating = '4.8';
  static const _totalDeliveries = '1247';
  static const _memberSince = 'January 2026';
  static const _vehicleType = 'Two Wheeler';
  static const _vehicleNumber = 'TS 09 XX 1234';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _headerStrip(context),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _summaryCard(),
                      const SizedBox(height: 12),
                      _statsRow(),
                      const SizedBox(height: 12),
                      _infoSection(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Details',
                        children: [
                          _infoRow('Name', _name),
                          _infoRow('Phone', _phone),
                          _infoRow('Rating', _rating, trailingStar: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoSection(
                        icon: Icons.two_wheeler_outlined,
                        title: 'Vehicle Details',
                        children: [
                          _infoRow('Vehicle Type', _vehicleType),
                          _infoRow('Vehicle Number', _vehicleNumber),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _documentsCard(context),
                      const SizedBox(height: 20),
                      _logoutButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerStrip(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.profileHeaderStart,
            AppColors.profileHeaderEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage your account',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.2),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.profileAvatarBg,
                child: Text(
                  _initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      _name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      _phone,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.profileDocVerifiedBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ACTIVE PARTNER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.profileDocVerifiedText,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.profileRatingChip,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _rating,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statBlock(
            bg: const BoxDecoration(
              color: AppColors.profileStatNavy,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            icon: Icons.inventory_2_outlined,
            value: _totalDeliveries,
            label: 'Total Deliveries',
            valueStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statBlock(
            bg: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.profileHeaderStart,
                  AppColors.profileStatGradEnd,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            icon: Icons.calendar_today_outlined,
            value: _memberSince,
            label: 'Member Since',
            isMonthText: true,
            valueStyle: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBlock({
    required Decoration bg,
    required IconData icon,
    required String value,
    required String label,
    required TextStyle valueStyle,
    bool isMonthText = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 22),
          const SizedBox(height: 10),
          if (isMonthText)
            Text(
              value,
              style: valueStyle,
              maxLines: 2,
            )
          else
            Text(value, style: valueStyle),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.slate700),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool trailingStar = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.slate500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailingStar) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.profileRatingChip,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentsCard(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shadowColor: const Color(0x0F0F172A),
      child: InkWell(
        onTap: () => context.push(AppRoutes.documents),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 20,
                color: AppColors.slate700,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Documents',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.profileDocVerifiedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.profileDocVerifiedText,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: AppColors.slate400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<DeliveryAppState>().signOut();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.cardSurface,
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
