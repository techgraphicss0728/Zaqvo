import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/domain/models/cart_item.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';
import 'package:zaqvo_customer_app/state/cart_controller.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class HomePage extends riverpod.ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final appState = context.watch<AppState>();
    final quickOrderProducts = appState.popularProducts.take(2).toList();
    final cartState = ref.watch(cartControllerProvider);
    final cartItems = _buildCartItems(appState, cartState.quantities);
    final cartItemCount = cartState.itemCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: cartItemCount == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _CartPreviewSheet(items: cartItems),
              ),
              backgroundColor: const Color(0xFF2A9CD5),
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(
                'Cart ($cartItemCount)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
      body: WaterRefreshWrapper(
        onRefresh: appState.refreshData,
        child: Skeletonizer(
          enabled: appState.isBusy,
          // Default is true; while loading it blocks all gestures (InkWell taps).
          ignorePointers: false,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _TopHeader(
                userName: appState.currentUser?.name ?? 'Customer',
                deliverLine: appState.deliveryDisplayLine,
                onProfileTap: () => context.go('${AppRoutes.home}/profile'),
                onDeliverTap: () =>
                    context.go('${AppRoutes.home}/saved-addresses'),
              ),
              const SizedBox(height: 14),
              const _SectionTitle(title: 'Quick Order'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      Expanded(
                        child: _QuickOrderCard(
                          product: i < quickOrderProducts.length
                              ? quickOrderProducts[i]
                              : null,
                          onTap: () {
                            final product = i < quickOrderProducts.length
                                ? quickOrderProducts[i]
                                : null;
                            if (product == null) return;
                            context.go('${AppRoutes.home}/product/${product.id}');
                          },
                        ),
                      ),
                      if (i == 0) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: _SubscriptionCard(),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: _ActionGrid(),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: _TodayOfferCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<CartItem> _buildCartItems(
  AppState appState,
  Map<String, int> quantities,
) {
  final items = <CartItem>[];
  for (final entry in quantities.entries) {
    final product = appState.getProductById(entry.key);
    if (product != null && entry.value > 0) {
      items.add(CartItem(product: product, quantity: entry.value));
    }
  }
  return items;
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.userName,
    required this.deliverLine,
    required this.onProfileTap,
    required this.onDeliverTap,
  });

  final String userName;
  final String deliverLine;
  final VoidCallback onProfileTap;
  final VoidCallback onDeliverTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E6EA8), Color(0xFF2EADE4)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Evening',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 34 / 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay hydrated , stay healthy',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDeliverTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivering to',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              deliverLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20 / 1.2,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B1E21),
        ),
      ),
    );
  }
}

class _QuickOrderCard extends StatelessWidget {
  const _QuickOrderCard({required this.product, required this.onTap});

  final Product? product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemName = product?.name ?? '20L Water Can';
    final itemPrice = product?.price.toStringAsFixed(0) ?? '30';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2A88C8),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF9AE2FC), Color(0xFF5EC5F1)],
                ),
              ),
              child: Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  child: const Icon(
                    Icons.local_drink_rounded,
                    color: Color(0xFF2D87C6),
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              itemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3C4753),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              '₹$itemPrice',
              style: const TextStyle(
                color: Color(0xFF2A88C8),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34AFE4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B9CD6), Color(0xFF23B7E6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Water Subscription',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Never run out of Water again',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _PlanChip(label: 'Daily')),
              SizedBox(width: 8),
              Expanded(child: _PlanChip(label: 'Alternate')),
              SizedBox(width: 8),
              Expanded(child: _PlanChip(label: 'Weekly')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4A677A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Subscription',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.38),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.calendar_month_outlined, 'Schedule'),
      (Icons.replay_rounded, 'Repeat Oder'),
      (Icons.local_offer_outlined, 'offers'),
      (Icons.pin_drop_outlined, 'Track Oder'),
      (Icons.credit_card_outlined, 'Payments'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 14 - 14 - 20) / 3,
            child: _ActionCard(
              icon: item.$1,
              label: item.$2,
              onTap: item.$2 == 'Schedule'
                  ? () => context.go('${AppRoutes.home}/schedule')
                  : () {},
            ),
          ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFEFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x142A88C8),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.skyBlue, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2D3640),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayOfferCard extends StatelessWidget {
  const _TodayOfferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B9BD6), Color(0xFF79D8F8)],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Offer",
                  style: TextStyle(
                    color: Color(0xFF0E4363),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get 10% OFF on first order',
                  style: TextStyle(
                    color: Color(0xFF0E2B43),
                    fontWeight: FontWeight.w700,
                    fontSize: 24 / 1.4,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.65),
              foregroundColor: const Color(0xFF3B5D73),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              elevation: 0,
            ),
            child: const Text(
              'Claim',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartPreviewSheet extends StatelessWidget {
  const _CartPreviewSheet({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cart Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F7FF),
                      child: Icon(Icons.water_drop_outlined),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text('${item.quantity} can'),
                    trailing: Text(
                      '₹${item.lineTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '₹${items.fold<double>(0, (a, b) => a + b.lineTotal).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF1F8BC8),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.cart);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9CD5),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
