# دليل ربط Frontend Flutter بـ Backend PHP

## مقدمة

هذا الدليل يوضح كيفية ربط تطبيق Flutter بـ API الخاص بـ Asha App Backend. يتضمن أمثلة عملية وتوضيحات للتعديلات المطلوبة في كود Flutter.

## إعدادات أساسية

### 1. إضافة المكتبات المطلوبة في `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  shared_preferences: ^2.0.15
  provider: ^6.0.5
  dio: ^5.0.0
  json_annotation: ^4.8.0
  
dev_dependencies:
  build_runner: ^2.3.3
  json_serializable: ^6.6.0
```

### 2. إنشاء ملف الثوابت `lib/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-domain.com';
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
```

## نماذج البيانات (Models)

### 1. نموذج المستخدم `lib/models/user_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  @JsonKey(name: 'user_type')
  final String userType;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final double rating;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  final String? bio;
  final String? website;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'is_yemeni_account')
  final bool isYemeniAccount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    required this.isVerified,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
    this.bio,
    this.website,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    required this.isYemeniAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### 2. نموذج الخدمة `lib/models/service_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable()
class Service {
  final int id;
  @JsonKey(name: 'provider_id')
  final int providerId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String title;
  final String description;
  final double price;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  final int duration;
  final List<String> images;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  final double rating;
  @JsonKey(name: 'total_ratings')
  final int totalRatings;
  @JsonKey(name: 'booking_count')
  final int bookingCount;
  @JsonKey(name: 'favorite_count')
  final int favoriteCount;
  final Map<String, dynamic>? specifications;
  final List<String> tags;
  final String location;
  final double? latitude;
  final double? longitude;
  final String address;
  final String city;
  @JsonKey(name: 'max_guests')
  final int? maxGuests;
  @JsonKey(name: 'cancellation_policy')
  final String? cancellationPolicy;
  @JsonKey(name: 'deposit_required')
  final bool depositRequired;
  @JsonKey(name: 'deposit_amount')
  final double? depositAmount;
  @JsonKey(name: 'payment_terms')
  final Map<String, dynamic>? paymentTerms;
  final Map<String, dynamic>? availability;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'provider_name')
  final String? providerName;
  @JsonKey(name: 'provider_rating')
  final double? providerRating;
  @JsonKey(name: 'provider_image')
  final String? providerImage;

  Service({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.duration,
    required this.images,
    required this.isActive,
    required this.isVerified,
    required this.isFeatured,
    required this.rating,
    required this.totalRatings,
    required this.bookingCount,
    required this.favoriteCount,
    this.specifications,
    required this.tags,
    required this.location,
    this.latitude,
    this.longitude,
    required this.address,
    required this.city,
    this.maxGuests,
    this.cancellationPolicy,
    required this.depositRequired,
    this.depositAmount,
    this.paymentTerms,
    this.availability,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.providerName,
    this.providerRating,
    this.providerImage,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
```

## خدمات API (Services)

### 1. خدمة HTTP الأساسية `lib/services/http_service.dart`

```dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class HttpService {
  late Dio _dio;
  
  HttpService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // إضافة رمز المصادقة تلقائياً
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // معالجة الأخطاء
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    // إعادة توجيه إلى صفحة تسجيل الدخول
  }
  
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Exception(data['message']);
        }
      }
      return Exception('خطأ في الاتصال بالخادم');
    }
    return Exception('خطأ غير متوقع');
  }
}
```

### 2. خدمة المصادقة `lib/services/auth_service.dart`

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart';
import 'http_service.dart';

class AuthService {
  final HttpService _httpService = HttpService();
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String userType = 'user',
    String? bio,
    String? website,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? userCategory,
    bool isYemeniAccount = false,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'user_type': userType,
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (userCategory != null) 'user_category': userCategory,
      'is_yemeni_account': isYemeniAccount,
    };
    
    return await _httpService.post(ApiConstants.register, data: data);
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? userType,
  }) async {
    final data = {
      'email': email,
      'password': password,
      if (userType != null) 'user_type': userType,
    };
    
    final response = await _httpService.post(ApiConstants.login, data: data);
    
    if (response['success'] == true) {
      final userData = response['data'];
      await _saveUserData(userData['user'], userData['token']);
    }
    
    return response;
  }
  
  Future<Map<String, dynamic>> verify({
    required String email,
    required String code,
  }) async {
    final data = {
      'email': email,
      'code': code,
    };
    
    return await _httpService.post(ApiConstants.verify, data: data);
  }
  
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final data = {
      'email': email,
    };
    
    return await _httpService.post(ApiConstants.forgotPassword, data: data);
  }
  
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final data = {
      'email': email,
      'code': code,
      'new_password': newPassword,
    };
    
    return await _httpService.post(ApiConstants.resetPassword, data: data);
  }
  
  Future<void> _saveUserData(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userData));
  }
  
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return User.fromJson(userData);
    }
    
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}
```

## التعديلات المطلوبة في صفحات Flutter

### 1. صفحة تسجيل الدخول

```dart
// في lib/screens/auth/login_screen.dart
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('يرجى ملء جميع الحقول');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (response['success'] == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError(response['message'] ?? 'فشل في تسجيل الدخول');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('تسجيل الدخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. صفحة عرض الخدمات

```dart
// في lib/screens/services/services_screen.dart
import '../../services/services_service.dart';
import '../../models/service_model.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServicesService _servicesService = ServicesService();
  List<Service> _services = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    _loadServices();
  }
  
  Future<void> _loadServices({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _services.clear();
    }
    
    try {
      final response = await _servicesService.getAllServices(
        page: _currentPage,
        limit: 20,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        final List<dynamic> servicesJson = data['services'];
        final List<Service> newServices = servicesJson
            .map((json) => Service.fromJson(json))
            .toList();
        
        setState(() {
          if (refresh) {
            _services = newServices;
          } else {
            _services.addAll(newServices);
          }
          
          final pagination = data['pagination'];
          _hasMore = _currentPage < pagination['total_pages'];
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading && _services.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('الخدمات')),
      body: RefreshIndicator(
        onRefresh: () => _loadServices(refresh: true),
        child: ListView.builder(
          itemCount: _services.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _services.length) {
              if (_hasMore) {
                _loadServices();
                return Center(child: CircularProgressIndicator());
              }
              return SizedBox.shrink();
            }
            
            final service = _services[index];
            return ServiceCard(service: service);
          },
        ),
      ),
    );
  }
}
```

## ملاحظات مهمة للتطوير

### 1. معالجة الأخطاء
- تأكد من معالجة جميع الأخطاء المحتملة من API
- استخدم try-catch blocks في جميع استدعاءات API
- اعرض رسائل خطأ واضحة للمستخدم

### 2. إدارة الحالة
- استخدم Provider أو Bloc لإدارة حالة التطبيق
- احفظ بيانات المستخدم محلياً باستخدام SharedPreferences
- تأكد من تحديث واجهة المستخدم عند تغيير البيانات

### 3. الأمان
- لا تحفظ كلمات المرور في التطبيق
- استخدم HTTPS فقط للاتصال بـ API
- تحقق من صحة البيانات قبل إرسالها

### 4. الأداء
- استخدم التحميل التدريجي (Pagination) للقوائم الطويلة
- احفظ البيانات محلياً لتقليل استدعاءات API
- استخدم الصور المحسنة وتحميلها بشكل تدريجي

### 5. تجربة المستخدم
- اعرض مؤشرات التحميل أثناء العمليات
- استخدم Pull-to-refresh للتحديث
- اعرض رسائل نجاح واضحة للعمليات المكتملة

