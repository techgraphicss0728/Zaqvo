import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;
import 'package:zaqvo_customer_app/core/errors/error_mapper.dart';
import 'package:zaqvo_customer_app/data/repositories/customer_repository.dart';
import 'package:zaqvo_customer_app/domain/models/app_user.dart';
import 'package:zaqvo_customer_app/domain/models/bootstrap_data.dart';
import 'package:zaqvo_customer_app/domain/models/cart_item.dart';
import 'package:zaqvo_customer_app/domain/models/category.dart' as app_category;
import 'package:zaqvo_customer_app/domain/models/customer_order.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';
import 'package:zaqvo_customer_app/domain/models/promo_banner.dart';
import 'package:zaqvo_customer_app/domain/models/saved_address.dart';
import 'package:zaqvo_customer_app/domain/models/scheduled_delivery.dart';

class AppState extends ChangeNotifier {
  AppState(this._repository);

  final CustomerRepository _repository;

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isBusy = false;
  String? _statusMessage;
  AppUser? _currentUser;
  List<app_category.Category> _categories = const [];
  List<Product> _products = const [];
  List<CustomerOrder> _orders = const [];
  List<PromoBanner> _banners = const [];
  List<ScheduledDelivery> _scheduledDeliveries = const [];
  List<SavedAddress> _savedAddresses = const [];
  final Set<String> _wishlistProductIds = <String>{};
  final Map<String, int> _cartQuantities = <String, int>{};

  bool get isInitialized => _isInitialized;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _currentUser != null;
  String? get statusMessage => _statusMessage;
  AppUser? get currentUser => _currentUser;
  List<app_category.Category> get categories => _categories;
  List<Product> get products => _products;
  List<CustomerOrder> get orders => _orders;
  List<PromoBanner> get banners => _banners;
  List<ScheduledDelivery> get scheduledDeliveries => _scheduledDeliveries;
  List<SavedAddress> get savedAddresses =>
      List<SavedAddress>.unmodifiable(_savedAddresses);
  Set<String> get wishlistProductIds => _wishlistProductIds;

  SavedAddress? get deliveryAddress {
    if (_savedAddresses.isEmpty) return null;
    for (final a in _savedAddresses) {
      if (a.isDefault) return a;
    }
    return _savedAddresses.first;
  }

  String get deliveryDisplayLine {
    final addr = deliveryAddress;
    if (addr == null) return 'Add delivery address';
    final short = addr.addressLine.split(',').first.trim();
    return '${addr.title}- $short';
  }
  Map<String, int> get cartQuantities => Map.unmodifiable(_cartQuantities);

  List<Product> get popularProducts =>
      _products.where((product) => product.isPopular).toList();

  List<CartItem> get cartItems {
    final items = <CartItem>[];
    _cartQuantities.forEach((productId, quantity) {
      final product = getProductById(productId);
      if (product != null && quantity > 0) {
        items.add(CartItem(product: product, quantity: quantity));
      }
    });
    return items;
  }

  int get cartItemCount => _cartQuantities.values.fold(0, (a, b) => a + b);

  double get cartSubtotal =>
      cartItems.fold(0, (total, item) => total + item.lineTotal);

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    await _runBusyAction(() async {
      final results = await Future.wait([
        _repository.loadBootstrapData(),
        Future<void>.delayed(const Duration(milliseconds: 2100)),
      ]);
      final data = results.first as BootstrapData;
      _categories = data.categories;
      _products = data.products;
      _orders = data.orders;
      _banners = data.banners;
      if (_scheduledDeliveries.isEmpty) {
        _scheduledDeliveries = [
          ScheduledDelivery(
            id: 'sd1',
            productId: 'p1',
            scheduledDate: DateTime.now().add(const Duration(days: 1)),
            timeSlotLabel: '8 AM - 12 PM',
            quantity: 2,
          ),
          ScheduledDelivery(
            id: 'sd2',
            productId: 'p2',
            scheduledDate: DateTime.now().add(const Duration(days: 2)),
            timeSlotLabel: '8 AM - 12 PM',
            quantity: 2,
          ),
        ];
      }
      if (_savedAddresses.isEmpty) {
        _savedAddresses = [
          const SavedAddress(
            id: 'addr_home',
            label: SavedAddressLabel.home,
            addressLine: 'Yusafguda, yadagiringar 500045',
            latitude: 17.4543,
            longitude: 78.3868,
            isDefault: true,
          ),
          const SavedAddress(
            id: 'addr_office',
            label: SavedAddressLabel.office,
            addressLine: 'Oceanic Trade Tower, Level 18, Suite 201',
            latitude: 17.4319,
            longitude: 78.4076,
            isDefault: false,
          ),
        ];
      }
      _isInitialized = true;
    });
    _isInitializing = false;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    var success = false;
    await _runBusyAction(() async {
      _currentUser = await _repository.signIn(email: email, password: password);
      success = true;
    });
    return success;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _runBusyAction(() async {
      final data = await _repository.loadBootstrapData();
      _categories = data.categories;
      _products = data.products;
      _orders = data.orders;
      _banners = data.banners;
    });
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
  }) async {
    if (_currentUser == null) return;
    await _runBusyAction(() async {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );
    });
  }

  Product? getProductById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void toggleWishlist(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    notifyListeners();
  }

  bool isWishlisted(String productId) =>
      _wishlistProductIds.contains(productId);

  void addToCart(String productId, {int quantity = 1}) {
    if (quantity <= 0) return;
    final current = _cartQuantities[productId] ?? 0;
    _cartQuantities[productId] = current + quantity;
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _cartQuantities.remove(productId);
    } else {
      _cartQuantities[productId] = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartQuantities.remove(productId);
    notifyListeners();
  }

  void addSavedAddress(SavedAddress address) {
    final cleared = address.isDefault
        ? _savedAddresses.map((a) => a.copyWith(isDefault: false)).toList()
        : List<SavedAddress>.from(_savedAddresses);
    _savedAddresses = [...cleared, address];
    notifyListeners();
  }

  void removeSavedAddress(String id) {
    final remaining = _savedAddresses.where((a) => a.id != id).toList();
    if (remaining.isEmpty) {
      _savedAddresses = [];
      notifyListeners();
      return;
    }
    if (!remaining.any((a) => a.isDefault)) {
      _savedAddresses = [
        for (var i = 0; i < remaining.length; i++)
          remaining[i].copyWith(isDefault: i == 0),
      ];
    } else {
      _savedAddresses = remaining;
    }
    notifyListeners();
  }

  void setDefaultSavedAddress(String id) {
    _savedAddresses = [
      for (final a in _savedAddresses) a.copyWith(isDefault: a.id == id),
    ];
    notifyListeners();
  }

  void updateSavedAddress(SavedAddress updated) {
    _savedAddresses = [
      for (final a in _savedAddresses)
        if (a.id == updated.id)
          updated
        else
          updated.isDefault ? a.copyWith(isDefault: false) : a,
    ];
    notifyListeners();
  }

  void scheduleDelivery({
    required String productId,
    required DateTime scheduledDate,
    required String timeSlotLabel,
    required int quantity,
  }) {
    final next = List<ScheduledDelivery>.from(_scheduledDeliveries)
      ..insert(
        0,
        ScheduledDelivery(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          productId: productId,
          scheduledDate: scheduledDate,
          timeSlotLabel: timeSlotLabel,
          quantity: quantity,
        ),
      );
    _scheduledDeliveries = next;
    notifyListeners();
  }

  void clearStatusMessage() {
    _statusMessage = null;
    notifyListeners();
  }

  Future<void> _runBusyAction(Future<void> Function() action) async {
    _isBusy = true;
    _statusMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('AppState error: $error\n$stackTrace');
      _statusMessage = ErrorMapper.toUserMessage(error);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
