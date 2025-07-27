import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final List<TextEditingController> codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  bool isLoading = false;

  void _verify(BuildContext context) {
    var isEmpty = codeControllers.any((controller) => controller.text.isEmpty);

    if (isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ يجب ملء جميع الحقول',
          style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 199, 147, 144),
        ),
      );
    } else {
      var fullCode = codeControllers.map((c) => c.text).join();
      setState(() => isLoading = true);

      // محاكاة عملية التحقق
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم التحقق من الكود: $fullCode',
            style: TextStyle(color: Colors.black),
            ),
            backgroundColor: const Color.fromARGB(255, 199, 151, 226),
          ),
        );
      });
    }
  }

  void _moveFocus(String value, int index) {
    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  void _handleBackspace(String value, int index) {
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التحقق من الكود'),
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
                        const Icon(
                          Icons.verified_user,
                          size: 80,
                          color: Color.fromARGB(255, 187, 138, 209),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'التحقق من الكود',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 7, 7, 7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أدخل رمز التحقق المكون من 4 أرقام',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return SizedBox(
                              width: 60,
                              child: TextField(
                                controller: codeControllers[index],
                                focusNode: focusNodes[index],
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLength: 1,
                                onChanged: (value) {
                                  _moveFocus(value, index);
                                  if (value.length == 1 && index == 3) {
                                    _verify(context);
                                  }
                                },
                                onSubmitted: (_) => _verify(context),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () => _verify(context),
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
                                    'تحقق',
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
    );
}
