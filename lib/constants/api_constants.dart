class ApiConstants {
  // static const String baseUrl = 'http://192.168.1.3/asha_app_backend';
  //  static const String baseUrl = 'http://localhost/asha_app_backend';
  static const String baseUrl = 'http://127.0.0.1/asha_app_tag';
  static const String apiVersion = 'v1';
  
  // Auth endpoints
  static const String login = '/api/auth/login.php';
  static const String register = '/api/auth/register.php';
  static const String verify = '/api/auth/verify.php';
  static const String forgotPassword = '/api/auth/forgot_password.php';
  static const String resetPassword = '/api/auth/reset_password.php';
  
  // Services endpoints
  static const String getAllServices = '/api/services/get_all.php';
  static const String getServiceById = '/api/services/get_by_id.php';
  
  // Categories endpoints
  static const String getAllCategories = '/api/categories/get_all.php';
  
  // Bookings endpoints
  static const String createBooking = '/api/bookings/create.php';
  static const String getUserBookings = '/api/bookings/get_user_bookings.php';
  
  // Favorites endpoints
  static const String toggleFavorite = '/api/favorites/toggle.php';
  static const String getUserFavorites = '/api/favorites/get_user_favorites.php';
  
  // Users endpoints
  static const String getUserProfile = '/api/users/get_profile.php';
  static const String updateUserProfile = '/api/users/update_profile.php';
}