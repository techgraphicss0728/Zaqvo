import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';
import 'package:zaqvo_customer_app/shared/widgets/empty_state.dart';
import 'package:zaqvo_customer_app/state/cart_controller.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class CatalogPage extends riverpod.ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  riverpod.ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends riverpod.ConsumerState<CatalogPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final waterProducts = appState.products.where((product) {
      final haystack =
          '${product.name} ${product.shortDescription} ${product.categoryId}'
              .toLowerCase();
      return haystack.contains('water') ||
          haystack.contains('liter') ||
          haystack.contains('litre') ||
          haystack.contains('can');
    }).toList();

    final source = waterProducts.isEmpty ? appState.products : waterProducts;
    final filtered = source.where((product) {
      final value = _query.trim().toLowerCase();
      if (value.isEmpty) return true;
      return product.name.toLowerCase().contains(value) ||
          product.shortDescription.toLowerCase().contains(value);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Products'),
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
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search water products',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                const SizedBox(
                  height: 420,
                  child: EmptyState(
                    title: 'No matching results',
                    subtitle: 'Try searching with another keyword.',
                  ),
                )
              else
                ...List.generate(filtered.length, (index) {
                  final item = filtered[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == filtered.length - 1 ? 0 : 8,
                    ),
                    child: _CatalogTile(
                      product: item,
                      onAdd: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .add(item.id, quantity: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart'),
                          ),
                        );
                      },
                      onTap: () =>
                          context.go('${AppRoutes.catalog}/product/${item.id}'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF9AE2FC), Color(0xFF5EC5F1)],
                ),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF233141),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5D6A78),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF1F8BC8),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2FADE3),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
