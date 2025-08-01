class ApiConstants {
  // static const String baseUrl = 'http://192.168.1.3/asha_app_backend';
  //  static const String baseUrl = 'http://localhost/asha_app_backend';
  static const String baseUrl = 'http://localhost/new_backend';
  static const String apiVersion = 'v1';

  // Auth endpoints
  static const String login = '/api/auth/login.php';
  static const String register = '/api/auth/register.php';
  static const String verify = '/api/auth/verify.php';
  static const String forgotPassword = '/api/auth/forgot_password.php';
  static const String resetPassword = '/api/auth/reset_password.php';
  static const String loginWithRedirect = '/api/auth/login_with_redirect.php';
  static const String registerWithRedirect =
      '/api/auth/register_with_redirect.php';
  static const String checkBookingEligibility =
      '/api/auth/check_booking_eligibility.php';

  // Services endpoints
  static const String getAllServices = '/api/services/get_all.php';
  static const String getServiceById = '/api/services/get_by_id.php';
  static const String getFeaturedServices = '/api/services/featured.php';
  static const String getServiceDetails =
      '/api/services/get_service_details.php';

  // Categories endpoints
  static const String getAllCategories = '/api/categories/get_all.php';
  static const String getCategoriesForProvider =
      '/api/categories/get_categories_for_provider.php';

  // Providers endpoints
  static const String getProviderServices =
      '/api/providers/get_provider_services.php';
  static const String getProvidersByCategory =
      '/api/providers/get_by_category.php';
  static const String getAllProviders = '/api/providers/get_all_providers.php';
  static const String getProviderProfile = '/api/providers/get_profile.php';

  // Ads endpoints
  static const String getActiveAds = '/api/ads/get_active_ads.php';
  static const String getAdDetails = '/api/ads/get_ad_details.php';

  // Bookings endpoints
  static const String createBooking = '/api/bookings/create.php';
  static const String getUserBookings = '/api/bookings/get_user_bookings.php';

  // Favorites endpoints
  static const String toggleFavorite = '/api/favorites/toggle.php';
  static const String getUserFavorites =
      '/api/favorites/get_user_favorites.php';

  // Users endpoints
  static const String getUserProfile = '/api/users/get_profile.php';
  static const String updateUserProfile = '/api/users/update_profile.php';

  // Reviews endpoints
  static const String createReview = '/api/reviews/create.php';
  static const String getServiceReviews =
      '/api/reviews/get_service_reviews.php';

  // Offers endpoints
  static const String getAllOffers = '/api/offers/get_all.php';
  static const String getOffersByService = '/api/offers/get_by_service.php';
}
