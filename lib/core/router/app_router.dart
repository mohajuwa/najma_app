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
import '../../features/artist_dashboard/presentation/screens/artist_location_screen.dart';
import '../../features/artist_onboard/presentation/screens/artist_onboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/order_deliverables_screen.dart';
import '../../features/orders/presentation/screens/custom_song_request_screen.dart';
// Settings
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/language_settings_screen.dart';
import '../../features/settings/presentation/screens/static_screens.dart';
import '../../features/artist_services/presentation/screens/artist_services_screen.dart';
import '../../features/artist_dashboard/presentation/screens/social_links_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── نقطة البداية ────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),

      // ── Onboarding ──────────────────────────────────────────────
      GoRoute(path: '/language',    builder: (c, s) => const LanguageScreen()),
      GoRoute(path: '/role-select', builder: (c, s) => const RoleSelectScreen()),
      GoRoute(path: '/otp',         builder: (c, s) => const OtpScreen()),

      // ── Celebrant Flow ──────────────────────────────────────────
      GoRoute(
        path: '/home',
        builder: (c, s) => const CelebrantHomeScreen(),
        routes: [
          GoRoute(
            path: 'artist/:id',
            builder: (c, s) => ArtistProfileScreen(
                artistId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'checkout',
            builder: (c, s) => CheckoutScreen(
              serviceId:    int.parse(s.uri.queryParameters['serviceId'] ?? '0'),
              serviceName:  s.uri.queryParameters['serviceName'] ?? '',
              servicePrice: double.parse(s.uri.queryParameters['price'] ?? '0'),
              artistName:   s.uri.queryParameters['artistName'] ?? '',
            ),
          ),
          // ── طلب أغنية خاصة / هدية ─────────────────────────────
          GoRoute(
            path: 'custom-song-request',
            builder: (c, s) {
              final q = s.uri.queryParameters;
              return CustomSongRequestScreen(
                serviceId:   int.parse(q['serviceId']   ?? '0'),
                serviceName: Uri.decodeComponent(q['serviceName'] ?? ''),
                category:    q['category']   ?? 'custom_song',
                price:       double.parse(q['price']    ?? '0'),
                artistName:  Uri.decodeComponent(q['artistName'] ?? ''),
                artistId:    int.parse(q['artistId']    ?? '0'),
              );
            },
          ),
          // ── محتوى مُسلَّم (للعميل) ────────────────────────────
          GoRoute(
            path: 'order-deliverables/:orderId',
            builder: (c, s) => OrderDeliverablesScreen(
              orderId:    int.parse(s.pathParameters['orderId'] ?? '0'),
              orderTitle: Uri.decodeComponent(
                  s.uri.queryParameters['title'] ?? 'المحتوى المُسلَّم'),
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
          // ── إعدادات المحتفل ────────────────────────────────────
          GoRoute(
            path: 'settings',
            builder: (c, s) => const SettingsScreen(origin: 'home'),
            routes: [
              GoRoute(path: 'edit-profile', builder: (c, s) => const EditProfileScreen()),
              GoRoute(path: 'language',     builder: (c, s) => const LanguageSettingsScreen()),
              GoRoute(path: 'privacy',      builder: (c, s) => const PrivacyPolicyScreen()),
              GoRoute(path: 'terms',        builder: (c, s) => const TermsScreen()),
              GoRoute(path: 'about',        builder: (c, s) => const AboutScreen()),
              GoRoute(path: 'support',      builder: (c, s) => const SupportScreen()),
            ],
          ),
        ],
      ),

      // ── Artist Flow ─────────────────────────────────────────────
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
          GoRoute(
            path: 'services',
            builder: (c, s) => const ArtistServicesScreen(),
          ),
          GoRoute(
            path: 'social-links',
            builder: (c, s) => const SocialLinksScreen(),
          ),
          // ── مشاركة الموقع ──────────────────────────────────────
          GoRoute(
            path: 'location',
            builder: (c, s) => const ArtistLocationScreen(),
          ),
          // ── محتوى مُسلَّم (للفنان) ─────────────────────────────
          GoRoute(
            path: 'order-deliverables/:orderId',
            builder: (c, s) => OrderDeliverablesScreen(
              orderId:    int.parse(s.pathParameters['orderId'] ?? '0'),
              orderTitle: Uri.decodeComponent(
                  s.uri.queryParameters['title'] ?? 'تسليم الخدمة'),
            ),
          ),
          // ── إعدادات الفنان ──────────────────────────────────────
          GoRoute(
            path: 'settings',
            builder: (c, s) => const SettingsScreen(origin: 'artist'),
            routes: [
              GoRoute(path: 'edit-profile', builder: (c, s) => const EditProfileScreen()),
              GoRoute(path: 'language',     builder: (c, s) => const LanguageSettingsScreen()),
              GoRoute(path: 'privacy',      builder: (c, s) => const PrivacyPolicyScreen()),
              GoRoute(path: 'terms',        builder: (c, s) => const TermsScreen()),
              GoRoute(path: 'about',        builder: (c, s) => const AboutScreen()),
              GoRoute(path: 'support',      builder: (c, s) => const SupportScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}
