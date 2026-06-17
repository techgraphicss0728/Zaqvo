import 'package:flutter/material.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';

/// Global bottom bar for the partner app: 5 tabs, uppercase labels.
class PartnerBottomNavBar extends StatelessWidget {
  const PartnerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const specs = <_NavSpec>[
      _NavSpec(Icons.home_outlined, 'HOME'),
      _NavSpec(Icons.inventory_2_outlined, 'ORDERS'),
      _NavSpec(Icons.calendar_today_outlined, 'SCHEDULE'),
      _NavSpec(Icons.payments_outlined, 'EARNINGS'),
      _NavSpec(Icons.person_outline, 'PROFILE'),
    ];

    return Material(
      elevation: 10,
      shadowColor: Colors.black26,
      color: AppColors.cardSurface,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
            child: Row(
              children: List.generate(specs.length, (i) {
                final s = specs[i];
                final active = i == currentIndex;
                return Expanded(
                  child: _NavItem(
                    spec: s,
                    active: active,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.active,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.navActive : AppColors.navInactive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
