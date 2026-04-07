import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/language/presentation/screens/language_screen.dart';
import '../../features/role_select/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/home/presentation/screens/celebrant_home_screen.dart';
import '../../features/artist_profile/presentation/screens/artist_profile_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/order_tracking/presentation/screens/order_tracking_screen.dart';
import '../../features/artist_dashboard/presentation/screens/artist_dashboard_screen.dart';
import '../../features/artist_onboard/presentation/screens/artist_onboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash',           builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/language',         builder: (c, s) => const LanguageScreen()),
      GoRoute(path: '/role-select',      builder: (c, s) => const RoleSelectScreen()),
      GoRoute(path: '/otp',              builder: (c, s) => const OtpScreen()),

      // Celebrant flow
      GoRoute(path: '/home',             builder: (c, s) => const CelebrantHomeScreen()),
      GoRoute(path: '/artist/:id',       builder: (c, s) => ArtistProfileScreen(artistId: s.pathParameters['id']!)),
      GoRoute(path: '/checkout',         builder: (c, s) => const CheckoutScreen()),
      GoRoute(path: '/track/:orderId',   builder: (c, s) => OrderTrackingScreen(orderId: s.pathParameters['orderId']!)),

      // Artist flow
      GoRoute(path: '/artist-onboard',   builder: (c, s) => const ArtistOnboardScreen()),
      GoRoute(path: '/artist-dashboard', builder: (c, s) => const ArtistDashboardScreen()),
    ],
  );
}
