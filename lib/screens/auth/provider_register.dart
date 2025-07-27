import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class ProviderRegisterPage extends StatefulWidget {
  const ProviderRegisterPage({super.key});

  @override
  State<ProviderRegisterPage> createState() => _ProviderRegisterPageState();
}

class _ProviderRegisterPageState extends State<ProviderRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final serviceController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    serviceController.dispose();
    super.dispose();
  }

  Future<void> registerProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final authService = AuthService();
    final result = await authService.register(
      name: nameController.text.trim(),
      email: '', // مزود الخدمة لا يحتاج بريد إلكتروني
      phone: phoneController.text.trim(),
      password: passwordController.text,
      userType: 'provider',
      userCategory: serviceController.text.trim(),
      isYemeniAccount: false,
    );
    final success = result['success'] == true;
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ تم إرسال طلب التسجيل للمراجعة',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 200, 149, 212),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ فشل التسجيل', style: TextStyle(color: Colors.black)),
          backgroundColor: Color.fromARGB(255, 201, 138, 134),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل مزود خدمة'),
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
                        const Icon(
                          Icons.business,
                          size: 80,
                          color: Color.fromARGB(255, 187, 153, 209),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'تسجيل مزود خدمة',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'املأ البيانات التالية لإرسال طلبك كمزود خدمة',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // الاسم
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'الاسم',
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
                        // رقم الهاتف
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 16),
                        // نوع الخدمة
                        TextFormField(
                          controller: serviceController,
                          decoration: InputDecoration(
                            labelText: 'نوع الخدمة',
                            prefixIcon: const Icon(
                              Icons.miscellaneous_services,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال نوع الخدمة';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // كلمة المرور
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
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
                          controller: confirmController,
                          obscureText: !isConfirmVisible,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
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
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: registerProvider,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple.shade200,
                                    foregroundColor: Colors.white,

                                    shadowColor: Colors.purple.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'تسجيل',
                                    style: TextStyle(
                                      fontSize: 16,
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
