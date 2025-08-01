import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../config/config.dart';
// import '../../utils/constants.dart';
// import '../user/user_home_page.dart';
// import '../provider/provider_pending_page.dart';
import '../../routes/app_routes.dart';

class SignupPage extends StatefulWidget {
  final String? source; // مصدر الطلب: 'drawer' أو 'booking' أو null للافتراضي

  const SignupPage({super.key, this.source});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final yemeniAccountController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;
  bool isLoading = false;
  String selectedRole = 'user';
  String? selectedCategory;
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    yemeniAccountController.dispose();
    super.dispose();
  }

  // دالة تحميل الفئات
  Future<void> _loadCategories() async {
    setState(() {
      isLoadingCategories = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/services/get_categories.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('خطأ في تحميل الفئات: $e');
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Color.fromARGB(255, 224, 140, 134)
            : Colors.deepPurple.shade200,

        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من اختيار الفئة للمزودين
    if (selectedRole == 'provider' && selectedCategory == null) {
      _showMessage('❌ يرجى اختيار نوع الفئة', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        userType: selectedRole,
        isYemeniAccount: yemeniAccountController.text.trim().isNotEmpty,
        userCategory: selectedCategory,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        if (selectedRole == 'user') {
          _showMessage('✅ تم إنشاء الحساب بنجاح! مرحباً بك كمستخدم.');

          // التوجيه الذكي حسب مصدر الطلب
          if (widget.source == 'booking') {
            // إذا جاء من صفحة الحجز، نرجع إلى الصفحة السابقة
            Navigator.pop(context, true);
          } else {
            // إذا جاء من drawer أو أي مكان آخر، نذهب للصفحة الرئيسية
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.userHome,
              (route) => false,
            );
          }
        } else {
          _showMessage(
            '✅ تم إنشاء الحساب بنجاح! تم إرسال طلب انضمامك كمزود خدمة للمشرف للمراجعة.',
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.userHome,
            (route) => false,
          );
        }
      } else {
        _showMessage('❌ فشل التسجيل: ${result['message']}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ خطأ في الاتصال: ${e.toString()}', isError: true);
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
        title: const Text('إنشاء حساب جديد'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.person_add,
                          size: 80,
                          color: Color.fromARGB(255, 208, 197, 228),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'انضم إلينا واستمتع بخدماتنا المميزة',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // الاسم
                      TextFormField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'الاسم الكامل',
                          hintText: 'أدخل اسمك الكامل',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),

                      // البريد الإلكتروني
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'example@email.com',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // رقم الهاتف
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          hintText: 'مثال: 777777777',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          return Validators.validatePhone(value);
                        },
                      ),
                      const SizedBox(height: 16),

                      // كلمة المرور
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        textInputAction: TextInputAction.next,
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
                        validator: Validators.validateStrongPassword,
                      ),
                      const SizedBox(height: 16),

                      // تأكيد كلمة المرور
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmVisible,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'تأكيد كلمة المرور',
                          hintText: 'أعد إدخال كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isConfirmVisible = !isConfirmVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              passwordController.text,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // نوع الحساب
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'نوع الحساب',
                          prefixIcon: const Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'user',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 169, 145, 173),
                                ),
                                SizedBox(width: 8),
                                Text('مستخدم عادي'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'provider',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  color: Color.fromARGB(255, 169, 145, 173),
                                ),
                                SizedBox(width: 8),
                                Text('مزود خدمة'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => selectedRole = val!),
                      ),
                      const SizedBox(height: 16),

                      // رقم الحساب اليمني (للمزودين فقط)
                      if (selectedRole == 'provider') ...[
                        TextFormField(
                          controller: yemeniAccountController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'رقم الحساب في بنك الكريمي *',
                            hintText: 'أدخل رقم الحساب في بنك الكريمي',
                            prefixIcon: const Icon(Icons.account_balance),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (selectedRole == 'provider') {
                              if (value == null || value.isEmpty) {
                                return 'رقم الحساب في بنك الكريمي مطلوب لمزودي الخدمات';
                              }
                              if (!RegExp(r'^3\d{9}$').hasMatch(value)) {
                                return 'رقم الحساب يجب أن يبدأ برقم 3 ويتكون من 10 أرقام بالضبط';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // اختيار نوع الفئة (للمزودين فقط)
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'نوع الفئة *',
                            hintText: 'اختر نوع الفئة التي تقدم خدماتها',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: isLoadingCategories
                              ? [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('جاري التحميل...'),
                                      ],
                                    ),
                                  ),
                                ]
                              : categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category['id'].toString(),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.category,
                                          color: Color.fromARGB(
                                            255,
                                            169,
                                            145,
                                            173,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            category['title'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          onChanged: isLoadingCategories
                              ? null
                              : (value) =>
                                    setState(() => selectedCategory = value),
                          validator: (value) {
                            if (selectedRole == 'provider') {
                              if (value == null || value.isEmpty) {
                                return 'نوع الفئة مطلوب لمزودي الخدمات';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // زر التسجيل
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade200,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.purple.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
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
                                  'إنشاء الحساب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(255, 254, 254, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // معلومات إضافية
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'معلومات مهمة:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedRole == 'user'
                                  ? '• سيتم إنشاء حسابك فوراً ويمكنك استخدام التطبيق مباشرة'
                                  : '• سيتم مراجعة طلبك من قبل الإدارة قبل الموافقة على حسابك',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
  );
}
