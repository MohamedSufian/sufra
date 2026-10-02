import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/address/address.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/address/address_form_screen.dart';
import '../../features/address/address_picker_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/orders/order_placed_screen.dart';
import '../../features/orders/order_tracking_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/restaurant/restaurant_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const favorites = '/favorites';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';

  static const checkout = '/checkout';
  static const signIn = '/sign-in';
  static const addressPick = '/address/pick';
  static const addressDetails = '/address/details';

  static String restaurant(String id) => '$home/restaurant/$id';
  static String orderPlaced(int id) => '/order-placed/$id';
  static String orderTracking(int id) => '$orders/$id';

  /// The five tab roots; anything deeper is a full-screen page without the navigation bar.
  static const tabs = {home, favorites, cart, orders, profile};
}

final routerProvider = Provider<GoRouter>((ref) {
  GoRoute tab(String path, Widget Function() screen, {List<RouteBase> routes = const []}) =>
      GoRoute(path: path, pageBuilder: (_, _) => NoTransitionPage(child: screen()), routes: routes);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      // Full-screen flows above the tabs.
      GoRoute(path: AppRoutes.checkout, builder: (_, _) => const CheckoutScreen()),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: AppRoutes.addressPick,
        builder: (_, state) => AddressPickerScreen(editing: state.extra as SavedAddress?),
      ),
      GoRoute(
        path: AppRoutes.addressDetails,
        // The draft only travels in memory; after a web reload, start over from the map.
        builder: (_, state) => switch (state.extra) {
          final AddressDraft draft => AddressFormScreen(draft: draft),
          _ => const AddressPickerScreen(),
        },
      ),
      GoRoute(
        path: '/order-placed/:id',
        builder: (_, state) => OrderPlacedScreen(orderId: int.tryParse(state.pathParameters['id']!) ?? -1),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, state, shell) => MainShell(
          navigationShell: shell,
          showNavigation: AppRoutes.tabs.contains(state.uri.path),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              tab(
                AppRoutes.home,
                HomeScreen.new,
                routes: [
                  GoRoute(
                    path: 'restaurant/:id',
                    builder: (_, state) => RestaurantScreen(restaurantId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(routes: [tab(AppRoutes.favorites, FavoritesScreen.new)]),
          StatefulShellBranch(routes: [tab(AppRoutes.cart, CartScreen.new)]),
          StatefulShellBranch(
            routes: [
              tab(
                AppRoutes.orders,
                OrdersScreen.new,
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => OrderTrackingScreen(orderId: int.tryParse(state.pathParameters['id']!) ?? -1),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(routes: [tab(AppRoutes.profile, ProfileScreen.new)]),
        ],
      ),
    ],
  );
});
