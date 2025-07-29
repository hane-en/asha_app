import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
// import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../user/user_home_page.dart';
import '../provider/provider_home_page.dart';
import '../admin/admin_home_page.dart';
import 'signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // اختبار الاتصال عند فتح الصفحة
    _testConnection();
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // دالة اختبار الاتصال
  Future<void> _testConnection() async {
    try {
      final result = await ApiService.testConnection();
      print('🔍 Connection test result: $result');

      if (result['success']) {
        print('✅ Server is working!');
      } else {
        print('❌ Server connection failed: ${result['message']}');
        // إظهار رسالة للمستخدم
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('مشكلة في الاتصال بالخادم: ${result['message']}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error testing connection: $e');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authService = AuthService();
      final data = await authService.login(
        email: loginController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      if (data['success']) {
        var msg = '';
        Widget nextPage;

        // تحديد نوع المستخدم من البيانات المرجعة
        final userType = data['data']['user']['user_type'] ?? 'user';
        final userId = data['data']['user']['id'];

        // حفظ بيانات المستخدم في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', userId);
        await prefs.setString('user_name', data['data']['user']['name'] ?? '');
        await prefs.setString('role', userType);

        switch (userType) {
          case 'user':
            msg = '🎉 مرحبًا بك كمستخدم!';
            nextPage = const UserHomePage();
            break;
          case 'provider':
            msg = '✅ مرحباً بك كمزود خدمة! يمكنك الآن إضافة خدماتك وإعلاناتك.';
            nextPage = const ProviderHomePage();
            break;
          case 'admin':
            msg = '🛠️ تم تسجيل الدخول كمسؤول.';
            nextPage = const AdminHomePage();
            break;
          default:
            msg = '⚠️ نوع المستخدم غير معروف: $userType';
            nextPage = const LoginPage();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),

            backgroundColor: Color.fromARGB(255, 199, 154, 207),
            behavior: SnackBarBehavior.floating,
          ),
        );

        String route;
        switch (userType) {
          case 'user':
            route = AppRoutes.userHome;
            break;
          case 'provider':
            route = AppRoutes.providerHome;
            break;
          case 'admin':
            route = AppRoutes.adminHome;
            break;
          default:
            route = AppRoutes.login;
        }
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else {
        final errorMsg =
            data['message'] ??
            '❌ فشل تسجيل الدخول. تحقق من الرقم وكلمة المرور.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color.fromARGB(255, 224, 140, 134),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: ${e.toString()}'),
          backgroundColor: const Color.fromARGB(255, 224, 140, 134),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.userHome,
              (route) => false,
            );
          },
        ),
        title: const Text('تسجيل الدخول'),

        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade200],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.purple.shade300,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'مرحباً بك',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 12, 11, 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'سجل دخولك للوصول إلى خدماتنا',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // البريد الإلكتروني أو رقم الهاتف
                        TextFormField(
                          controller: loginController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني أو رقم الهاتف',
                            hintText: 'أدخل البريد الإلكتروني أو رقم الهاتف',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف';
                            }
                            // تحقق إذا كان بريد أو رقم هاتف
                            if (value.contains('@')) {
                              return Validators.validateEmail(value);
                            } else {
                              return Validators.validatePhone(value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // كلمة المرور
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            hintText: 'أدخل كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade200,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.purple.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // روابط إضافية
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 12, 11, 12),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 18, 18, 19),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // خط فاصل
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'أو',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // روابط سريعة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.providerLogin,
                                );
                              },
                              icon: const Icon(Icons.business),
                              label: const Text('مزود خدمة'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.adminLogin,
                                );
                              },
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text('مسؤول'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
