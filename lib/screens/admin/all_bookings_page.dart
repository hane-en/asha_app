import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class AllBookingsPage extends StatefulWidget {
  const AllBookingsPage({super.key});

  @override
  State<AllBookingsPage> createState() => _AllBookingsPageState();
}

class _AllBookingsPageState extends State<AllBookingsPage> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String selectedStatus = 'الكل';
  String userRole = 'user';

  @override
  void initState() {
    super.initState();
    loadUserRole();
    loadBookingsByStatus();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? 'user';
    });
  }

  Future<void> loadBookingsByStatus() async {
    setState(() => isLoading = true);
    try {
      final results = selectedStatus == 'الكل'
          ? await AdminService.getAllBookings()
          : await AdminService.getBookingsByStatus(selectedStatus);
      setState(() {
        bookings = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الحجوزات: $e')));
      }
    }
  }

  Future<void> updateStatus(int bookingId, String newStatus) async {
    try {
      final success = await AdminService.updateBookingStatus(
        bookingId,
        newStatus,
      );
      if (success) {
        loadBookingsByStatus();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('✅ تم تحديث الحالة')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ فشل في تحديث الحالة')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
      }
    }
  }

  Future<void> deleteBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا الطلب؟'),
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

    if (confirm == true) {
      try {
        final success = await AdminService.deleteBooking(bookingId);
        if (success) {
          loadBookingsByStatus();
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('🗑️ تم الحذف')));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('❌ فشل في الحذف')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
        }
      }
    }
  }

  Widget buildAdminActions(int bookingId) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      PopupMenuButton<String>(
        icon: const Icon(Icons.edit),
        onSelected: (value) => updateStatus(bookingId, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'قيد المراجعة',
            child: Text('قيد المراجعة'),
          ),
          const PopupMenuItem(value: 'تم القبول', child: Text('تم القبول')),
          const PopupMenuItem(value: 'مرفوض', child: Text('مرفوض')),
          const PopupMenuItem(value: 'مكتمل', child: Text('مكتمل')),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => deleteBooking(bookingId),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('إدارة الطلبات', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: loadBookingsByStatus,
          tooltip: 'تحديث',
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: DropdownButton<String>(
            value: selectedStatus,
            isExpanded: true,
            items: ['الكل', 'قيد المراجعة', 'تم القبول', 'مرفوض', 'مكتمل']
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
                loadBookingsByStatus();
              });
            },
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : bookings.isEmpty
              ? const Center(child: Text('لا توجد حجوزات بالحالة المحددة'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_note,
                          color: Colors.purple,
                        ),
                        title: Text('الخدمة: ${b['service_name'] ?? ''}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('العميل: ${b['user_name'] ?? ''}'),
                            Text('الحالة: ${b['status'] ?? ''}'),
                            if (b['date'] != null)
                              Text('التاريخ: ${b['date']}'),
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
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ],
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
  );
}
