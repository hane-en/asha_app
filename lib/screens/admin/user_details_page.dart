import 'package:flutter/material.dart';
import 'edit_user_profile.dart';
import 'delete_user_page.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart'; // Added import for AdminSettingsPage

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل المستخدم',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditUserProfilePage(user: user),
                ),
              );
            },
            tooltip: 'تعديل',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المستخدم
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(
                            (user['name']?[0] ?? '?').toUpperCase(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? 'غير محدد',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ID: ${user['id'] ?? 'غير محدد'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      'رقم الهاتف',
                      user['phone'] ?? 'غير محدد',
                      Icons.phone,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'الدور',
                      user['role'] ?? 'غير محدد',
                      Icons.person,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'البريد الإلكتروني',
                      user['email'] ?? 'غير محدد',
                      Icons.email,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'العنوان',
                      user['address'] ?? 'غير محدد',
                      Icons.location_on,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditUserProfilePage(user: user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل البيانات'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeleteUserPage(
                            userId: user['id'] ?? 0,
                            userName: user['name'] ?? '',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('حذف المستخدم'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
              (route) => false,
            );
          }
        },
      ),
    ),
  );

  Widget _buildInfoRow(String label, String value, IconData icon) => Row(
    children: [
      Icon(icon, color: Colors.purple, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ],
  );
}
