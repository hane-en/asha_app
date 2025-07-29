import 'package:flutter/material.dart';
import 'signup_page.dart';

class SignupTest extends StatelessWidget {
  const SignupTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار صفحة التسجيل',
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Cairo'),
      home: const SignupPage(),
    );
  }
}
