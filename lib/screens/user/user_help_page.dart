import 'package:flutter/material.dart';
import '../../routes/route_names.dart';
import '../../routes/app_routes.dart';

class UserHelpPage extends StatelessWidget {
  const UserHelpPage({super.key});

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.userHome,
        (route) => false,
      );
      return false;
    },
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المساعدة والدعم'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.userHome,
                (route) => false,
              );
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.help_outline, size: 80, color: Colors.purple),
            const SizedBox(height: 16),
            const Text(
              'الأسئلة الشائعة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('كيف يمكنني إنشاء حساب؟'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'يمكنك إنشاء حساب من خلال الضغط على زر "إنشاء حساب جديد" وملء البيانات المطلوبة.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('كيف أضيف خدمة أو إعلان؟'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'بعد تسجيل الدخول كمزود خدمة، يمكنك إضافة خدمة أو إعلان من خلال لوحة التحكم.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('كيف أتواصل مع الدعم؟'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'يمكنك التواصل مع الدعم عبر البريد الإلكتروني support@eventservices.com أو من خلال صفحة التواصل داخل التطبيق.',
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.purple),
              title: const Text('البريد الإلكتروني للدعم'),
              subtitle: const Text('support@eventservices.com'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.purple),
              title: const Text('رقم الدعم الفني'),
              subtitle: const Text('+967-xxx-xxx-xxx'),
              onTap: () {},
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0, // الصفحة الرئيسية (المساعدة من القائمة الجانبية)
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
    ),
  );
}
