import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/shared/widgets/error_view.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';
import 'package:zaqvo_customer_app/state/cart_controller.dart';

class ProductDetailsPage extends riverpod.ConsumerWidget {
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final appState = context.watch<AppState>();
    final product = appState.getProductById(productId);

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Product details')),
        body: ErrorView(
          message: 'The requested service is not available right now.',
          onRetry: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Product Details'),
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 180),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF2FC),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BAF0), Color(0xFF3788DD)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 40 / 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.shortDescription,
                      style: const TextStyle(
                        color: Color(0xFF5C6670),
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF1F8BC8),
                              fontWeight: FontWeight.w800,
                              fontSize: 42 / 1.4,
                            ),
                          ),
                          const TextSpan(
                            text: ' per can',
                            style: TextStyle(
                              color: Color(0xFF5C6670),
                              fontWeight: FontWeight.w600,
                              fontSize: 20 / 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Features',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 28 / 1.4,
                            ),
                          ),
                          SizedBox(height: 10),
                          _FeatureLine(
                            icon: Icons.opacity_outlined,
                            title: '7-Stage Purification',
                            subtitle: 'RO + UV + TDS controlled',
                          ),
                          SizedBox(height: 8),
                          _FeatureLine(
                            icon: Icons.check_rounded,
                            title: 'Lab Tested',
                            subtitle: 'ISO Certified water quality',
                          ),
                          SizedBox(height: 8),
                          _FeatureLine(
                            icon: Icons.local_shipping_outlined,
                            title: 'Same Day Delivery',
                            subtitle: 'Order before 6 PM',
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
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Color(0xFF5C6670),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '1 can',
                    style: TextStyle(
                      color: Color(0xFF5C6670),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 40 / 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B9BD6), Color(0xFF43C9EF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(cartControllerProvider.notifier).add(product.id);
                      context.go(AppRoutes.cart);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 28 / 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFD6EBF7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2D87C6), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18 / 1.2,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF5C6670),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
