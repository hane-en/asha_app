import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_home_page.dart';
import '../screens/admin/admin_settings_page.dart';
import '../screens/admin/all_bookings_page.dart';
import '../screens/admin/delete_user_page.dart';
import '../screens/admin/edit_user_profile.dart';
import '../screens/admin/join_requests_page.dart';
import '../screens/admin/manage_ads.dart';
import '../screens/admin/manage_bookings.dart';
import '../screens/admin/manage_comments.dart';
import '../screens/admin/manage_services.dart';
import '../screens/admin/manage_users.dart';
import '../screens/admin/profile_requests_page.dart';
import '../screens/admin/search_user_page.dart';
import '../screens/admin/user_details_page.dart';
import '../screens/admin/user_list_page.dart';
import '../screens/auth/forgot_password_page.dart';
import '../screens/auth/login_admin.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/provider_login.dart';
import '../screens/auth/signup_page.dart';
import '../screens/auth/verify_page.dart';
import '../screens/provider/add_service_page.dart';
import '../screens/provider/add_service_category_page.dart';
import '../screens/provider/edit_service_category_page.dart';
import '../screens/provider/service_category_details_page.dart';
import '../screens/provider/my_ads_page.dart';
import '../screens/provider/my_bookings_page.dart';
import '../screens/provider/my_services_page.dart';
import '../screens/provider/notifications_page.dart';
import '../screens/provider/provider_analytics_page.dart';
import '../screens/provider/provider_home_page.dart';
import '../screens/provider/provider_pending_page.dart';
import '../screens/provider/send_massage_page.dart';
import '../screens/provider/settings_page.dart';
import '../screens/user/booking_status_page.dart';
import '../screens/user/favorites_page.dart';
import '../screens/user/home_page.dart';
import '../screens/user/notifications_page.dart';
import '../screens/user/search_page.dart';
import '../screens/user/settings_page.dart';
import '../screens/user/user_help_page.dart';
import '../screens/user/user_home_page.dart';
import '../screens/provider/provider_help_page.dart';
import '../screens/provider/edit_provider_profile_page.dart';
import '../test_services_connection.dart';
import '../test_connection.dart';
import '../test_services_home_method.dart';
import '../test_backend_connection.dart';
import '../test_unified_data.dart';
import '../test_services_simple.dart';
import '../test_api_simple.dart';
import '../screens/user/test_favorites_debug.dart';
import '../screens/user/test_local_favorites.dart';
import 'route_arguments.dart';
import 'route_names.dart';

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
  static const String adminDashboard = RouteNames.adminDashboard;
  static const String adminSettings = RouteNames.adminSettings;
  static const String manageUsers = RouteNames.manageUsers;
  static const String manageServices = RouteNames.manageServices;
  static const String manageAds = RouteNames.manageAds;
  static const String manageComments = RouteNames.manageComments;
  static const String manageBookings = RouteNames.manageBookings;
  static const String joinRequests = RouteNames.joinRequests;
  static const String userDetails = RouteNames.userDetails;
  static const String editUserProfile = RouteNames.editUserProfile;
  static const String deleteUser = RouteNames.deleteUser;
  static const String searchUser = RouteNames.searchUser;
  static const String providerHelp = RouteNames.providerHelp;

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
            builder: (_) => LoginScreen(),
            settings: settings,
          );
        case userHome:
          return MaterialPageRoute(
            builder: (_) => const UserHomePage(),
            settings: settings,
          );
        case favorites:
          return MaterialPageRoute(
            builder: (_) => FavoritesPage(),
            settings: settings,
          );
        case bookingStatus:
          return MaterialPageRoute(
            builder: (_) => const BookingStatusPage(),
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
        case RouteNames.addServiceCategory:
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => AddServiceCategoryPage(
              serviceId: args?['serviceId'] ?? 0,
              serviceTitle: args?['serviceTitle'] ?? '',
            ),
            settings: settings,
          );
        case RouteNames.editServiceCategory:
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => EditServiceCategoryPage(
              categoryId: args?['categoryId'] ?? 0,
              serviceTitle: args?['serviceTitle'] ?? '',
            ),
            settings: settings,
          );
        case RouteNames.serviceCategoryDetails:
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => ServiceCategoryDetailsPage(
              categoryId: args?['categoryId'] ?? 0,
              serviceTitle: args?['serviceTitle'] ?? '',
            ),
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
        case RouteNames.adminDashboard:
          return MaterialPageRoute(
            builder: (_) => const AdminDashboardPage(),
            settings: settings,
          );
        case RouteNames.adminSettings:
          return MaterialPageRoute(
            builder: (_) => const AdminSettingsPage(),
            settings: settings,
          );
        case RouteNames.manageUsers:
          return MaterialPageRoute(
            builder: (_) => const ManageUsersPage(),
            settings: settings,
          );
        case RouteNames.manageServices:
          return MaterialPageRoute(
            builder: (_) => const ManageServices(),
            settings: settings,
          );
        case RouteNames.manageAds:
          return MaterialPageRoute(
            builder: (_) => const ManageAdsPage(),
            settings: settings,
          );
        case RouteNames.manageComments:
          return MaterialPageRoute(
            builder: (_) => const ManageComments(),
            settings: settings,
          );
        case RouteNames.manageBookings:
          return MaterialPageRoute(
            builder: (_) => const ManageBookings(),
            settings: settings,
          );
        case RouteNames.joinRequests:
          return MaterialPageRoute(
            builder: (_) => const JoinRequestsPage(),
            settings: settings,
          );
        case RouteNames.profileRequests:
          return MaterialPageRoute(
            builder: (_) => const ProfileRequestsPage(),
            settings: settings,
          );
        case RouteNames.userDetails:
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => UserDetailsPage(user: args ?? {}),
            settings: settings,
          );
        case RouteNames.editUserProfile:
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => EditUserProfilePage(user: args ?? {}),
            settings: settings,
          );
        case RouteNames.deleteUser:
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => DeleteUserPage(
              userId: args?['userId'] ?? 0,
              userName: args?['userName'] ?? '',
            ),
            settings: settings,
          );
        case RouteNames.searchUser:
          return MaterialPageRoute(
            builder: (_) => const SearchUserPage(),
            settings: settings,
          );
        case RouteNames.providerHelp:
          return MaterialPageRoute(
            builder: (_) => const ProviderHelpPage(),
            settings: settings,
          );
        case RouteNames.editProviderProfile:
          return MaterialPageRoute(
            builder: (_) => const EditProviderProfilePage(),
            settings: settings,
          );
        case '/provider-notifications':
          return MaterialPageRoute(
            builder: (_) => const ProviderNotificationsPage(),
            settings: settings,
          );
        case '/test-services':
          return MaterialPageRoute(
            builder: (_) => TestServicesConnection(),
            settings: settings,
          );
        case '/test-connection':
          return MaterialPageRoute(
            builder: (_) => TestConnection(),
            settings: settings,
          );
        case '/test-services-home':
          return MaterialPageRoute(
            builder: (_) => TestServicesHomeMethod(),
            settings: settings,
          );
        case '/test-backend':
          return MaterialPageRoute(
            builder: (_) => TestBackendConnection(),
            settings: settings,
          );
        case '/test-unified':
          return MaterialPageRoute(
            builder: (_) => TestUnifiedData(),
            settings: settings,
          );
        case '/test-services-simple':
          return MaterialPageRoute(
            builder: (_) => TestServicesSimple(),
            settings: settings,
          );
        case '/test-api-simple':
          return MaterialPageRoute(
            builder: (_) => TestApiSimple(),
            settings: settings,
          );
        case '/test-favorites':
          return MaterialPageRoute(builder: (_) => const TestFavoritesDebug());
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

  @override
  Widget build(BuildContext context) {
    // إعادة التوجيه تلقائياً بدون أي واجهة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role');
      String route;
      switch (role) {
        case 'user':
          route = AppRoutes.userHome;
          break;
        case 'provider':
          route = AppRoutes.providerHome;
          break;
        case 'admin':
          route = AppRoutes.adminHome;
          break;
        default:
          route = AppRoutes.userHome;
          break;
      }
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    });
    return const SizedBox.shrink();
  }
}
