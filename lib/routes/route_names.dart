// Route names for the application
class RouteNames {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verify = '/verify';
  static const String forgotPassword = '/forgot-password';
  static const String providerLogin = '/provider-login';
  static const String adminLogin = '/admin-login';
  static const String booking = '/booking';

  // ignore: constant_identifier_names
  static const String BookingScreen = '/booking';

  // User routes
  static const String userHome = '/user-home';
  static const String favorites = '/favorites';
  static const String bookingStatus = '/booking-status';
  static const String userSettings = '/user-settings';
  static const String help = '/help';
  static const String serviceSearch = '/service-search';
  static const String categoryServices = '/category-services';
  static const String providersByCategory = '/providers-by-category';
  static const String serviceProviders = '/service-providers';
  static const String providerServices = '/provider-services';
  static const String serviceDetails = '/service-details';
  static const String offerDetails = '/offer-details';

  // Provider routes
  static const String providerHome = '/provider-home';
  static const String addService = '/add-service';
  static const String myServices = '/my-services';
  static const String myAds = '/my-ads';
  static const String myBookings = '/my-bookings';
  static const String providerPending = '/provider-pending';
  static const String sendMessage = '/send-message';
  static const String providerAnalytics = '/provider-analytics';
  static const String providerSettings = '/provider-settings';
  static const String providerHelp = '/provider-help';
  static const String editProviderProfile = '/edit-provider-profile';
  static const String providerNotifications = '/provider-notifications';

  // Admin routes
  static const String adminHome = '/admin-home';
  static const String userList = '/user-list';
  static const String allBookings = '/all-bookings';
  static const String notifications = '/notifications';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminSettings = '/admin-settings';
  static const String manageUsers = '/manage-users';
  static const String manageServices = '/manage-services';
  static const String manageAds = '/manage-ads';
  static const String manageComments = '/manage-comments';
  static const String manageBookings = '/manage-bookings';
  static const String joinRequests = '/join-requests';
  static const String profileRequests = '/profile-requests';
  static const String userDetails = '/user-details';
  static const String editUserProfile = '/edit-user-profile';
  static const String deleteUser = '/delete-user';
  static const String searchUser = '/search-user';

  // Service category routes
  static const String addServiceCategory = '/add-service-category';
  static const String editServiceCategory = '/edit-service-category';
  static const String serviceCategoryDetails = '/service-category-details';

  // System routes
  static const String splash = '/splash';
  static const String error = '/error';
  static const String testFlow = '/test-flow';
  static const String testApi = '/test-api';
  static const String databaseTest = '/database-test';
}
