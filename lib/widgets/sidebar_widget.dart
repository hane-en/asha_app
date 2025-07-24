import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {

  const SidebarWidget({
    super.key,
    required this.items,
    this.userName,
    this.userRole,
    this.onProfileTap,
    this.onLogoutTap,
  });
  final List<SidebarItem> items;
  final String? userName;
  final String? userRole;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) => Drawer(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                // User name
                Text(
                  userName ?? 'مستخدم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // User role
                Text(
                  _getRoleText(userRole),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile section
                if (onProfileTap != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('الملف الشخصي'),
                    onTap: onProfileTap,
                  ),
                const Divider(),
                // Main menu items
                ...items.map((item) => _buildMenuItem(context, item)),
                const Divider(),
                // Logout
                if (onLogoutTap != null)
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: onLogoutTap,
                  ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                Text(
                  'خدمات المناسبات',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildMenuItem(BuildContext context, SidebarItem item) => ListTile(
      leading: Icon(
        item.icon,
        color: item.isActive ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: item.isActive ? FontWeight.bold : FontWeight.normal,
          color: item.isActive ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: item.badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: item.onTap,
    );

  String _getRoleText(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'مدير النظام';
      case 'provider':
        return 'مزود الخدمة';
      case 'user':
        return 'مستخدم';
      default:
        return 'مستخدم';
    }
  }
}

class SidebarItem {

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.badge,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final int? badge;
}
