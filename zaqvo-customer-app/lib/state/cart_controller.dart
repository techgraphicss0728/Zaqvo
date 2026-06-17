import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:zaqvo_customer_app/core/storage/hive_boxes.dart';

class CartState {
  const CartState({required this.quantities});

  final Map<String, int> quantities;

  int get itemCount => quantities.values.fold(0, (a, b) => a + b);
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    final box = Hive.box<dynamic>(HiveBoxes.cart);
    final raw = box.toMap().map(
      (key, value) => MapEntry(
        key.toString(),
        value is int ? value : int.tryParse(value.toString()) ?? 0,
      ),
    );
    raw.removeWhere((key, value) => value <= 0);
    return CartState(quantities: raw);
  }

  Future<void> _persist() async {
    final box = Hive.box<dynamic>(HiveBoxes.cart);
    await box.clear();
    for (final entry in state.quantities.entries) {
      await box.put(entry.key, entry.value);
    }
  }

  Future<void> add(String productId, {int quantity = 1}) async {
    if (quantity <= 0) return;
    final next = Map<String, int>.from(state.quantities);
    next[productId] = (next[productId] ?? 0) + quantity;
    state = CartState(quantities: next);
    await _persist();
  }

  Future<void> update(String productId, int quantity) async {
    final next = Map<String, int>.from(state.quantities);
    if (quantity <= 0) {
      next.remove(productId);
    } else {
      next[productId] = quantity;
    }
    state = CartState(quantities: next);
    await _persist();
  }

  Future<void> remove(String productId) async {
    final next = Map<String, int>.from(state.quantities);
    next.remove(productId);
    state = CartState(quantities: next);
    await _persist();
  }
}

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(() {
  return CartController();
});
