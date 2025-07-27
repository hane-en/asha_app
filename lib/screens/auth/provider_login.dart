import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
// import '../provider/provider_home_page.dart';
import '../../routes/app_routes.dart';

class ProviderLoginPage extends StatefulWidget {
  const ProviderLoginPage({super.key});

  @override
  State<ProviderLoginPage> createState() => _ProviderLoginPageState();
}

class _ProviderLoginPageState extends State<ProviderLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final authService = AuthService();
      final data = await authService.login(
        email: loginController.text.trim(),
        password: passwordController.text,
        userType: 'provider',
      );

      if (!mounted) return;

      if (data['success'] && data['role'] == 'provider') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تسجيل الدخول كمزود خدمة بنجاح'
            ,style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.fromARGB(255, 219, 186, 228),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.providerHome,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ فشل تسجيل الدخول أو ليس لديك حساب مزود خدمة'
             ,style: TextStyle(color: Colors.black),),
            backgroundColor:  Color.fromARGB(255, 224, 140, 134),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: ${e.toString()}', style: TextStyle(color: Colors.black),),
          backgroundColor:  Color.fromARGB(255, 224, 140, 134),
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
        title: const Text('تسجيل دخول مزود خدمة'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                 Colors.deepPurple.shade100,
                  Colors.deepPurple.shade200,
                ],
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
                            Icons.business,
                            size: 80,
                            color: Colors.purple.shade300,
                          ),
                        const SizedBox(height: 24),
                        const Text(
                          'تسجيل دخول مزود خدمة',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 10, 10, 10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'سجل دخولك للوصول إلى لوحة تحكم مزود الخدمة',
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
                              return 'يرجى إدخال كلمة المرور';
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
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: loginProvider,
                                 style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple.shade200,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor: Colors.purple.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                  ),
                                  child: const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                        fontSize: 18,
                                         color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ),
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
