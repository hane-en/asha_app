import 'package:flutter/material.dart';
import 'join_requests_page.dart';
import 'user_list_page.dart';
import 'search_user_page.dart'; // أضف هذه الصفحة للبحث
import 'manage_services.dart';
import 'manage_ads.dart';
import 'manage_bookings.dart';
import 'manage_comments.dart';
import 'edit_user_profile.dart';
import 'delete_user_page.dart';
// import 'user_details_page.dart';
import 'all_bookings_page.dart';
import 'admin_settings_page.dart'; // أضف هذه الصفحة للإعدادات
import 'package:shared_preferences/shared_preferences.dart'; // أضف هذه المكتبة للتعامل مع SharedPreferences

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async => true,
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'لوحة الإدارة',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'بحث عن مستخدم',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchUserPage()),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinRequestsPage()),
              ),
              child: const Text('طلبات الانضمام'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListPage()),
              ),
              child: const Text('المستخدمين'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageServices()),
              ),
              child: const Text('إدارة الخدمات'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageAdsPage()),
              ),
              child: const Text('إدارة الإعلانات'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageBookings()),
              ),
              child: const Text('إدارة الحجوزات'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageComments()),
              ),
              child: const Text('إدارة التعليقات'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllBookingsPage()),
              ),
              child: const Text('جميع الحجوزات'),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              // لا تفعل شيئاً إذا كنت بالفعل في الصفحة الرئيسية
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
              );
            }
          },
        ),
      ),
    ),
  );
}
