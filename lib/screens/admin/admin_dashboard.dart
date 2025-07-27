import 'package:flutter/material.dart';
import 'manage_users.dart';
import 'manage_services.dart';
import 'manage_ads.dart';
import 'manage_comments.dart';
import 'manage_bookings.dart';
import 'join_requests_page.dart';
import 'admin_settings_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('لوحة تحكم المشرف'),
      backgroundColor: Colors.white,
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildTile(context, 'إدارة المستخدمين', const ManageUsersPage()),
        buildTile(context, 'إدارة الخدمات', const ManageServices()),
        buildTile(context, 'إدارة الإعلانات', const ManageAdsPage()),
        buildTile(context, 'إدارة التعليقات', const ManageComments()),
        buildTile(context, 'إدارة الحجوزات', const ManageBookings()),
        buildTile(context, 'طلبات الانضمام', const JoinRequestsPage()),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
          );
        }
        // إذا كنت بالفعل في الرئيسية لا تفعل شيئاً
      },
    ),
  );

  Widget buildTile(BuildContext context, String title, Widget page) => Card(
    child: ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    ),
  );
}
