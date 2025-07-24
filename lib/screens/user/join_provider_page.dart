import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class JoinProviderPage extends StatefulWidget {
  const JoinProviderPage({super.key});

  @override
  State<JoinProviderPage> createState() => _JoinProviderPageState();
}

class _JoinProviderPageState extends State<JoinProviderPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final serviceController = TextEditingController();
  bool isLoading = false;

  Future<void> submitRequest() async {
    setState(() => isLoading = true);
    final success = await ApiService.joinAsProvider(
      nameController.text,
      phoneController.text,
      serviceController.text,
    );
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الانضمام بنجاح')),
      );
      nameController.clear();
      phoneController.clear();
      serviceController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل إرسال الطلب')));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('طلب الانضمام كمزود خدمة')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              TextField(
                controller: serviceController,
                decoration: const InputDecoration(labelText: 'نوع الخدمة'),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: submitRequest,
                      child: const Text('إرسال الطلب'),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0, // الصفحة الرئيسية (الانضمام من القائمة الجانبية)
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/user_home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/search');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/favorites');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/booking_status');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'الطلبات'),
          ],
        ),
      ),
    );
}
