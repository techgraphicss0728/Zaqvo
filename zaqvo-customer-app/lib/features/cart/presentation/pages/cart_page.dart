import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/domain/models/cart_item.dart';
import 'package:zaqvo_customer_app/shared/widgets/empty_state.dart';
import 'package:zaqvo_customer_app/state/cart_controller.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class CartPage extends riverpod.ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final appState = context.watch<AppState>();
    final cartState = ref.watch(cartControllerProvider);
    final items = _buildCartItems(appState, cartState.quantities);
    const deliveryFee = 10.0;
    final subtotal = items.fold<double>(0, (a, b) => a + b.lineTotal);
    final total = items.isEmpty ? 0.0 : subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('My Cart')),
      body: WaterRefreshWrapper(
        onRefresh: appState.refreshData,
        child: Skeletonizer(
          enabled: appState.isBusy,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 150),
            children: [
              if (items.isEmpty)
                const SizedBox(
                  height: 420,
                  child: EmptyState(
                    title: 'Your cart is empty',
                    subtitle: 'Add water products to continue.',
                  ),
                )
              else ...[
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CartItemCard(
                        name: item.product.name,
                        price: item.product.price,
                        quantity: item.quantity,
                        onMinus: () => ref.read(cartControllerProvider.notifier).update(
                          item.product.id,
                          item.quantity - 1,
                        ),
                        onPlus: () => ref.read(cartControllerProvider.notifier).update(
                          item.product.id,
                          item.quantity + 1,
                        ),
                        onDelete: () => ref
                            .read(cartControllerProvider.notifier)
                            .remove(item.product.id),
                      ),
                    )),
                const _AddressCard(),
                const SizedBox(height: 12),
                const _PaymentMethodsCard(),
                const SizedBox(height: 12),
                _BillCard(subtotal: subtotal, deliveryFee: deliveryFee),
              ],
            ],
          ),
        ),
      ),
      bottomSheet: items.isEmpty
          ? null
          : Container(
              color: AppColors.backgroundLight,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B9BD6), Color(0xFF43C9EF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed successfully')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Place Order ₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28 / 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.name,
    required this.price,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    required this.onDelete,
  });

  final String name;
  final double price;
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFEFF8FC),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18 / 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF1F8BC8),
                      fontWeight: FontWeight.w800,
                      fontSize: 38 / 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: onMinus),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _QtyButton(icon: Icons.add, onTap: onPlus),
                      const SizedBox(width: 8),
                      Text('x ₹${price.toStringAsFixed(0)} each'),
                    ],
                  ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.catalog),
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text(
                  'Add Items',
                  style: TextStyle(fontWeight: FontWeight.w700),
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFFE9EEF2),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const ListTile(
        leading: Icon(Icons.location_on_outlined, color: AppColors.skyBlue),
        title: Text(
          'Delivery Address',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('2-99 , Yusafguda, near Basti Dawakhana ,505544'),
      ),
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  const _PaymentMethodsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18 / 1.2),
            ),
            const SizedBox(height: 10),
            _paymentOption(
              label: 'Cash on Delivery',
              icon: Icons.payments_outlined,
              selected: true,
            ),
            const SizedBox(height: 8),
            _paymentOption(label: 'UPI Payments', icon: Icons.account_balance),
            const SizedBox(height: 8),
            _paymentOption(
              label: 'Credit/Debit Card',
              icon: Icons.credit_card_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption({
    required String label,
    required IconData icon,
    bool selected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.skyBlue : const Color(0xFFE3EBF1),
          width: selected ? 1.8 : 1,
        ),
        color: selected ? const Color(0xFFEEF9FF) : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? AppColors.skyBlue : Colors.black54),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.skyBlue : const Color(0xFF394754),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.subtotal, required this.deliveryFee});

  final double subtotal;
  final double deliveryFee;

  @override
  Widget build(BuildContext context) {
    final total = subtotal + deliveryFee;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _amountRow('Subtotal', subtotal),
            const SizedBox(height: 6),
            _amountRow('Delivery Fee', deliveryFee),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Add ₹80 more for free delivery!',
                style: TextStyle(
                  color: Color(0xFF4D87AA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _amountRow('Total', total, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String label, double value, {bool bold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: bold ? const Color(0xFF1F8BC8) : null,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 34 / 1.4 : 16,
          ),
        ),
      ],
    );
  }
}
