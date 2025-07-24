import 'package:flutter/material.dart';
import 'manage_my_services.dart';
import 'manage_my_ads.dart';
import 'provider_bookings.dart';
import 'add_service_page.dart';
import 'add_ad_page.dart';

class ProviderHomePage extends StatelessWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة مزود الخدمة')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(context, 'خدماتي', const ManageMyServices()),
          _buildCard(context, 'إعلاناتي', const ManageMyAdsPage()),
          _buildCard(context, 'إضافة خدمة', const AddServicePage()),
          _buildCard(context, 'إضافة إعلان', const AddAdPage()),
          _buildCard(context, 'حجوزاتي', const ProviderBookingsPage()),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Widget page) {
    return Card(
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
      ),
    );
  }
}
