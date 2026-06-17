import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_delivery_app/core/router/app_routes.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';

/// Partner home — matches ZAQVO Partner Figma (status card, stats, active order, quick actions).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: 16),
              _heroCard(),
              const SizedBox(height: 20),
              _sectionTitle('🚚 Today\'s Deliveries'),
              const SizedBox(height: 12),
              _statsRow(),
              const SizedBox(height: 14),
              _viewAllButton(),
              const SizedBox(height: 22),
              _sectionTitle('📦 Active Delivery'),
              const SizedBox(height: 10),
              _activeDeliveryCard(),
              const SizedBox(height: 22),
              _sectionTitle('⚡ Quick Actions'),
              const SizedBox(height: 12),
              _quickActionsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go(AppRoutes.profile),
            borderRadius: BorderRadius.circular(32),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.border,
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: AppColors.slate500,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ZAQVO Partner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications')),
            );
          },
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.slate700,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.heroGradientStart,
            AppColors.heroGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                      'Hello, Venu 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ready to deliver today?',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _onlineToggle(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.earningsPill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Today\'s Earnings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.trending_up, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  '₹850',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _onlineToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Online',
            style: TextStyle(
              color: AppColors.slate700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 22,
            child: FittedBox(
              child: Switch.adaptive(
                value: _isOnline,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeTrackColor: const Color(0xFF22C55E),
                onChanged: (v) {
                  setState(() => _isOnline = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statPill('10', 'Total', AppColors.statTotalBg, null),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statPill('5', 'Completed', AppColors.successLight, AppColors.successStrong),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statPill('4', 'Pending', AppColors.warningLight, AppColors.warningStrong),
        ),
      ],
    );
  }

  Widget _statPill(
    String value,
    String label,
    Color bg,
    Color? valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.slate700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewAllButton() {
    return Material(
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [
                AppColors.skyBlue,
                AppColors.navActive,
              ],
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                'View All Orders →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeDeliveryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
            child: Row(
              children: [
                const Text(
                  '📦 Active Delivery',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inProgressTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inProgressTeal,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _infoRow('Order ID', '#ZAQ1234'),
                const SizedBox(height: 6),
                _infoRow('Customer', 'Ramesh Kumar'),
                const SizedBox(height: 6),
                _infoRow('Address', 'Kukatpally, Hyd'),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.slate500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '2.3 km',
                      style: TextStyle(
                        color: AppColors.slate700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: const BoxDecoration(
              color: AppColors.itemFooterBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Text('💧', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  '2 x 20L Water Cans',
                  style: TextStyle(
                    color: AppColors.slate700,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            k,
            style: const TextStyle(
              color: AppColors.slate500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(
              color: AppColors.slate700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _quickCard(
          'Start Delivery',
          AppColors.quickIconBg1,
          Icons.local_shipping_outlined,
          true,
        ),
        _quickCard(
          'View Earnings',
          AppColors.quickIconBg2,
          Icons.savings_outlined,
          true,
        ),
        _quickCard(
          'Order History',
          AppColors.quickIconBg3,
          Icons.history,
          true,
        ),
        _quickCard(
          'Support',
          AppColors.quickIconBg4,
          Icons.support_agent,
          false,
        ),
      ],
    );
  }

  Widget _quickCard(
    String label,
    Color iconBg,
    IconData icon,
    bool lightIcon,
  ) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: lightIcon
                      ? Colors.white
                      : AppColors.slate700,
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
