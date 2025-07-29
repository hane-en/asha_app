import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class JoinRequestsPage extends StatefulWidget {
  const JoinRequestsPage({super.key});

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  List<Map<String, dynamic>> requests = [];
  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> categoryStats = [];
  bool isLoading = true;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    setState(() => isLoading = true);
    try {
      final response = await AdminService.getProviderRequests(
        page: 1,
        status: selectedStatus,
      );

      if (response['success'] == true) {
        setState(() {
          requests = List<Map<String, dynamic>>.from(response['data']);
          stats = response['stats'];
          categoryStats = List<Map<String, dynamic>>.from(
            response['category_stats'] ?? [],
          );
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الطلبات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> handleRequest(int requestId, String action) async {
    final adminNotes = await showNotesDialog(action);
    if (adminNotes == null) return; // User cancelled

    try {
      bool success;
      if (action == 'approve') {
        success = await AdminService.approveProviderRequest(
          requestId,
          adminNotes: adminNotes,
        );
      } else {
        success = await AdminService.rejectProviderRequest(
          requestId,
          adminNotes: adminNotes,
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم معالجة الطلب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        loadRequests(); // إعادة تحميل الطلبات
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في معالجة الطلب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> showNotesDialog(String action) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'approve' ? 'ملاحظات الموافقة' : 'سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظاتك هنا (اختياري)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلبات الانضمام',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadRequests,
            tooltip: 'تحديث الطلبات',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // إحصائيات
                if (stats != null) _buildStatsCard(),

                // فلاتر
                _buildFilters(),

                // قائمة الطلبات
                Expanded(
                  child: requests.isEmpty
                      ? const Center(child: Text('لا توجد طلبات حالياً'))
                      : RefreshIndicator(
                          onRefresh: loadRequests,
                          child: ListView.builder(
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final request = requests[index];
                              return _buildRequestCard(request);
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

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات طلبات الانضمام',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الكل', stats!['total_requests'], Colors.blue),
                _buildStatItem(
                  'قيد الانتظار',
                  stats!['pending_requests'],
                  Colors.orange,
                ),
                _buildStatItem(
                  'تمت الموافقة',
                  stats!['approved_requests'],
                  Colors.green,
                ),
                _buildStatItem(
                  'مرفوض',
                  stats!['rejected_requests'],
                  Colors.red,
                ),
              ],
            ),
            if (categoryStats.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'طلبات حسب الفئة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryStats.length,
                  itemBuilder: (context, index) {
                    final category = categoryStats[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            '0xFF${category['category_color']?.substring(1) ?? '8E24AA'}',
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category['requests_count'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            category['category_name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'حالة الطلب',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('جميع الطلبات')),
                DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                DropdownMenuItem(
                  value: 'approved',
                  child: Text('تمت الموافقة'),
                ),
                DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
              ],
              onChanged: (value) {
                setState(() => selectedStatus = value);
                loadRequests();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final categoryName = request['category_name'] ?? 'غير محدد';
    final categoryColor = request['category_color'] ?? '#8E24AA';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          request['user_name'] ?? 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد: ${request['user_email']}'),
            Text('الهاتف: ${request['user_phone']}'),
            if (request['yemeni_account'] != null)
              Text('الحساب اليمني: ${request['yemeni_account']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF${categoryColor.substring(1)}')),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'فئة الخدمة: $categoryName',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request['business_name'] != null) ...[
                  Text(
                    'اسم العمل: ${request['business_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                if (request['business_description'] != null) ...[
                  Text('وصف العمل: ${request['business_description']}'),
                  const SizedBox(height: 8),
                ],
                if (request['business_phone'] != null) ...[
                  Text('هاتف العمل: ${request['business_phone']}'),
                  const SizedBox(height: 8),
                ],
                if (request['business_address'] != null) ...[
                  Text('عنوان العمل: ${request['business_address']}'),
                  const SizedBox(height: 8),
                ],
                if (request['admin_notes'] != null &&
                    request['admin_notes'].isNotEmpty) ...[
                  Text(
                    'ملاحظات المشرف: ${request['admin_notes']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'تاريخ الطلب: ${request['created_at']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              handleRequest(request['id'], 'approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('موافقة'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              handleRequest(request['id'], 'reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('رفض'),
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
}
