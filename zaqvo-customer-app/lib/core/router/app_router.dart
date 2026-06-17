import 'package:go_router/go_router.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:zaqvo_customer_app/features/cart/presentation/pages/cart_page.dart';
import 'package:zaqvo_customer_app/features/home/presentation/pages/home_page.dart';
import 'package:zaqvo_customer_app/features/auth/presentation/pages/login_page.dart';
import 'package:zaqvo_customer_app/features/auth/presentation/pages/otp_page.dart';
import 'package:zaqvo_customer_app/features/orders/presentation/pages/orders_page.dart';
import 'package:zaqvo_customer_app/features/product/presentation/pages/product_details_page.dart';
import 'package:zaqvo_customer_app/features/profile/presentation/pages/profile_hub_page.dart';
import 'package:zaqvo_customer_app/features/profile/presentation/pages/profile_page.dart';
import 'package:zaqvo_customer_app/features/addresses/presentation/map_picker_args.dart';
import 'package:zaqvo_customer_app/features/addresses/presentation/pages/map_address_picker_page.dart';
import 'package:zaqvo_customer_app/features/addresses/presentation/pages/saved_addresses_page.dart';
import 'package:zaqvo_customer_app/features/help/presentation/pages/help_support_page.dart';
import 'package:zaqvo_customer_app/features/payments/presentation/pages/payment_methods_page.dart';
import 'package:zaqvo_customer_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:zaqvo_customer_app/features/schedule/presentation/pages/schedule_page.dart';
import 'package:zaqvo_customer_app/features/shell/presentation/pages/main_shell_page.dart';
import 'package:zaqvo_customer_app/features/splash/presentation/pages/splash_page.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

GoRouter createAppRouter(AppState appState) => GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: appState,
      redirect: (context, state) {
        final location = state.uri.toString();
        final isPublicRoute = location == AppRoutes.login ||
            location == AppRoutes.splash ||
            location.startsWith(AppRoutes.otp);

        if (!appState.isInitialized && location != AppRoutes.splash) {
          return AppRoutes.splash;
        }

        if (appState.isInitialized &&
            !appState.isAuthenticated &&
            !isPublicRoute) {
          return AppRoutes.login;
        }

        if (appState.isAuthenticated && isPublicRoute) {
          return AppRoutes.home;
        }

        if (appState.isInitialized &&
            !appState.isAuthenticated &&
            location == AppRoutes.splash) {
          return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (context, state) =>
              OtpPage(mobile: state.uri.queryParameters['mobile'] ?? ''),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShellPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                  routes: [
                    GoRoute(
                      path: 'product/:id',
                      builder: (context, state) {
                        final productId = state.pathParameters['id'] ?? '';
                        return ProductDetailsPage(productId: productId);
                      },
                    ),
                    GoRoute(
                      path: 'profile',
                      builder: (context, state) => const ProfileHubPage(),
                      routes: [
                        GoRoute(
                          path: 'personal-details',
                          builder: (context, state) => const ProfilePage(),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'schedule',
                      builder: (context, state) => const SchedulePage(),
                    ),
                    GoRoute(
                      path: 'saved-addresses',
                      builder: (context, state) => const SavedAddressesPage(),
                    ),
                    GoRoute(
                      path: 'notifications',
                      builder: (context, state) => const NotificationsPage(),
                    ),
                    GoRoute(
                      path: 'help-support',
                      builder: (context, state) => const HelpSupportPage(),
                    ),
                    GoRoute(
                      path: 'payment-methods',
                      builder: (context, state) => const PaymentMethodsPage(),
                    ),
                    GoRoute(
                      path: 'pick-location',
                      builder: (context, state) {
                        final args = state.extra as MapPickerArgs?;
                        return MapAddressPickerPage(
                          args: args ?? const MapPickerArgs(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.catalog,
                  builder: (context, state) => const CatalogPage(),
                  routes: [
                    GoRoute(
                      path: 'product/:id',
                      builder: (context, state) {
                        final productId = state.pathParameters['id'] ?? '';
                        return ProductDetailsPage(productId: productId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.orders,
                  builder: (context, state) => const OrdersPage(),
                  routes: [
                    GoRoute(
                      path: 'product/:id',
                      builder: (context, state) {
                        final productId = state.pathParameters['id'] ?? '';
                        return ProductDetailsPage(productId: productId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.cart,
                  builder: (context, state) => const CartPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
