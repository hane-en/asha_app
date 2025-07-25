import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderHelpPage extends StatelessWidget {
  const ProviderHelpPage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'المساعدة والدعم',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/provider-home',
            (route) => false,
          ),
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
            title: const Text('كيف يمكنني إضافة خدمة؟'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'يمكنك إضافة خدمة من خلال لوحة التحكم الخاصة بك كمزود خدمة.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('كيف أتابع حجوزاتي؟'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'يمكنك متابعة الحجوزات من خلال صفحة "حجوزاتي" في لوحة التحكم.',
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
                  'يمكنك التواصل مع الدعم عبر البريد الإلكتروني asha@gmail.com أو من خلال صفحة التواصل داخل التطبيق.',
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.purple),
            title: const Text('البريد الإلكتروني للدعم'),
            subtitle: const Text('asha@gmail.com'),
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'asha@gmail.com',
                query: 'subject=دعم فني&body=السلام عليكم،',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تعذر فتح تطبيق البريد الإلكتروني'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.purple),
            title: const Text('رقم الدعم الفني'),
            subtitle: const Text('771-746-478'),
            onTap: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: '771746478');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تعذر فتح تطبيق الاتصال')),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}
