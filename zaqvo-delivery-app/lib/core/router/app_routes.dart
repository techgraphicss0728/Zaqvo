class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';

  static const home = '/app/home';
  static const orders = '/app/orders';
  static const schedule = '/app/schedule';
  static const earnings = '/app/earnings';
  static const profile = '/app/profile';
  static const documents = '/app/profile/documents';

  static String orderDetail(String orderId) => '$orders/detail/$orderId';
}
