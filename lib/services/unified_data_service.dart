import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'api_service.dart';

class UnifiedDataService {
  static const String baseUrl = Config.apiBaseUrl;

  // ==================== الخدمات المميزة ====================

  // جلب الخدمات المميزة
  static Future<Map<String, dynamic>> getFeaturedServices({
    int? categoryId,
    int? limit = 10,
  }) async {
    try {
      final result = await ApiService.getFeaturedServices(
        categoryId: categoryId,
        limit: limit,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'total': result['total'],
          'message': 'تم جلب الخدمات المميزة بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': result['message'] ?? 'خطأ في جلب الخدمات المميزة',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ==================== الفئات ====================

  // جلب جميع الفئات
  static Future<Map<String, dynamic>> getAllCategories() async {
    try {
      final result = await ApiService.getAllCategories();

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'total': result['total'],
          'message': 'تم جلب الفئات بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': result['message'] ?? 'خطأ في جلب الفئات',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // جلب فئة محددة
  static Future<Map<String, dynamic>> getCategoryById(int categoryId) async {
    try {
      final result = await ApiService.getCategoryById(categoryId);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': 'تم جلب معلومات الفئة بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'خطأ في جلب معلومات الفئة',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ==================== مزودي الخدمات ====================

  // جلب مزودي الخدمات حسب الفئة
  static Future<Map<String, dynamic>> getProvidersByCategory(
    int categoryId,
  ) async {
    try {
      final result = await ApiService.getProvidersByCategory(categoryId);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'total': result['total'],
          'message': 'تم جلب مزودي الخدمات بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': result['message'] ?? 'خطأ في جلب مزودي الخدمات',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // جلب جميع المزودين مع فلترة متقدمة
  static Future<Map<String, dynamic>> getAllProviders({
    int? categoryId,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await ApiService.getAllProviders(
        categoryId: categoryId,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'total': result['total'],
          'message': 'تم جلب مزودي الخدمات بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': result['message'] ?? 'خطأ في جلب مزودي الخدمات',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // جلب خدمات مزود معين
  static Future<Map<String, dynamic>> getProviderServices(
    int providerId, {
    int? categoryId,
  }) async {
    try {
      final result = await ApiService.getProviderServices(
        providerId,
        categoryId: categoryId,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': 'تم جلب خدمات المزود بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'خطأ في جلب خدمات المزود',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // جلب معلومات مزود معين
  static Future<Map<String, dynamic>> getProviderProfile(int providerId) async {
    try {
      final result = await ApiService.getProviderProfile(providerId);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': 'تم جلب معلومات المزود بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'خطأ في جلب معلومات المزود',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ==================== جلب جميع البيانات المطلوبة ====================

  // جلب البيانات الرئيسية للصفحة الرئيسية
  static Future<Map<String, dynamic>> getHomePageData() async {
    try {
      // جلب الخدمات المميزة
      final featuredServices = await getFeaturedServices(limit: 10);

      // جلب جميع الفئات
      final categories = await getAllCategories();

      // جلب الإعلانات النشطة
      final ads = await ApiService.getActiveAds();

      return {
        'success': true,
        'data': {
          'featured_services': featuredServices['data'] ?? [],
          'categories': categories['data'] ?? [],
          'ads': ads['data'] ?? [],
        },
        'message': 'تم جلب البيانات بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'data': {'featured_services': [], 'categories': [], 'ads': []},
        'message': 'خطأ في جلب البيانات: $e',
      };
    }
  }

  // جلب بيانات صفحة الفئة
  static Future<Map<String, dynamic>> getCategoryPageData(
    int categoryId,
  ) async {
    try {
      // جلب معلومات الفئة
      final categoryInfo = await getCategoryById(categoryId);

      // جلب مزودي الخدمات في هذه الفئة
      final providers = await getProvidersByCategory(categoryId);

      // جلب الخدمات المميزة في هذه الفئة
      final featuredServices = await getFeaturedServices(
        categoryId: categoryId,
        limit: 5,
      );

      return {
        'success': true,
        'data': {
          'category': categoryInfo['data']?['category'],
          'providers': providers['data'] ?? [],
          'featured_services': featuredServices['data'] ?? [],
        },
        'message': 'تم جلب بيانات الفئة بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'data': {'category': null, 'providers': [], 'featured_services': []},
        'message': 'خطأ في جلب بيانات الفئة: $e',
      };
    }
  }

  // جلب بيانات صفحة المزود
  static Future<Map<String, dynamic>> getProviderPageData(
    int providerId,
  ) async {
    try {
      // جلب معلومات المزود
      final providerInfo = await getProviderProfile(providerId);

      // جلب خدمات المزود
      final providerServices = await getProviderServices(providerId);

      return {
        'success': true,
        'data': {
          'provider': providerInfo['data']?['provider'],
          'services': providerServices['data']?['services'] ?? [],
          'featured_services': providerInfo['data']?['featured_services'] ?? [],
          'recent_reviews': providerInfo['data']?['recent_reviews'] ?? [],
        },
        'message': 'تم جلب بيانات المزود بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'data': {
          'provider': null,
          'services': [],
          'featured_services': [],
          'recent_reviews': [],
        },
        'message': 'خطأ في جلب بيانات المزود: $e',
      };
    }
  }

  // ==================== المفضلة ====================

  // إضافة/إزالة من المفضلة
  static Future<Map<String, dynamic>> toggleFavorite(
    int userId,
    int serviceId,
  ) async {
    try {
      final result = await ApiService.toggleFavorite(
        userId: userId,
        serviceId: serviceId,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': result['message'] ?? 'تم تحديث المفضلة بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'خطأ في تحديث المفضلة',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ==================== التقييمات ====================

  // إضافة تقييم جديد
  static Future<Map<String, dynamic>> createReview({
    required int userId,
    required int serviceId,
    required int rating,
    required String comment,
  }) async {
    try {
      final reviewData = {
        'user_id': userId,
        'service_id': serviceId,
        'rating': rating,
        'comment': comment,
      };

      final result = await ApiService.createReview(reviewData);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': result['message'] ?? 'تم إضافة التقييم بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'خطأ في إضافة التقييم',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ==================== تفاصيل الخدمة ====================

  // جلب تفاصيل الخدمة
  static Future<Map<String, dynamic>> getServiceDetails(
    int serviceId, {
    int? userId,
  }) async {
    try {
      final params = {
        'service_id': serviceId,
      };
      
      if (userId != null) {
        params['user_id'] = userId;
      }

      final result = await ApiService.getServiceDetails(params);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': result['message'] ?? 'تم جلب تفاصيل الخدمة بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'خطأ في جلب تفاصيل الخدمة',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ==================== الإعلانات ====================

  // جلب الإعلانات النشطة
  static Future<Map<String, dynamic>> getActiveAds() async {
    try {
      final result = await ApiService.getActiveAds();

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': result['message'] ?? 'تم جلب الإعلانات بنجاح',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': result['message'] ?? 'خطأ في جلب الإعلانات',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'خطأ في الاتصال: $e'};
    }
  }
}
