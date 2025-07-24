import 'package:flutter/material.dart';
import 'route_names.dart';
import 'route_arguments.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signup_page.dart';
import '../screens/auth/verify_page.dart';
import '../screens/auth/forgot_password_page.dart';
import '../screens/auth/provider_login.dart';
import '../screens/auth/login_admin.dart';
import '../screens/user/user_home_page.dart';
import '../screens/user/favorites_page.dart';
import '../screens/user/booking_status_page.dart';
import '../screens/provider/provider_home_page.dart';
import '../screens/provider/add_service_page.dart';
import '../screens/provider/my_services_page.dart';
import '../screens/provider/my_ads_page.dart';
import '../screens/provider/my_bookings_page.dart';
import '../screens/provider/provider_pending_page.dart';
import '../screens/provider/send_massage_page.dart';
import '../screens/admin/admin_home_page.dart';
import '../screens/admin/user_list_page.dart';
import '../screens/admin/all_bookings_page.dart';
import '../config/config.dart';
import '../screens/user/settings_page.dart';
import '../screens/user/notifications_page.dart';
import '../screens/user/search_page.dart';
import '../screens/user/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/provider/provider_analytics_page.dart';
import '../screens/provider/notifications_page.dart';
import '../screens/provider/settings_page.dart';
import '../screens/user/user_help_page.dart';

class AppRoutes {
  // Route names - using centralized route names
  static const String login = RouteNames.login;
  static const String signup = RouteNames.signup;
  static const String verify = RouteNames.verify;
  static const String forgotPassword = RouteNames.forgotPassword;
  static const String providerLogin = RouteNames.providerLogin;
  static const String adminLogin = RouteNames.adminLogin;
  static const String userHome = RouteNames.userHome;
  static const String favorites = RouteNames.favorites;
  static const String bookingStatus = RouteNames.bookingStatus;
  static const String providerHome = RouteNames.providerHome;
  static const String addService = RouteNames.addService;
  static const String myServices = RouteNames.myServices;
  static const String myAds = RouteNames.myAds;
  static const String myBookings = RouteNames.myBookings;
  static const String providerPending = RouteNames.providerPending;
  static const String sendMessage = RouteNames.sendMessage;
  static const String adminHome = RouteNames.adminHome;
  static const String userList = RouteNames.userList;
  static const String allBookings = RouteNames.allBookings;
  static const String notifications = RouteNames.notifications;
  static const String userSettings = RouteNames.userSettings;
  static const String help = RouteNames.help;
  static const String serviceSearch = RouteNames.serviceSearch;
  static const String providerAnalytics = RouteNames.providerAnalytics;
  static const String providerSettings = RouteNames.providerSettings;
  static const String splash = RouteNames.splash;
  static const String error = RouteNames.error;

  /// Route generator with improved type safety and error handling
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case login:
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
            settings: settings,
          );
        case signup:
          return MaterialPageRoute(
            builder: (_) => const SignupPage(),
            settings: settings,
          );
        case verify:
          return MaterialPageRoute(
            builder: (_) => const VerifyPage(),
            settings: settings,
          );
        case forgotPassword:
          return MaterialPageRoute(
            builder: (_) => const ForgotPasswordPage(),
            settings: settings,
          );
        case providerLogin:
          return MaterialPageRoute(
            builder: (_) => const ProviderLoginPage(),
            settings: settings,
          );
        case adminLogin:
          return MaterialPageRoute(
            builder: (_) => const AdminLoginPage(),
            settings: settings,
          );
        case userHome:
          return MaterialPageRoute(
            builder: (_) => const UserHomePage(),
            settings: settings,
          );
        case favorites:
          return MaterialPageRoute(
            builder: (_) => const FavoritesPage(userId: 1),
            settings: settings,
          );
        case bookingStatus:
          return MaterialPageRoute(
            builder: (_) => const BookingStatusPage(userId: 1),
            settings: settings,
          );
        case providerHome:
          return MaterialPageRoute(
            builder: (_) => const ProviderHomePage(),
            settings: settings,
          );
        case addService:
          return MaterialPageRoute(
            builder: (_) => const AddServicePage(),
            settings: settings,
          );
        case myServices:
          return MaterialPageRoute(
            builder: (_) => const MyServicesPage(),
            settings: settings,
          );
        case myAds:
          return MaterialPageRoute(
            builder: (_) => const MyAdsPage(),
            settings: settings,
          );
        case myBookings:
          return MaterialPageRoute(
            builder: (_) => const MyBookingsPage(),
            settings: settings,
          );
        case providerPending:
          return MaterialPageRoute(
            builder: (_) => const ProviderPendingPage(),
            settings: settings,
          );
        case sendMessage:
          final args = settings.arguments as SendMessageArguments?;
          final receiverPhone = args?.receiverPhone ?? '';
          return MaterialPageRoute(
            builder: (_) => SendMessagePage(receiverPhone: receiverPhone),
            settings: settings,
          );
        case adminHome:
          return MaterialPageRoute(
            builder: (_) => const AdminHomePage(),
            settings: settings,
          );
        case userList:
          return MaterialPageRoute(
            builder: (_) => const UserListPage(),
            settings: settings,
          );
        case allBookings:
          return MaterialPageRoute(
            builder: (_) => const AllBookingsPage(),
            settings: settings,
          );
        case notifications:
          return MaterialPageRoute(
            builder: (_) => const NotificationsPage(),
            settings: settings,
          );
        case userSettings:
          return MaterialPageRoute(
            builder: (_) => const SettingsPage(),
            settings: settings,
          );
        case help:
          return MaterialPageRoute(
            builder: (_) => const UserHelpPage(),
            settings: settings,
          );
        case serviceSearch:
          return MaterialPageRoute(
            builder: (_) => const SearchPage(),
            settings: settings,
          );
        case providerAnalytics:
          return MaterialPageRoute(
            builder: (_) => const ProviderAnalyticsPage(),
            settings: settings,
          );
        case providerSettings:
          return MaterialPageRoute(
            builder: (_) => const ProviderSettingsPage(),
            settings: settings,
          );
        case splash:
          return MaterialPageRoute(
            builder: (_) => const HomePage(),
            settings: settings,
          );
        case error:
          final args = settings.arguments as ErrorArguments?;
          final errorMessage = args?.message ?? 'حدث خطأ غير متوقع';
          return MaterialPageRoute(
            builder: (_) => _ErrorPage(message: errorMessage),
            settings: settings,
          );
        case '/provider-notifications':
          return MaterialPageRoute(
            builder: (_) => const ProviderNotificationsPage(),
            settings: settings,
          );
        default:
          return MaterialPageRoute(
            builder: (_) => const _NotFoundPage(),
            settings: settings,
          );
      }
    } catch (e) {
      return MaterialPageRoute(
        builder: (_) => _ErrorPage(message: 'خطأ في تحميل الصفحة: $e'),
        settings: settings,
      );
    }
  }

  // Helper method to navigate with arguments
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method to replace current route
  static void replaceTo(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Helper method to navigate and clear stack
  static void navigateAndClear(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}

// Error page widget
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('خطأ'), backgroundColor: Colors.red),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text('حدث خطأ', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Not found page widget
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  Future<String> _getHomeRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    switch (role) {
      case 'user':
        return AppRoutes.userHome;
      case 'provider':
        return AppRoutes.providerHome;
      case 'admin':
        return AppRoutes.adminHome;
      default:
        return AppRoutes
            .userHome; // تعديل هنا: اجعل الصفحة الافتراضية هي userHome
    }
  }

  @override
  Widget build(BuildContext context) {
    // إعادة التوجيه تلقائياً بدون أي واجهة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final route = await _getHomeRoute();
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    });
    return const SizedBox.shrink();
  }
}
