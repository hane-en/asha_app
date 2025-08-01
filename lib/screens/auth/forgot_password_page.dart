import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final inputController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  Future<void> sendRecovery() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    // سيتم إضافة هذه الدالة لاحقاً
    final success = false; // placeholder
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ تم إرسال رابط/رمز الاسترجاع إلى بريدك أو هاتفك'
              : '❌ لم يتم العثور على الحساب',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: success
            ? Color(0xFFE1BEE7)
            : const Color.fromARGB(255, 182, 105, 99),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('استرجاع كلمة المرور'),
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
                        Icons.lock_open,
                        size: 80,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'استرجاع كلمة المرور',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أدخل بريدك الإلكتروني أو رقم هاتفك المرتبط بالحساب',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: inputController,
                        decoration: const InputDecoration(
                          labelText: 'البريد أو الهاتف',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال البريد أو رقم الهاتف';
                          }
                          if (value.contains('@')) {
                            return Validators.validateEmail(value);
                          } else {
                            return Validators.validatePhone(value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: sendRecovery,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade200,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.purple.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'إرسال رمز الاسترجاع',
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
  );
}
