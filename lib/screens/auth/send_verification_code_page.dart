import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import 'verify_sms_code_page.dart';

class SendVerificationCodePage extends StatefulWidget {
  const SendVerificationCodePage({super.key});

  @override
  State<SendVerificationCodePage> createState() =>
      _SendVerificationCodePageState();
}

class _SendVerificationCodePageState extends State<SendVerificationCodePage> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final success = await ApiService.sendSMSCode(phoneController.text.trim());

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إرسال الرمز بنجاح',
            style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.fromARGB(255, 195, 161, 223),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerifySmsCodePage(phone: phoneController.text.trim()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ فشل إرسال الرمز',
            style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.fromARGB(255, 204, 151, 147),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: ${e.toString()}',
          style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color.fromARGB(255, 199, 148, 144),
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
          title: const Text('إرسال رمز التحقق'),
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
                          const Icon(
                            Icons.sms_outlined,
                            size: 80,
                            color: Color.fromARGB(255, 203, 153, 223),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'إرسال رمز التحقق',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'أدخل رقم هاتفك لإرسال رمز التحقق',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'رقم الهاتف',
                              hintText: 'مثال: 777123456',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return Validators.validatePhone(value);
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ElevatedButton(
                                    onPressed: sendCode,
                                    style:ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple.shade200,
                                      foregroundColor: Colors.white,
                                      
                                      shadowColor: Colors.purple.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'إرسال الرمز عبر SMS',
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
