import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';

/// Notification preferences and recent activity (opens from Profile → Notifications).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _orderUpdates = true;
  bool _deliveryAlerts = true;
  bool _offersPromos = false;
  bool _subscriptionReminders = true;

  late List<_ActivityItem> _recent;

  @override
  void initState() {
    super.initState();
    _recent = [
      const _ActivityItem(
        title: 'Order Delivered!',
        body: 'Your order has been delivered successfully.',
        timeLabel: 'JUST NOW',
        leading: _LeadingStyle.check,
        unread: true,
      ),
      const _ActivityItem(
        title: 'Flash Sale Alert 🔥',
        body: 'Limited time offers on your favourite products.',
        timeLabel: '2H AGO',
        leading: _LeadingStyle.tag,
        unread: true,
      ),
      const _ActivityItem(
        title: 'Payment Successful',
        body: 'Your payment was processed.',
        timeLabel: 'YESTERDAY',
        leading: _LeadingStyle.wallet,
        unread: false,
      ),
      const _ActivityItem(
        title: 'Security Update',
        body: 'We updated our security policies.',
        timeLabel: 'YESTERDAY',
        leading: _LeadingStyle.security,
        unread: false,
      ),
    ];
  }

  void _clearAll() {
    setState(() {
      for (var i = 0; i < _recent.length; i++) {
        _recent[i] = _recent[i].copyWith(unread: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF3F6F9);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NotificationsHeader(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            onClearAll: _clearAll,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                const _SectionLabel('SETTINGS'),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'Order Updates',
                      subtitle: 'Status changes for your orders',
                      value: _orderUpdates,
                      onChanged: (v) => setState(() => _orderUpdates = v),
                    ),
                    _SettingsTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Delivery Alerts',
                      subtitle: 'Driver and ETA notifications',
                      value: _deliveryAlerts,
                      onChanged: (v) => setState(() => _deliveryAlerts = v),
                    ),
                    _SettingsTile(
                      icon: Icons.local_offer_outlined,
                      title: 'Offers & Promos',
                      subtitle: 'Deals and promotional messages',
                      value: _offersPromos,
                      onChanged: (v) => setState(() => _offersPromos = v),
                    ),
                    _SettingsTile(
                      icon: Icons.event_repeat_rounded,
                      title: 'Subscription Reminders',
                      subtitle: 'Upcoming deliveries and renewals',
                      value: _subscriptionReminders,
                      onChanged: (v) =>
                          setState(() => _subscriptionReminders = v),
                      showDividerBelow: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('RECENT ACTIVITY'),
                const SizedBox(height: 10),
                ..._recent.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityCard(item: e),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: Color(0xFF9CA8B5),
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.onBack,
    required this.onClearAll,
  });

  final VoidCallback onBack;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A9FD9), Color(0xFF36B8E8), AppColors.skyBlue],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 18),
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: onClearAll,
                //   style: TextButton.styleFrom(
                //     foregroundColor: Colors.white.withValues(alpha: 0.92),
                //     padding: const EdgeInsets.symmetric(horizontal: 8),
                //     minimumSize: Size.zero,
                //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //   ),
                //   child: const Text(
                //     'Clear all',
                //     style: TextStyle(
                //       fontWeight: FontWeight.w700,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDividerBelow = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDividerBelow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1565C0), size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF203447),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.skyBlue,
                activeTrackColor: AppColors.skyBlue.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
        if (showDividerBelow)
          Divider(
            height: 1,
            thickness: 1,
            indent: 52,
            color: AppColors.border.withValues(alpha: 0.85),
          ),
      ],
    );
  }
}

enum _LeadingStyle { check, tag, wallet, security }

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.leading,
    required this.unread,
  });

  final String title;
  final String body;
  final String timeLabel;
  final _LeadingStyle leading;
  final bool unread;

  _ActivityItem copyWith({bool? unread}) {
    return _ActivityItem(
      title: title,
      body: body,
      timeLabel: timeLabel,
      leading: leading,
      unread: unread ?? this.unread,
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final muted = item.leading == _LeadingStyle.wallet ||
        item.leading == _LeadingStyle.security;

    Widget leading;
    switch (item.leading) {
      case _LeadingStyle.check:
        leading = Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF36C2F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
        );
        break;
      case _LeadingStyle.tag:
        leading = Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF36C2F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_offer_rounded,
              color: Colors.white, size: 22),
        );
        break;
      case _LeadingStyle.wallet:
        leading = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              color: Color(0xFF64748B), size: 22),
        );
        break;
      case _LeadingStyle.security:
        leading = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: Color(0xFF64748B), size: 22),
        );
        break;
    }

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: muted
                                ? const Color(0xFF64748B)
                                : const Color(0xFF203447),
                          ),
                        ),
                      ),
                      if (item.unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.skyBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.timeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: muted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF36C2F0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
