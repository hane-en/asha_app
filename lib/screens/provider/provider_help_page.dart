import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

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
            AppRoutes.providerHome,
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
    ),
  );
}
