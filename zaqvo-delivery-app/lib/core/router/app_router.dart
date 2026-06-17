import 'package:go_router/go_router.dart';
import 'package:zaqvo_delivery_app/core/router/app_routes.dart';
import 'package:zaqvo_delivery_app/core/router/route_fallback_page.dart';
import 'package:zaqvo_delivery_app/features/auth/presentation/pages/login_page.dart';
import 'package:zaqvo_delivery_app/features/auth/presentation/pages/otp_page.dart';
import 'package:zaqvo_delivery_app/features/earnings/presentation/pages/earnings_page.dart';
import 'package:zaqvo_delivery_app/features/home/presentation/pages/home_page.dart';
import 'package:zaqvo_delivery_app/features/orders/presentation/pages/completed_order_details_page.dart';
import 'package:zaqvo_delivery_app/features/orders/presentation/pages/orders_page.dart';
import 'package:zaqvo_delivery_app/features/profile/presentation/pages/documents_page.dart';
import 'package:zaqvo_delivery_app/features/profile/presentation/pages/profile_page.dart';
import 'package:zaqvo_delivery_app/features/schedule/presentation/pages/schedule_page.dart';
import 'package:zaqvo_delivery_app/features/shell/presentation/pages/partner_shell_page.dart';
import 'package:zaqvo_delivery_app/features/splash/presentation/pages/splash_page.dart';
import 'package:zaqvo_delivery_app/state/delivery_app_state.dart';

GoRouter createAppRouter(DeliveryAppState appState) => GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: appState,
      /// No raw "Page Not Found" / stack traces for end users.
      errorBuilder: (context, state) => const RouteFallbackPage(),
      redirect: (context, state) {
        final path = state.uri.path;
        if (path == '/' || path.isEmpty) {
          return AppRoutes.splash;
        }

        final isPublic = path == AppRoutes.login ||
            path == AppRoutes.splash ||
            path == AppRoutes.otp;

        // Bootstrapping: stay on splash until init finishes (avoids
        // authed => /app/home => !init => /splash loop).
        if (!appState.isInitialized && path != AppRoutes.splash) {
          return AppRoutes.splash;
        }

        if (appState.isInitialized &&
            !appState.isAuthenticated &&
            !isPublic) {
          return AppRoutes.login;
        }

        // Only after splash work is done: send signed-in users away from auth routes.
        if (appState.isInitialized &&
            appState.isAuthenticated &&
            isPublic) {
          return AppRoutes.home;
        }

        if (appState.isInitialized &&
            !appState.isAuthenticated &&
            path == AppRoutes.splash) {
          return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => AppRoutes.splash,
        ),
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
          builder: (context, state) {
            final mobile = state.uri.queryParameters['mobile'] ?? '';
            return OtpPage(mobile: mobile);
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return PartnerShellPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
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
                      path: 'detail/:orderId',
                      builder: (context, state) {
                        final id = state.pathParameters['orderId'] ?? '';
                        return CompletedOrderDetailsPage(orderId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.schedule,
                  builder: (context, state) => const SchedulePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.earnings,
                  builder: (context, state) => const EarningsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'documents',
                      builder: (context, state) => const DocumentsPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
