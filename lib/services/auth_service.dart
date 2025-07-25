import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../utils/helpers.dart';

class AuthService {
  static const String _baseUrl = Config.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Helper method to handle HTTP requests
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool isPost = false,
    bool isPut = false,
    bool isDelete = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'EventServicesApp/${Config.appVersion}',
        ...?headers,
      };

      if (Config.enableLogging) {
        print(
          'Auth Request: ${isPost
              ? 'POST'
              : isPut
              ? 'PUT'
              : isDelete
              ? 'DELETE'
              : 'GET'} $uri',
        );
        if (body != null) {
          print('Request Body: $body');
        }
      }

      http.Response response;
      if (isPost) {
        response = await http
            .post(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else if (isPut) {
        response = await http
            .put(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else if (isDelete) {
        response = await http
            .delete(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else {
        response = await http
            .get(uri, headers: requestHeaders)
            .timeout(_timeout);
      }

      if (Config.enableLogging) {
        print('Auth Response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception(Config.networkErrorMessage);
    } on TimeoutException {
      throw Exception(Config.timeoutErrorMessage);
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات');
    } catch (e) {
      if (Config.enableLogging) {
        print('Auth Error: $e');
      }
      throw Exception(Config.unknownErrorMessage);
    }
  }

  // Login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      // Input validation
      if (!_isValidEmail(email)) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }
      if (!_isValidPassword(password)) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      final data = await _makeRequest(
        'auth/login.php',
        body: json.encode({'email': email, 'password': password}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'message': Config.loginSuccessMessage,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? Config.authenticationErrorMessage,
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmPassword,
    String role, // أضف هذا السطر
  ) async {
    try {
      // Input validation
      if (!_isValidName(name)) {
        throw Exception('الاسم غير صحيح');
      }
      if (!_isValidEmail(email)) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }
      if (!_isValidPhone(phone)) {
        throw Exception('رقم الهاتف غير صحيح');
      }
      if (!_isValidPassword(password)) {
        throw Exception('كلمة المرور غير صحيحة');
      }
      if (password != confirmPassword) {
        throw Exception('كلمة المرور غير متطابقة');
      }

      final data = await _makeRequest(
        'auth/register.php',
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
          'role': role, // أضف هذا السطر
        }),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'user': data['user'],
          'message': Config.registrationSuccessMessage,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? Config.validationErrorMessage,
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Phone verification method
  static Future<Map<String, dynamic>> verifyPhone(
    String phone,
    String code,
  ) async {
    try {
      if (!_isValidPhone(phone)) {
        throw Exception('رقم الهاتف غير صحيح');
      }
      if (code.length != 6) {
        throw Exception('رمز التحقق غير صحيح');
      }

      final data = await _makeRequest(
        'verify_phone.php',
        body: json.encode({'phone': phone, 'code': code}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {'success': true, 'message': 'تم التحقق من رقم الهاتف بنجاح'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في التحقق من رقم الهاتف',
        };
      }
    } catch (e) {
      print('Phone verification error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Send verification code method
  static Future<Map<String, dynamic>> sendVerificationCode(String phone) async {
    try {
      if (!_isValidPhone(phone)) {
        throw Exception('رقم الهاتف غير صحيح');
      }

      final data = await _makeRequest(
        'send_verification_code.php',
        body: json.encode({'phone': phone}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {'success': true, 'message': 'تم إرسال رمز التحقق بنجاح'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في إرسال رمز التحقق',
        };
      }
    } catch (e) {
      print('Send verification code error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Password reset method
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      final data = await _makeRequest(
        'auth/reset_password.php',
        body: json.encode({'email': email}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'message': 'تم إرسال رابط إعادة تعيين كلمة المرور',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في إرسال رابط إعادة التعيين',
        };
      }
    } catch (e) {
      print('Password reset error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Change password method
  static Future<Map<String, dynamic>> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      if (!_isValidPassword(currentPassword)) {
        throw Exception('كلمة المرور الحالية غير صحيحة');
      }
      if (!_isValidPassword(newPassword)) {
        throw Exception('كلمة المرور الجديدة غير صحيحة');
      }
      if (newPassword != confirmPassword) {
        throw Exception('كلمة المرور الجديدة غير متطابقة');
      }

      final data = await _makeRequest(
        'change_password.php',
        body: json.encode({
          'user_id': userId,
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
        isPost: true,
      );

      if (data['success'] == true) {
        return {'success': true, 'message': 'تم تغيير كلمة المرور بنجاح'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تغيير كلمة المرور',
        };
      }
    } catch (e) {
      print('Change password error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update profile method
  static Future<Map<String, dynamic>> updateProfile(
    int userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final data = await _makeRequest(
        'update_profile.php',
        body: json.encode({'user_id': userId, ...profileData}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'user': data['user'],
          'message': Config.updateSuccessMessage,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? Config.validationErrorMessage,
        };
      }
    } catch (e) {
      print('Update profile error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete account method
  static Future<Map<String, dynamic>> deleteAccount(
    int userId,
    String password,
  ) async {
    try {
      if (!_isValidPassword(password)) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      final data = await _makeRequest(
        'delete_account.php',
        body: json.encode({'user_id': userId, 'password': password}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {'success': true, 'message': 'تم حذف الحساب بنجاح'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في حذف الحساب',
        };
      }
    } catch (e) {
      print('Delete account error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout method
  static Future<Map<String, dynamic>> logout(int userId) async {
    try {
      final data = await _makeRequest(
        'logout.php',
        body: json.encode({'user_id': userId}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {'success': true, 'message': 'تم تسجيل الخروج بنجاح'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تسجيل الخروج',
        };
      }
    } catch (e) {
      print('Logout error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check authentication method
  static Future<Map<String, dynamic>> checkAuth(String token) async {
    try {
      final data = await _makeRequest(
        'check_auth.php',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (data['success'] == true) {
        return {'success': true, 'user': data['user'], 'isValid': true};
      } else {
        return {
          'success': false,
          'isValid': false,
          'message': data['message'] ?? 'الجلسة منتهية الصلاحية',
        };
      }
    } catch (e) {
      print('Check auth error: $e');
      return {'success': false, 'isValid': false, 'message': e.toString()};
    }
  }

  // Refresh token method
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final data = await _makeRequest(
        'refresh_token.php',
        body: json.encode({'refresh_token': refreshToken}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'token': data['token'],
          'refresh_token': data['refresh_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تحديث الجلسة',
        };
      }
    } catch (e) {
      print('Refresh token error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Validation helper methods
  static bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  static bool _isValidPhone(String phone) {
    final clean = Helpers.convertArabicNumbers(
      phone,
    ).replaceAll(RegExp(r'[^0-9]'), '');
    return RegExp(r'^(77|78|70|71|73)[0-9]{7}  ?$').hasMatch(clean);
  }

  static bool _isValidPassword(String password) =>
      password.length >= Config.minPasswordLength &&
      password.length <= Config.maxPasswordLength;

  static bool _isValidName(String name) =>
      name.length >= Config.minNameLength &&
      name.length <= Config.maxNameLength;

  // Register provider method
  static Future<bool> registerProvider(
    String name,
    String phone,
    String password,
    String service,
  ) async {
    try {
      if (!_isValidName(name)) {
        throw Exception('الاسم غير صحيح');
      }
      if (!_isValidPhone(phone)) {
        throw Exception('رقم الهاتف غير صحيح');
      }
      if (!_isValidPassword(password)) {
        throw Exception('كلمة المرور غير صحيحة');
      }
      if (service.trim().isEmpty) {
        throw Exception('نوع الخدمة مطلوب');
      }
      final data = await _makeRequest(
        'join_as_provider.php',
        body: json.encode({
          'name': name,
          'phone': phone,
          'password': password,
          'service': service,
        }),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Register provider error: $e');
      return false;
    }
  }
}
