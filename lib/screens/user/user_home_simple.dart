import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// صفحة مبسطة للاختبار
class UserHomeSimple extends StatefulWidget {
  const UserHomeSimple({super.key});

  @override
  State<UserHomeSimple> createState() => _UserHomeSimpleState();
}

class _UserHomeSimpleState extends State<UserHomeSimple> {
  String? _userName;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    print('🏠 UserHomeSimple initState called');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _userName = prefs.getString('user_name');
          _userRole = prefs.getString('role');
        });
        print('✅ User data loaded: $_userName, $_userRole');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 UserHomeSimple build method called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text(
              'مرحباً بك في الصفحة الرئيسية',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (_userName != null)
              Text(
                'المستخدم: $_userName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (_userRole != null)
              Text(
                'النوع: $_userRole',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم فتح الصفحة بنجاح!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('اختبار الزر'),
            ),
          ],
        ),
      ),
    );
  }
}
