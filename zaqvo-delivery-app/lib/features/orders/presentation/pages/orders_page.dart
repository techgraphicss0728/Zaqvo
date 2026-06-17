import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_delivery_app/core/router/app_routes.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';
import 'package:zaqvo_delivery_app/features/orders/presentation/models/partner_order.dart';

/// Your Deliveries — Active / Completed tabs (Figma-matched).
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0; // 0 Active, 1 Completed

  @override
  Widget build(BuildContext context) {
    final activeList = kMockActiveOrders;
    final completedList = kMockCompletedOrders;
    return ColoredBox(
      color: AppColors.pageBackground,
      child: Column(
        children: [
          _DeliveriesHeader(
            activeCount: activeList.length,
            completedCount: completedList.length,
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: _tab == 0
                ? _ActiveOrdersList(orders: activeList)
                : _CompletedOrdersList(orders: completedList),
          ),
        ],
      ),
    );
  }
}

class _DeliveriesHeader extends StatelessWidget {
  const _DeliveriesHeader({
    required this.activeCount,
    required this.completedCount,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int activeCount;
  final int completedCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.paddingOf(context).top + 16,
            20,
            20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.ordersHeaderTop,
                AppColors.ordersHeaderBottom,
              ],
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Deliveries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage your delivery orders',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SegmentedTabs(
              activeCount: activeCount,
              completedCount: completedCount,
              selectedIndex: selectedIndex,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.activeCount,
    required this.completedCount,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int activeCount;
  final int completedCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(28),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _SegButton(
                label: 'Active Orders ($activeCount)',
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _SegButton(
                label: 'Completed ($completedCount)',
                selected: selectedIndex == 1,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  const _SegButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.textPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.tabPillUnselected,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveOrdersList extends StatelessWidget {
  const _ActiveOrdersList({required this.orders});

  final List<ActivePartnerOrder> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final o = orders[i];
        if (o.status == PartnerOrderStatus.pending) {
          return _PendingOrderCard(order: o);
        }
        return _ActiveTypeOrderCard(order: o);
      },
    );
  }
}

class _ActiveTypeOrderCard extends StatelessWidget {
  const _ActiveTypeOrderCard({required this.order});

  final ActivePartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orderCardActiveStroke, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orderBadgeActiveBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: AppColors.orderBadgeActiveText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${order.amount} ${order.isOnline ? "online" : "cash"}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.orderDetailIcon,
            ),
          ),
          const SizedBox(height: 12),
          _orderDetailGrid(order),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallOutline(
                  label: 'Navigate',
                  icon: Icons.near_me_outlined,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallOutline(
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orderDeliverGreen,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: const Text(
                    'Deliver',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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
}

class _PendingOrderCard extends StatelessWidget {
  const _PendingOrderCard({required this.order});

  final ActivePartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orderBadgePendingBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: AppColors.orderBadgePendingText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${order.amount} ${order.isOnline ? "online" : "cash"}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _orderDetailGrid(order),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orderAcceptButton,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Accept Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _orderDetailGrid(ActivePartnerOrder order) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _OrderIconLine(
              icon: Icons.location_on_outlined,
              text: order.area,
            ),
          ),
          Expanded(
            child: _OrderIconLine(
              icon: Icons.water_drop_outlined,
              text: order.itemsLabel,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _OrderIconLine(
              icon: Icons.near_me_outlined,
              text: '${order.distanceKm} km',
            ),
          ),
          Expanded(
            child: _OrderIconLine(
              icon: Icons.schedule_outlined,
              text: order.timeLabel,
            ),
          ),
        ],
      ),
    ],
  );
}

class _SmallOutline extends StatelessWidget {
  const _SmallOutline({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        side: const BorderSide(color: AppColors.orderOutlineTeal, width: 1.2),
        foregroundColor: AppColors.orderOutlineTeal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CompletedOrdersList extends StatelessWidget {
  const _CompletedOrdersList({required this.orders});

  final List<CompletedPartnerOrder> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _CompletedOrderCard(order: orders[i]),
    );
  }
}

class _CompletedOrderCard extends StatelessWidget {
  const _CompletedOrderCard({required this.order});

  final CompletedPartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  color: AppColors.slate700,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orderCompletedBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: AppColors.orderCompletedBadgeText,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${order.amount}',
                    style: const TextStyle(
                      color: AppColors.orderPriceGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    order.isOnline ? 'ONLINE' : 'CASH',
                    style: const TextStyle(
                      color: AppColors.orderPaymentSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _CompletedDetailGrid(order: order),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.push(AppRoutes.orderDetail(order.id));
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.orderOutlineTeal, width: 1.2),
                foregroundColor: AppColors.orderOutlineTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedDetailGrid extends StatelessWidget {
  const _CompletedDetailGrid({required this.order});

  final CompletedPartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OrderIconLine(
                icon: Icons.location_on_outlined,
                text: order.area,
              ),
            ),
            Expanded(
              child: _OrderIconLine(
                icon: Icons.water_drop_outlined,
                text: order.itemsLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _OrderIconLine(
                icon: Icons.route,
                text: '${order.distanceKm} km',
              ),
            ),
            Expanded(
              child: _OrderIconLine(
                icon: Icons.schedule_outlined,
                text: order.timeLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderIconLine extends StatelessWidget {
  const _OrderIconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.orderDetailIcon),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.slate700,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
