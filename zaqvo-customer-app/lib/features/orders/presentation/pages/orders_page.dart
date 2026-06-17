import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/domain/models/customer_order.dart';
import 'package:zaqvo_customer_app/shared/widgets/empty_state.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            onPressed: () => context.go('${AppRoutes.home}/profile'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
      body: WaterRefreshWrapper(
        onRefresh: appState.refreshData,
        child: Skeletonizer(
          enabled: appState.isBusy,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              if (appState.orders.isEmpty) {
                return const SizedBox(
                  height: 420,
                  child: EmptyState(
                    title: 'No orders yet',
                    subtitle: 'Orders you place will appear here.',
                  ),
                );
              }
              final order = appState.orders[index];
              return _OrderCard(
                order: order,
                onTap: () {
                  String? productId = order.productId;
                  if (productId == null) {
                    for (final product in appState.products) {
                      if (product.name == order.productName) {
                        productId = product.id;
                        break;
                      }
                    }
                  }
                  if (productId == null) return;
                  context.go('${AppRoutes.orders}/product/$productId');
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: appState.orders.isEmpty ? 1 : appState.orders.length,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final CustomerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd MMM, hh:mm a').format(order.placedAt);
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(order.productName),
        subtitle: Text('Order #${order.id}\n$dateLabel'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₹${order.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            Text(
              order.status.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
