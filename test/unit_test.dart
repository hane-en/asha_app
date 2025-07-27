import 'package:flutter_test/flutter_test.dart';
import 'package:asha_application/models/user_model.dart';
import 'package:asha_application/models/service_model.dart';
import 'package:asha_application/utils/validators.dart';
import 'package:asha_application/config/config.dart';

void main() {
  group('User Tests', () {
    test('should create User from JSON', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '123456789',
        'user_type': 'user',
        'profile_image': 'image.jpg',
        'is_verified': true,
        'is_active': true,
        'rating': 4.5,
        'review_count': 10,
        'bio': 'Test bio',
        'website': 'test.com',
        'address': 'Test address',
        'city': 'Test city',
        'latitude': 12.34,
        'longitude': 56.78,
        'is_yemeni_account': true,
        'created_at': '2023-01-01',
        'updated_at': '2023-01-01',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phone, '123456789');
      expect(user.userType, 'user');
      expect(user.profileImage, 'image.jpg');
      expect(user.isVerified, true);
      expect(user.isActive, true);
      expect(user.rating, 4.5);
      expect(user.reviewCount, 10);
      expect(user.bio, 'Test bio');
      expect(user.website, 'test.com');
      expect(user.address, 'Test address');
      expect(user.city, 'Test city');
      expect(user.latitude, 12.34);
      expect(user.longitude, 56.78);
      expect(user.isYemeniAccount, true);
      expect(user.createdAt, '2023-01-01');
      expect(user.updatedAt, '2023-01-01');
    });

    test('should convert User to JSON', () {
      final user = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        phone: '123456789',
        userType: 'user',
        profileImage: 'image.jpg',
        isVerified: true,
        isActive: true,
        rating: 4.5,
        reviewCount: 10,
        bio: 'Test bio',
        website: 'test.com',
        address: 'Test address',
        city: 'Test city',
        latitude: 12.34,
        longitude: 56.78,
        isYemeniAccount: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['phone'], '123456789');
      expect(json['user_type'], 'user');
      expect(json['profile_image'], 'image.jpg');
      expect(json['is_verified'], true);
      expect(json['is_active'], true);
      expect(json['rating'], 4.5);
      expect(json['review_count'], 10);
      expect(json['bio'], 'Test bio');
      expect(json['website'], 'test.com');
      expect(json['address'], 'Test address');
      expect(json['city'], 'Test city');
      expect(json['latitude'], 12.34);
      expect(json['longitude'], 56.78);
      expect(json['is_yemeni_account'], true);
      expect(json['created_at'], '2023-01-01');
      expect(json['updated_at'], '2023-01-01');
    });

    test('should handle null values in User', () {
      final user = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        phone: '123456789',
        userType: 'user',
        isVerified: true,
        isActive: true,
        rating: 4.5,
        reviewCount: 10,
        isYemeniAccount: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      expect(user.profileImage, null);
      expect(user.bio, null);
      expect(user.website, null);
      expect(user.address, null);
      expect(user.city, null);
      expect(user.latitude, null);
      expect(user.longitude, null);
    });

    test('should create complete User with all fields', () {
      final completeUser = User(
        id: 1,
        name: 'Complete User',
        email: 'complete@example.com',
        phone: '123456789',
        userType: 'provider',
        profileImage: 'profile.jpg',
        isVerified: true,
        isActive: true,
        rating: 5.0,
        reviewCount: 20,
        bio: 'Complete bio',
        website: 'complete.com',
        address: 'Complete address',
        city: 'Complete city',
        latitude: 12.34,
        longitude: 56.78,
        isYemeniAccount: false,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      expect(completeUser.id, 1);
      expect(completeUser.name, 'Complete User');
      expect(completeUser.userType, 'provider');
      expect(completeUser.isYemeniAccount, false);
    });

    test('should create incomplete User with minimal fields', () {
      final incompleteUser = User(
        id: 2,
        name: 'Incomplete User',
        email: 'incomplete@example.com',
        phone: '987654321',
        userType: 'user',
        isVerified: false,
        isActive: true,
        rating: 0.0,
        reviewCount: 0,
        isYemeniAccount: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      expect(incompleteUser.id, 2);
      expect(incompleteUser.name, 'Incomplete User');
      expect(incompleteUser.isVerified, false);
      expect(incompleteUser.rating, 0.0);
    });

    test('should validate User data integrity', () {
      final user = User(
        id: 1,
        name: 'Valid User',
        email: 'valid@example.com',
        phone: '123456789',
        userType: 'user',
        isVerified: true,
        isActive: true,
        rating: 4.5,
        reviewCount: 10,
        isYemeniAccount: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      final validUser = User(
        id: 2,
        name: 'Another Valid User',
        email: 'another@example.com',
        phone: '987654321',
        userType: 'provider',
        isVerified: false,
        isActive: false,
        rating: 3.0,
        reviewCount: 5,
        isYemeniAccount: false,
        createdAt: '2023-01-02',
        updatedAt: '2023-01-02',
      );

      expect(user.id != validUser.id, true);
      expect(user.name != validUser.name, true);
      expect(user.email != validUser.email, true);
      expect(user.userType != validUser.userType, true);
    });
  });

  group('Service Tests', () {
    test('should create Service from JSON', () {
      final json = {
        'id': 1,
        'provider_id': 1,
        'category_id': 1,
        'title': 'Test Service',
        'description': 'Test description',
        'price': 100.0,
        'original_price': 120.0,
        'duration': 60,
        'images': ['image1.jpg', 'image2.jpg'],
        'is_active': true,
        'is_verified': true,
        'is_featured': false,
        'rating': 4.5,
        'total_ratings': 10,
        'booking_count': 5,
        'favorite_count': 3,
        'specifications': {'key': 'value'},
        'tags': ['tag1', 'tag2'],
        'location': 'Test location',
        'latitude': 12.34,
        'longitude': 56.78,
        'address': 'Test address',
        'city': 'Test city',
        'max_guests': 10,
        'cancellation_policy': 'Flexible',
        'deposit_required': true,
        'deposit_amount': 20.0,
        'payment_terms': {'terms': 'test'},
        'availability': {'available': true},
        'created_at': '2023-01-01',
        'updated_at': '2023-01-01',
        'category_name': 'Test Category',
        'provider_name': 'Test Provider',
        'provider_rating': 4.8,
        'provider_image': 'provider.jpg',
      };

      final service = Service.fromJson(json);

      expect(service.id, 1);
      expect(service.providerId, 1);
      expect(service.categoryId, 1);
      expect(service.title, 'Test Service');
      expect(service.description, 'Test description');
      expect(service.price, 100.0);
      expect(service.originalPrice, 120.0);
      expect(service.duration, 60);
      expect(service.images, ['image1.jpg', 'image2.jpg']);
      expect(service.isActive, true);
      expect(service.isVerified, true);
      expect(service.isFeatured, false);
      expect(service.rating, 4.5);
      expect(service.totalRatings, 10);
      expect(service.bookingCount, 5);
      expect(service.favoriteCount, 3);
      expect(service.specifications, {'key': 'value'});
      expect(service.tags, ['tag1', 'tag2']);
      expect(service.location, 'Test location');
      expect(service.latitude, 12.34);
      expect(service.longitude, 56.78);
      expect(service.address, 'Test address');
      expect(service.city, 'Test city');
      expect(service.maxGuests, 10);
      expect(service.cancellationPolicy, 'Flexible');
      expect(service.depositRequired, true);
      expect(service.depositAmount, 20.0);
      expect(service.paymentTerms, {'terms': 'test'});
      expect(service.availability, {'available': true});
      expect(service.createdAt, '2023-01-01');
      expect(service.updatedAt, '2023-01-01');
      expect(service.categoryName, 'Test Category');
      expect(service.providerName, 'Test Provider');
      expect(service.providerRating, 4.8);
      expect(service.providerImage, 'provider.jpg');
    });

    test('should convert Service to JSON', () {
      final service = Service(
        id: 1,
        providerId: 1,
        categoryId: 1,
        title: 'Test Service',
        description: 'Test description',
        price: 100.0,
        originalPrice: 120.0,
        duration: 60,
        images: ['image1.jpg', 'image2.jpg'],
        isActive: true,
        isVerified: true,
        isFeatured: false,
        rating: 4.5,
        totalRatings: 10,
        bookingCount: 5,
        favoriteCount: 3,
        specifications: {'key': 'value'},
        tags: ['tag1', 'tag2'],
        location: 'Test location',
        latitude: 12.34,
        longitude: 56.78,
        address: 'Test address',
        city: 'Test city',
        maxGuests: 10,
        cancellationPolicy: 'Flexible',
        depositRequired: true,
        depositAmount: 20.0,
        paymentTerms: {'terms': 'test'},
        availability: {'available': true},
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
        categoryName: 'Test Category',
        providerName: 'Test Provider',
        providerRating: 4.8,
        providerImage: 'provider.jpg',
      );

      final json = service.toJson();

      expect(json['id'], 1);
      expect(json['provider_id'], 1);
      expect(json['category_id'], 1);
      expect(json['title'], 'Test Service');
      expect(json['description'], 'Test description');
      expect(json['price'], 100.0);
      expect(json['original_price'], 120.0);
      expect(json['duration'], 60);
      expect(json['images'], ['image1.jpg', 'image2.jpg']);
      expect(json['is_active'], true);
      expect(json['is_verified'], true);
      expect(json['is_featured'], false);
      expect(json['rating'], 4.5);
      expect(json['total_ratings'], 10);
      expect(json['booking_count'], 5);
      expect(json['favorite_count'], 3);
      expect(json['specifications'], {'key': 'value'});
      expect(json['tags'], ['tag1', 'tag2']);
      expect(json['location'], 'Test location');
      expect(json['latitude'], 12.34);
      expect(json['longitude'], 56.78);
      expect(json['address'], 'Test address');
      expect(json['city'], 'Test city');
      expect(json['max_guests'], 10);
      expect(json['cancellation_policy'], 'Flexible');
      expect(json['deposit_required'], true);
      expect(json['deposit_amount'], 20.0);
      expect(json['payment_terms'], {'terms': 'test'});
      expect(json['availability'], {'available': true});
      expect(json['created_at'], '2023-01-01');
      expect(json['updated_at'], '2023-01-01');
      expect(json['category_name'], 'Test Category');
      expect(json['provider_name'], 'Test Provider');
      expect(json['provider_rating'], 4.8);
      expect(json['provider_image'], 'provider.jpg');
    });

    test('should handle null values in Service', () {
      final service = Service(
        id: 1,
        providerId: 1,
        categoryId: 1,
        title: 'Test Service',
        description: 'Test description',
        price: 100.0,
        duration: 60,
        images: [],
        isActive: true,
        isVerified: true,
        isFeatured: false,
        rating: 4.5,
        totalRatings: 10,
        bookingCount: 5,
        favoriteCount: 3,
        tags: [],
        location: 'Test location',
        address: 'Test address',
        city: 'Test city',
        depositRequired: false,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      expect(service.originalPrice, null);
      expect(service.specifications, null);
      expect(service.latitude, null);
      expect(service.longitude, null);
      expect(service.maxGuests, null);
      expect(service.cancellationPolicy, null);
      expect(service.depositAmount, null);
      expect(service.paymentTerms, null);
      expect(service.availability, null);
      expect(service.categoryName, null);
      expect(service.providerName, null);
      expect(service.providerRating, null);
      expect(service.providerImage, null);
    });

    test('should create complete Service with all fields', () {
      final service = Service(
        id: 1,
        providerId: 1,
        categoryId: 1,
        title: 'Complete Service',
        description: 'Complete description',
        price: 200.0,
        originalPrice: 250.0,
        duration: 120,
        images: ['complete1.jpg', 'complete2.jpg'],
        isActive: true,
        isVerified: true,
        isFeatured: true,
        rating: 5.0,
        totalRatings: 20,
        bookingCount: 10,
        favoriteCount: 8,
        specifications: {'complete': 'specs'},
        tags: ['complete', 'service'],
        location: 'Complete location',
        latitude: 12.34,
        longitude: 56.78,
        address: 'Complete address',
        city: 'Complete city',
        maxGuests: 20,
        cancellationPolicy: 'Strict',
        depositRequired: true,
        depositAmount: 50.0,
        paymentTerms: {'complete': 'terms'},
        availability: {'complete': 'available'},
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
        categoryName: 'Complete Category',
        providerName: 'Complete Provider',
        providerRating: 5.0,
        providerImage: 'complete_provider.jpg',
      );

      expect(service.id, 1);
      expect(service.title, 'Complete Service');
      expect(service.isFeatured, true);
      expect(service.providerRating, 5.0);
    });

    test('should create minimal Service with required fields', () {
      final service = Service(
        id: 2,
        providerId: 2,
        categoryId: 2,
        title: 'Minimal Service',
        description: 'Minimal description',
        price: 50.0,
        duration: 30,
        images: [],
        isActive: false,
        isVerified: false,
        isFeatured: false,
        rating: 0.0,
        totalRatings: 0,
        bookingCount: 0,
        favoriteCount: 0,
        tags: [],
        location: 'Minimal location',
        address: 'Minimal address',
        city: 'Minimal city',
        depositRequired: false,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      expect(service.id, 2);
      expect(service.title, 'Minimal Service');
      expect(service.isActive, false);
      expect(service.isVerified, false);
      expect(service.rating, 0.0);
    });

    test('should validate Service data integrity', () {
      final service1 = Service(
        id: 1,
        providerId: 1,
        categoryId: 1,
        title: 'Service 1',
        description: 'Description 1',
        price: 100.0,
        duration: 60,
        images: [],
        isActive: true,
        isVerified: true,
        isFeatured: false,
        rating: 4.5,
        totalRatings: 10,
        bookingCount: 5,
        favoriteCount: 3,
        tags: [],
        location: 'Location 1',
        address: 'Address 1',
        city: 'City 1',
        depositRequired: false,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      final service2 = Service(
        id: 2,
        providerId: 2,
        categoryId: 2,
        title: 'Service 2',
        description: 'Description 2',
        price: 200.0,
        duration: 120,
        images: [],
        isActive: false,
        isVerified: false,
        isFeatured: true,
        rating: 3.0,
        totalRatings: 5,
        bookingCount: 2,
        favoriteCount: 1,
        tags: [],
        location: 'Location 2',
        address: 'Address 2',
        city: 'City 2',
        depositRequired: true,
        createdAt: '2023-01-02',
        updatedAt: '2023-01-02',
      );

      expect(service1.id != service2.id, true);
      expect(service1.title != service2.title, true);
      expect(service1.price != service2.price, true);
      expect(service1.isActive != service2.isActive, true);
    });

    test('should handle Service with discount calculation', () {
      final service = Service(
        id: 1,
        providerId: 1,
        categoryId: 1,
        title: 'Discounted Service',
        description: 'Service with discount',
        price: 80.0,
        originalPrice: 100.0,
        duration: 60,
        images: [],
        isActive: true,
        isVerified: true,
        isFeatured: false,
        rating: 4.5,
        totalRatings: 10,
        bookingCount: 5,
        favoriteCount: 3,
        tags: [],
        location: 'Test location',
        address: 'Test address',
        city: 'Test city',
        depositRequired: false,
        createdAt: '2023-01-01',
        updatedAt: '2023-01-01',
      );

      expect(service.price, 80.0);
      expect(service.originalPrice, 100.0);
      expect(service.originalPrice! > service.price, true);
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
