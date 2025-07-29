import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'user_details_page.dart';
import 'delete_user_page.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  // إحصائيات المستخدمين
  int totalUsers = 0;
  int adminUsers = 0;
  int providerUsers = 0;
  int customerUsers = 0;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final userList = await AdminService.getAllUsers();

      // حساب الإحصائيات
      int total = userList.length;
      int admins = 0;
      int providers = 0;
      int customers = 0;

      for (var user in userList) {
        // حساب الأدوار
        String role = user['role']?.toString().toLowerCase() ?? '';
        if (role.contains('admin')) {
          admins++;
        } else if (role.contains('provider')) {
          providers++;
        } else if (role.contains('user')) {
          customers++;
        }
      }

      setState(() {
        users = userList;
        totalUsers = total;
        adminUsers = admins;
        providerUsers = providers;
        customerUsers = customers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        users = [];
        totalUsers = 0;
        adminUsers = 0;
        providerUsers = 0;
        customerUsers = 0;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المستخدمين: $e')));
      }
    }
  }

  Future<void> deleteUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المستخدم "$userName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeleteUserPage(userId: userId, userName: userName),
        ),
      );

      if (result == true) {
        loadUsers(); // إعادة تحميل القائمة بعد الحذف
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadUsers,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('لا توجد مستخدمين'))
          : Column(
              children: [
                // عداد الإحصائيات
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'مدیرین',
                          adminUsers.toString(),
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'مزودین',
                          providerUsers.toString(),
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'مستخدمین',
                          customerUsers.toString(),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'الكل',
                          totalUsers.toString(),
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                // قائمة المستخدمين
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user['name']?[0]?.toUpperCase() ?? '?'),
                          ),
                          title: Text(user['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الهاتف: ${user['phone'] ?? ''}'),
                              Text('الدور: ${user['role'] ?? ''}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UserDetailsPage(user: user),
                                    ),
                                  );
                                  break;
                                case 'delete':
                                  deleteUser(
                                    user['id'] ?? 0,
                                    user['name'] ?? '',
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('عرض التفاصيل'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'حذف',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
