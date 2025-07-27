import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.userId});
  final int userId;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  Future<void> changePassword() async {
    if (newPasswordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور الجديدة غير متطابقة')),
      );
      return;
    }

    setState(() => isLoading = true);
    final success = await ApiService.changePassword(
      widget.userId,
      oldPasswordController.text,
      newPasswordController.text,
    );
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل تغيير كلمة المرور')));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('تغيير كلمة المرور')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
                obscureText: true,
              ),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: changePassword,
                      child: const Text('تغيير'),
                    ),
            ],
          ),
        ),
      ),
    );
}
