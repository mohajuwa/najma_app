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
import '../../features/notifications/presentation/screens/notifications_screen.dart';

/// قواعد التنقل:
/// context.go()   = استبدال الـ stack (لا يوجد رجوع) ← للـ Splash والـ Home بعد Login
/// context.push() = إضافة للـ stack (يوجد رجوع)     ← للـ Onboarding والـ Details

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── نقطة البداية — لا رجوع منها
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),

      // ── Onboarding Flow — push حتى يشتغل زر الرجوع
      GoRoute(path: '/language', builder: (c, s) => const LanguageScreen()),
      GoRoute(
        path: '/role-select',
        builder: (c, s) => const RoleSelectScreen(),
      ),
      GoRoute(path: '/otp', builder: (c, s) => const OtpScreen()),

      // ── Celebrant Flow — go (لا رجوع لـ OTP بعد الدخول)
      GoRoute(
        path: '/home',
        builder: (c, s) => const CelebrantHomeScreen(),
        routes: [
          GoRoute(
            path: 'artist/:id',
            builder: (c, s) =>
                ArtistProfileScreen(artistId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'checkout',
            builder: (c, s) => CheckoutScreen(
              serviceId: int.parse(s.uri.queryParameters['serviceId'] ?? '0'),
              serviceName: s.uri.queryParameters['serviceName'] ?? '',
              servicePrice: double.parse(s.uri.queryParameters['price'] ?? '0'),
              artistName: s.uri.queryParameters['artistName'] ?? '',
            ),
          ),
          GoRoute(
            path: 'track/:orderId',
            builder: (c, s) =>
                OrderTrackingScreen(orderId: s.pathParameters['orderId']!),
          ),
          GoRoute(
            path: 'notifications',
            builder: (c, s) => const NotificationsScreen(),
          ),
        ],
      ),

      // ── Artist Flow
      GoRoute(
        path: '/artist-onboard',
        builder: (c, s) => const ArtistOnboardScreen(),
      ),
      GoRoute(
        path: '/artist-dashboard',
        builder: (c, s) => const ArtistDashboardScreen(),
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (c, s) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}
