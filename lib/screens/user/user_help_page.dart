import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
            // البريد الإلكتروني للدعم
            ListTile(
              leading: const Icon(Icons.email, color: Colors.purple),
              title: const Text('البريد الإلكتروني للدعم'),
              subtitle: const Text('asha_app@gmail.com'),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'asha_app@gmail.com',
                  query:
                      'subject=طلب دعم فني&body=السلام عليكم،\n\nأحتاج إلى مساعدة في:\n\n\n\nشكراً لكم',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تعذر فتح تطبيق البريد الإلكتروني'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            // رقم الدعم الفني مع خيارات الاتصال والواتساب
            ExpansionTile(
              leading: const Icon(Icons.phone, color: Colors.purple),
              title: const Text('رقم الدعم الفني'),
              subtitle: const Text('+967-771-746-678'),
              children: [
                ListTile(
                  leading: const Icon(Icons.call, color: Colors.green),
                  title: const Text('اتصال'),
                  subtitle: const Text('اتصال مباشر'),
                  onTap: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: '967771746678',
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تعذر فتح تطبيق الاتصال'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: const Text('المراسلة عبر الواتساب'),
                  subtitle: const Text('فتح محادثة مباشرة'),
                  onTap: () async {
                    final Uri whatsappUri = Uri.parse(
                      'https://wa.me/967771746678?text=السلام عليكم، أحتاج إلى مساعدة في التطبيق',
                    );
                    if (await canLaunchUrl(whatsappUri)) {
                      await launchUrl(
                        whatsappUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تعذر فتح تطبيق الواتساب'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
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
