import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'user_details_page.dart';
import 'delete_user_page.dart';
import 'edit_user_profile.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? selectedUserType;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final userList = await AdminService.getAllUsers();
      setState(() {
        users = userList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المستخدمين: $e')));
      }
    }
  }

  Future<void> deleteUser(int userId, String userName, String userType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد حذف المستخدم "$userName"؟'),
            const SizedBox(height: 8),
            Text(
              'نوع المستخدم: ${_getUserTypeText(userType)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (userType == 'provider')
              const Text(
                '⚠️ سيتم حذف جميع خدماته وإعلاناته وبياناته المرتبطة',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ هذا الإجراء لا يمكن التراجع عنه',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
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

  String _getUserTypeText(String userType) {
    switch (userType) {
      case 'user':
        return 'مستخدم عادي';
      case 'provider':
        return 'مزود خدمة';
      case 'admin':
        return 'مدير';
      default:
        return 'غير محدد';
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'user':
        return Colors.blue;
      case 'provider':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    List<Map<String, dynamic>> filtered = users;

    // فلترة حسب نوع المستخدم
    if (selectedUserType != null) {
      filtered = filtered
          .where((user) => user['user_type'] == selectedUserType)
          .toList();
    }

    // فلترة حسب البحث
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final phone = user['phone']?.toString().toLowerCase() ?? '';
        final query = searchQuery!.toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    return filtered;
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
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadUsers,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // فلاتر البحث
          _buildFilters(),

          // قائمة المستخدمين
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                ? const Center(child: Text('لا توجد مستخدمين'))
                : RefreshIndicator(
                    onRefresh: loadUsers,
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // حقل البحث
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value.isEmpty ? null : value;
              });
            },
            decoration: InputDecoration(
              labelText: 'البحث عن مستخدم',
              hintText: 'اسم، بريد، هاتف...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),

          // فلتر نوع المستخدم
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedUserType,
                  decoration: InputDecoration(
                    labelText: 'نوع المستخدم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('جميع المستخدمين'),
                    ),
                    DropdownMenuItem(value: 'user', child: Text('مستخدم عادي')),
                    DropdownMenuItem(
                      value: 'provider',
                      child: Text('مزود خدمة'),
                    ),
                    DropdownMenuItem(value: 'admin', child: Text('مدير')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedUserType = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // إحصائيات سريعة
          const SizedBox(height: 12),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalUsers = users.length;
    final regularUsers = users.where((u) => u['user_type'] == 'user').length;
    final providers = users.where((u) => u['user_type'] == 'provider').length;
    final admins = users.where((u) => u['user_type'] == 'admin').length;

    return Row(
      children: [
        Expanded(child: _buildStatCard('الكل', totalUsers, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('مستخدمين', regularUsers, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('مزودين', providers, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('مديرين', admins, Colors.purple)),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userType = user['user_type'] ?? 'user';
    final userTypeText = _getUserTypeText(userType);
    final userTypeColor = _getUserTypeColor(userType);
    final isVerified = user['is_verified'] == 1;
    final status = user['status'] ?? 'active';

    // معلومات الفئة
    final categoryName = user['category_name'] ?? user['service_category_name'];
    final categoryColor = user['category_color'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: userTypeColor.withOpacity(0.2),
          child: Text(
            user['name']?[0]?.toUpperCase() ?? '?',
            style: TextStyle(color: userTypeColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 16),
            if (status != 'active')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'محظور',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد: ${user['email'] ?? ''}'),
            Text('الهاتف: ${user['phone'] ?? ''}'),
            const SizedBox(height: 4),
            Row(
              children: [
                // نوع المستخدم
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: userTypeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userTypeText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // الفئة المختارة (للمزودين فقط)
                if (userType == 'provider' && categoryName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(categoryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoryName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر عرض التفاصيل
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserDetailsPage(user: user),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, color: Colors.blue),
              tooltip: 'عرض التفاصيل',
            ),

            // زر التعديل
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditUserProfilePage(user: user),
                  ),
                ).then((result) {
                  if (result == true) loadUsers();
                });
              },
              icon: const Icon(Icons.edit, color: Colors.orange),
              tooltip: 'تعديل',
            ),

            // زر الحذف
            IconButton(
              onPressed: () =>
                  deleteUser(user['id'] ?? 0, user['name'] ?? '', userType),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'حذف',
            ),
          ],
        ),
        children: [
          // تفاصيل إضافية
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'تاريخ التسجيل: ${user['created_at'] ?? ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (user['last_login'] != null)
                  Text(
                    'آخر تسجيل دخول: ${user['last_login']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                const SizedBox(height: 8),

                // معلومات الفئة (للمزودين)
                if (userType == 'provider' && categoryName != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: _getCategoryColor(categoryColor),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الفئة المختارة: $categoryName',
                        style: TextStyle(
                          color: _getCategoryColor(categoryColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // إحصائيات النشاط
                Row(
                  children: [
                    Expanded(
                      child: _buildActivityStat(
                        'الحجوزات',
                        user['bookings_count'] ?? 0,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActivityStat(
                        'التعليقات',
                        user['reviews_count'] ?? 0,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActivityStat(
                        'المفضلة',
                        user['favorites_count'] ?? 0,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                // إحصائيات إضافية للمزودين
                if (userType == 'provider') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActivityStat(
                          'الخدمات',
                          user['services_count'] ?? 0,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActivityStat(
                          'الإعلانات',
                          user['ads_count'] ?? 0,
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActivityStat(
                          'حجوزات الخدمات',
                          user['provider_bookings_count'] ?? 0,
                          Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // دالة مساعدة للحصول على لون الفئة
  Color _getCategoryColor(String? categoryColor) {
    if (categoryColor == null) return Colors.grey;

    try {
      // إذا كان اللون بصيغة hex
      if (categoryColor.startsWith('#')) {
        return Color(int.parse(categoryColor.replaceAll('#', '0xFF')));
      }

      // إذا كان اللون بصيغة rgb
      if (categoryColor.startsWith('rgb')) {
        final values = categoryColor
            .replaceAll('rgb(', '')
            .replaceAll(')', '')
            .split(',');
        if (values.length == 3) {
          return Color.fromARGB(
            255,
            int.parse(values[0].trim()),
            int.parse(values[1].trim()),
            int.parse(values[2].trim()),
          );
        }
      }

      // ألوان محددة مسبقاً
      switch (categoryColor.toLowerCase()) {
        case 'purple':
        case '#8e24aa':
          return const Color(0xFF8e24aa);
        case 'pink':
        case '#ce93d8':
          return const Color(0xFFce93d8);
        case 'blue':
        case '#2196f3':
          return const Color(0xFF2196f3);
        case 'green':
        case '#4caf50':
          return const Color(0xFF4caf50);
        case 'orange':
        case '#ff9800':
          return const Color(0xFFff9800);
        case 'red':
        case '#f44336':
          return const Color(0xFFf44336);
        case 'teal':
        case '#009688':
          return const Color(0xFF009688);
        case 'indigo':
        case '#3f51b5':
          return const Color(0xFF3f51b5);
        default:
          return Colors.grey;
      }
    } catch (e) {
      return Colors.grey;
    }
  }
}
