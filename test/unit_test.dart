import 'package:flutter_test/flutter_test.dart';
import 'package:asha_application/models/user_model.dart';
import 'package:asha_application/models/service_model.dart';
import 'package:asha_application/utils/validators.dart';
import 'package:asha_application/config/config.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel from JSON', () {
      final json = {
        'id': 1,
        'name': 'أحمد محمد',
        'phone': '77156724',
        'email': 'ahmed@example.com',
        'role': 'user',
        'profile_image': 'https://example.com/image.jpg',
        'address': 'إب، اليمن',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
        'is_active': true,
        'is_verified': true,
        'rating': 4,
        'review_count': 10,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'أحمد محمد');
      expect(user.phone, '77156724');
      expect(user.email, 'ahmed@example.com');
      expect(user.role, 'user');
      expect(user.profileImage, 'https://example.com/image.jpg');
      expect(user.address, 'إب، اليمن');
      expect(user.isActive, true);
      expect(user.isVerified, true);
      expect(user.rating, 4);
      expect(user.reviewCount, 10);
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        id: 1,
        name: 'أحمد محمد',
        phone: '77156724',
        email: 'ahmed@example.com',
        role: 'user',
        profileImage: 'https://example.com/image.jpg',
        address: 'إب، اليمن',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
        isVerified: true,
        rating: 4,
        reviewCount: 10,
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'أحمد محمد');
      expect(json['phone'], '77156724');
      expect(json['email'], 'ahmed@example.com');
      expect(json['role'], 'user');
      expect(json['profile_image'], 'https://example.com/image.jpg');
      expect(json['address'], 'إب، اليمن');
      expect(json['is_active'], true);
      expect(json['is_verified'], true);
      expect(json['rating'], 4);
      expect(json['review_count'], 10);
    });

    test('should check user roles correctly', () {
      final user = UserModel(
        id: 1,
        name: 'أحمد محمد',
        phone: '77156724',
        email: 'ahmed@example.com',
        role: 'admin',
      );

      expect(user.isAdmin, true);
      expect(user.isProvider, false);
      expect(user.isUser, false);
    });

    test('should calculate profile completeness', () {
      final completeUser = UserModel(
        id: 1,
        name: 'أحمد محمد',
        phone: '77156724',
        email: 'ahmed@example.com',
        role: 'user',
        profileImage: 'https://example.com/image.jpg',
        address: 'إب، اليمن',
      );

      final incompleteUser = UserModel(
        id: 1,
        name: 'أحمد محمد',
        phone: '77156724',
        email: 'ahmed@example.com',
        role: 'user',
      );

      expect(completeUser.profileCompleteness, 1.0);
      expect(incompleteUser.profileCompleteness, 0.6);
    });

    test('should format rating correctly', () {
      final user = UserModel(
        id: 1,
        name: 'أحمد محمد',
        phone: '77156724',
        email: 'ahmed@example.com',
        role: 'user',
        rating: 4,
        reviewCount: 10,
      );

      expect(user.formattedRating, '4.0');
      expect(user.hasReviews, true);
      expect(user.averageRating, 4.0);
    });

    test('should validate user data', () {
      final validUser = UserModel(
        id: 1,
        name: 'أحمد محمد',
        phone: '77156724',
        email: 'ahmed@example.com',
        role: 'user',
      );

      expect(validUser.isValidEmail, true);
      expect(validUser.isValidPhone, true);
      expect(validUser.hasValidProfile, true);
    });
  });

  group('ServiceModel Tests', () {
    test('should create ServiceModel from JSON', () {
      final json = {
        'id': 1,
        'name': 'خدمة التصوير',
        'description': 'تصوير احترافي للمناسبات',
        'price': 500,
        'original_price': 600,
        'category': 'تصوير',
        'provider_id': 1,
        'provider_name': 'أحمد المصور',
        'provider_phone': '77156724',
        'provider_email': 'ahmed@example.com',
        'image': 'https://example.com/image.jpg',
        'rating': 4.5,
        'review_count': 20,
        'is_featured': true,
        'is_verified': true,
        'is_active': true,
        'booking_count': 50,
        'favorite_count': 30,
        'location': 'إب، إب',
        'duration': 120,
        'max_guests': 100,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.id, 1);
      expect(service.name, 'خدمة التصوير');
      expect(service.description, 'تصوير احترافي للمناسبات');
      expect(service.price, 500);
      expect(service.originalPrice, 600);
      expect(service.category, 'تصوير');
      expect(service.providerId, 1);
      expect(service.providerName, 'أحمد المصور');
      expect(service.rating, 4.5);
      expect(service.reviewCount, 20);
      expect(service.isFeatured, true);
      expect(service.isVerified, true);
      expect(service.isActive, true);
      expect(service.bookingCount, 50);
      expect(service.favoriteCount, 30);
      expect(service.location, 'إب، إب');
      expect(service.duration, 120);
      expect(service.maxGuests, 100);
    });

    test('should convert ServiceModel to JSON', () {
      final service = ServiceModel(
        id: 1,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        originalPrice: 600,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        providerPhone: '77156724',
        providerEmail: 'ahmed@example.com',
        image: 'https://example.com/image.jpg',
        rating: 4.5,
        reviewCount: 20,
        isFeatured: true,
        isVerified: true,
        bookingCount: 50,
        favoriteCount: 30,
        location: 'إب، إب',
        duration: 120,
        maxGuests: 100,
      );

      final json = service.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'خدمة التصوير');
      expect(json['description'], 'تصوير احترافي للمناسبات');
      expect(json['price'], 500);
      expect(json['original_price'], 600);
      expect(json['category'], 'تصوير');
      expect(json['provider_id'], 1);
      expect(json['provider_name'], 'أحمد المصور');
      expect(json['rating'], 4.5);
      expect(json['review_count'], 20);
      expect(json['is_featured'], true);
      expect(json['is_verified'], true);
      expect(json['is_active'], true);
      expect(json['booking_count'], 50);
      expect(json['favorite_count'], 30);
      expect(json['location'], 'إب، إب');
      expect(json['duration'], 120);
      expect(json['max_guests'], 100);
    });

    test('should calculate discount correctly', () {
      final service = ServiceModel(
        id: 1,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        originalPrice: 600,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
      );

      expect(service.hasDiscount, true);
      expect(service.discountPercentage, 17.0);
      expect(service.discountText, 'خصم 17%');
      expect(service.formattedPrice, '500.00 ريال');
      expect(service.formattedOriginalPrice, '600.00 ريال');
    });

    test('should format rating correctly', () {
      final service = ServiceModel(
        id: 1,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        rating: 4.5,
        reviewCount: 20,
      );

      expect(service.formattedRating, '4.5');
      expect(service.ratingText, 'ممتاز');
      expect(service.hasReviews, true);
    });

    test('should format duration correctly', () {
      final service1 = ServiceModel(
        id: 1,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        duration: 30,
      );

      final service2 = ServiceModel(
        id: 2,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        duration: 90,
      );

      final service3 = ServiceModel(
        id: 3,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        duration: 1500,
      );

      expect(service1.formattedDuration, '30 دقيقة');
      expect(service2.formattedDuration, '1 ساعة و 30 دقيقة');
      expect(service3.formattedDuration, '1 يوم');
    });

    test('should check service status correctly', () {
      final service = ServiceModel(
        id: 1,
        name: 'خدمة التصوير',
        description: 'تصوير احترافي للمناسبات',
        price: 500,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        isFeatured: true,
        isVerified: true,
        bookingCount: 50,
        favoriteCount: 30,
      );

      expect(service.statusText, 'مميز');
      expect(service.isPopular, true);
      expect(service.isTrending, true);
      expect(service.isAvailable, true);
    });

    test('should search in service correctly', () {
      final service = ServiceModel(
        id: 1,
        name: 'خدمة التصوير الاحترافي',
        description: 'تصوير احترافي للمناسبات والأعراس',
        price: 500,
        category: 'تصوير',
        providerId: 1,
        providerName: 'أحمد المصور',
        tags: ['تصوير', 'أعراس', 'مناسبات'],
      );

      expect(service.matchesSearch('تصوير'), true);
      expect(service.matchesSearch('أعراس'), true);
      expect(service.matchesSearch('أحمد'), true);
      expect(service.matchesSearch('مطعم'), false);
    });
  });

  group('Validators Tests', () {
    test('should validate email correctly', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('should validate phone correctly', () {
      expect(Validators.validatePhone('0501234567'), null);
      expect(Validators.validatePhone('512345678'), null);
      expect(Validators.validatePhone('+966501234567'), null);
      expect(Validators.validatePhone('123'), isNotNull);
      expect(Validators.validatePhone(''), isNotNull);
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('should validate password correctly', () {
      expect(Validators.validatePassword('password123'), null);
      expect(Validators.validatePassword('123'), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('should validate strong password correctly', () {
      expect(Validators.validateStrongPassword('Password123!'), null);
      expect(Validators.validateStrongPassword('password'), isNotNull);
      expect(Validators.validateStrongPassword('PASSWORD123'), isNotNull);
      expect(Validators.validateStrongPassword('Password123'), isNotNull);
    });

    test('should validate name correctly', () {
      expect(Validators.validateName('أحمد محمد'), null);
      expect(Validators.validateName('Ahmed Mohamed'), null);
      expect(Validators.validateName('أ'), isNotNull);
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName(null), isNotNull);
    });

    test('should validate price correctly', () {
      expect(Validators.validatePrice('100'), null);
      expect(Validators.validatePrice('100.50'), null);
      expect(Validators.validatePrice('-100'), isNotNull);
      expect(Validators.validatePrice('1000000'), isNotNull);
      expect(Validators.validatePrice('invalid'), isNotNull);
      expect(Validators.validatePrice(''), isNotNull);
      expect(Validators.validatePrice(null), isNotNull);
    });

    test('should validate description correctly', () {
      expect(Validators.validateDescription('وصف مفصل للخدمة'), null);
      expect(Validators.validateDescription('قصير'), isNotNull);
      expect(Validators.validateDescription(''), isNotNull);
      expect(Validators.validateDescription(null), isNotNull);
    });

    test('should validate URL correctly', () {
      expect(Validators.validateUrl('https://example.com'), null);
      expect(Validators.validateUrl('http://example.com'), null);
      expect(Validators.validateUrl('invalid-url'), isNotNull);
      expect(Validators.validateUrl(''), null); // URL is optional
      expect(Validators.validateUrl(null), null); // URL is optional
    });

    test('should validate confirm password correctly', () {
      expect(
        Validators.validateConfirmPassword('password123', 'password123'),
        null,
      );
      expect(
        Validators.validateConfirmPassword('password123', 'different'),
        isNotNull,
      );
      expect(Validators.validateConfirmPassword('', 'password123'), isNotNull);
      expect(
        Validators.validateConfirmPassword(null, 'password123'),
        isNotNull,
      );
    });
  });

  group('Config Tests', () {
    test('should have valid API configuration', () {
      expect(Config.apiBaseUrl, isNotEmpty);
      expect(Config.appName, isNotEmpty);
      expect(Config.appVersion, isNotEmpty);
      expect(Config.connectionTimeout, isPositive);
      expect(Config.receiveTimeout, isPositive);
    });

    test('should have valid validation limits', () {
      expect(Config.minPasswordLength, isPositive);
      expect(Config.maxPasswordLength, isPositive);
      expect(Config.minPhoneLength, isPositive);
      expect(Config.maxPhoneLength, isPositive);
      expect(Config.minNameLength, isPositive);
      expect(Config.maxNameLength, isPositive);
      expect(Config.minDescriptionLength, isPositive);
      expect(Config.maxDescriptionLength, isPositive);
      expect(Config.minPrice, isNonNegative);
      expect(Config.maxPrice, isPositive);
    });

    test('should have valid service categories', () {
      expect(Config.serviceCategories, isNotEmpty);
      expect(Config.serviceCategories, contains('تصوير'));
      expect(Config.serviceCategories, contains('مطاعم'));
      expect(Config.serviceCategories, contains('قاعات'));
    });

    test('should have valid booking statuses', () {
      expect(Config.statusPending, isNotEmpty);
      expect(Config.statusConfirmed, isNotEmpty);
      expect(Config.statusCompleted, isNotEmpty);
      expect(Config.statusCancelled, isNotEmpty);
    });

    test('should have valid payment methods', () {
      expect(Config.paymentMethods, isNotEmpty);
      expect(Config.paymentMethods, contains('نقداً'));
      expect(Config.paymentMethods, contains('بطاقة ائتمان'));
    });

    test('should have valid user roles', () {
      expect(Config.roleUser, isNotEmpty);
      expect(Config.roleProvider, isNotEmpty);
      expect(Config.roleAdmin, isNotEmpty);
    });

    test('should have valid error messages', () {
      expect(Config.networkErrorMessage, isNotEmpty);
      expect(Config.serverErrorMessage, isNotEmpty);
      expect(Config.unknownErrorMessage, isNotEmpty);
      expect(Config.validationErrorMessage, isNotEmpty);
      expect(Config.authenticationErrorMessage, isNotEmpty);
    });

    test('should have valid success messages', () {
      expect(Config.loginSuccessMessage, isNotEmpty);
      expect(Config.registrationSuccessMessage, isNotEmpty);
      expect(Config.updateSuccessMessage, isNotEmpty);
      expect(Config.deleteSuccessMessage, isNotEmpty);
      expect(Config.saveSuccessMessage, isNotEmpty);
    });

    test('should have valid UI configuration', () {
      expect(Config.defaultPadding, isPositive);
      expect(Config.defaultMargin, isPositive);
      expect(Config.defaultBorderRadius, isPositive);
      expect(Config.defaultElevation, isNonNegative);
    });

    test('should have valid feature flags', () {
      expect(Config.enableAdvancedSearch, isA<bool>());
      expect(Config.enableFilters, isA<bool>());
      expect(Config.enableSorting, isA<bool>());
      expect(Config.enablePagination, isA<bool>());
    });
  });
}
