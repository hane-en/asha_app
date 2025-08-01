import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
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

    return await ApiService.register(
      name: name,
      email: email,
      password: password,
      userType: userType,
      phone: phone,
      address: address,
      categoryId: null,
    );
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String? userType,
  }) async {
    final data = {
      'identifier': identifier,
      'password': password,
      if (userType != null) 'user_type': userType,
    };

    final response = await ApiService.login(
<<<<<<< HEAD
      identifier: identifier,
=======
      email: identifier,
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
      password: password,
    );

    if (response['success'] == true) {
      final userData = response['data'];
      await _saveUserData(userData['user'], userData['token']);
    }
    print(response);
    return response;
  }

  Future<Map<String, dynamic>> verify({
    required String email,
    required String code,
  }) async {
    // سيتم إضافة هذه الدالة لاحقاً
    throw UnimplementedError('verify method not implemented yet');
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    // سيتم إضافة هذه الدالة لاحقاً
    throw UnimplementedError('forgotPassword method not implemented yet');
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    // سيتم إضافة هذه الدالة لاحقاً
    throw UnimplementedError('resetPassword method not implemented yet');
  }

  Future<void> _saveUserData(
    Map<String, dynamic> userData,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userData));
    // حفظ معرف المستخدم بشكل منفصل للوصول السريع
    // تحويل id إلى int إذا كان string
    final userId = userData['id'];
    if (userId != null) {
      if (userId is int) {
        await prefs.setInt('user_id', userId);
      } else if (userId is String) {
        await prefs.setInt('user_id', int.tryParse(userId) ?? 0);
      } else {
        await prefs.setInt('user_id', 0);
      }
    } else {
      await prefs.setInt('user_id', 0);
    }
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_type', userData['user_type'] ?? 'user');
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
