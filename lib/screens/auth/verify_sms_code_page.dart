import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reset_password_page.dart';
import '../../services/api_service.dart';

class VerifySmsCodePage extends StatefulWidget {
  const VerifySmsCodePage({super.key, required this.phone});
  final String phone;

  @override
  State<VerifySmsCodePage> createState() => _VerifySmsCodePageState();
}

class _VerifySmsCodePageState extends State<VerifySmsCodePage> {
  final codeController = TextEditingController();
  bool isLoading = false;
  int seconds = 60;
  bool canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    codeController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    setState(() {
      canResend = false;
      seconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => seconds--);
      }
    });
  }

  Future<void> verifyCode() async {
    final code = codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز مكوّن من 6 أرقام',
          style: TextStyle(color: Colors.black),),
          backgroundColor: Color.fromARGB(255, 201, 151, 148),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ApiService.verifyCode(widget.phone, code);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم التحقق بنجاح',
            style: TextStyle(color: Colors.black),),
            backgroundColor: Color.fromARGB(255, 178, 152, 207),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(userIdentifier: widget.phone),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ رمز التحقق غير صحيح',
            style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.fromARGB(255, 202, 151, 148),
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
          backgroundColor: const Color.fromARGB(255, 199, 155, 152),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> resendCode() async {
    setState(() => canResend = false);
    startTimer();

    try {
      final success = await ApiService.sendSMSCode(widget.phone);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ تم إرسال رمز جديد' : '❌ فشل إرسال الرمز',
          style: TextStyle(color: Colors.black),
          ),
          backgroundColor: success ? const Color.fromARGB(255, 195, 150, 212) : const Color.fromARGB(255, 194, 144, 140),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: ${e.toString()}',
          style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color.fromARGB(255, 190, 144, 140),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحقق من الرمز'),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sms, size: 80, color: Color.fromARGB(255, 181, 152, 214)),
                        const SizedBox(height: 24),
                        const Text(
                          'تحقق من الرمز',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'تم إرسال رمز التحقق إلى\n${widget.phone}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        TextFormField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            labelText: 'رمز التحقق',
                            hintText: '000000',
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (value) {
                            if (value.length == 6) {
                              verifyCode();
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
                                  onPressed: verifyCode,
                                  style:ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple.shade200,
                                      foregroundColor: Colors.white,
                                    
                                      shadowColor: Colors.purple.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                  ),
                                  child: const Text(
                                    'تحقق',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        canResend
                            ? TextButton(
                                onPressed: resendCode,
                                child: const Text(
                                  'إعادة إرسال الرمز',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            : Text(
                                'يمكنك إعادة الإرسال بعد $seconds ثانية',
                                style: const TextStyle(color: Colors.grey),
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
