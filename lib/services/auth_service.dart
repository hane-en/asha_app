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