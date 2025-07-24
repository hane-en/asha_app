import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key, required this.userId});
  final int userId;

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> deleteAccount() async {
    setState(() => isLoading = true);
    final success = await ApiService.deleteAccount(
      widget.userId,
      passwordController.text,
    );
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الحساب بنجاح')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل حذف الحساب')));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('حذف الحساب')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'تحذير: هذا الإجراء لا يمكن التراجع عنه',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور للتأكيد',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('حذف الحساب'),
                    ),
            ],
          ),
        ),
      ),
    );
}
