import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class ManageServices extends StatefulWidget {
  const ManageServices({super.key});

  @override
  State<ManageServices> createState() => _ManageServicesState();
}

class _ManageServicesState extends State<ManageServices> {
  List<Map<String, dynamic>> services = [];
  Map<String, dynamic>? stats;
  bool isLoading = true;
  int currentPage = 1;
  final int perPage = 20;
  bool hasMoreData = true;
  String? searchQuery;
  String? selectedCategory;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMoreData = true;
      });
    }

    try {
      final response = await AdminService.getAllServicesDetailed(
        page: currentPage,
        limit: perPage,
      );

      if (response['success'] == true) {
        final newServices = List<Map<String, dynamic>>.from(response['data']);

        setState(() {
          if (refresh) {
            services = newServices;
          } else {
            services.addAll(newServices);
          }
          stats = response['stats'];
          isLoading = false;
          hasMoreData = newServices.length == perPage;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الخدمات: $e')));
      }
    }
  }

  Future<void> loadMoreServices() async {
    if (!hasMoreData || isLoading) return;

    setState(() => currentPage++);
    await loadServices();
  }

  Future<void> deleteService(int serviceId, String serviceName) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف الخدمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد حذف الخدمة "$serviceName"؟'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ سيتم حذف جميع البيانات المرتبطة بالخدمة:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• الحجوزات'),
            const Text('• التعليقات والتقييمات'),
            const Text('• المفضلة'),
            const Text('• العروض'),
            const SizedBox(height: 16),
            const Text('سبب الحذف (اختياري):'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'أدخل سبب الحذف...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
      try {
        final result = await AdminService.deleteServiceWithNotification(
          serviceId,
          reasonController.text.trim().isEmpty
              ? 'تم حذف الخدمة من قبل المدير'
              : reasonController.text.trim(),
        );

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${result['message']}'),
                backgroundColor: Colors.green,
              ),
            );
          }
          loadServices(refresh: true);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${result['message']}'),
                backgroundColor: Colors.red,
              ),
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
  }

  void showServiceDetails(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.business, color: _getStatusColor(service['is_active'])),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                service['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('الفئة', service['category_name'] ?? ''),
              _buildDetailRow('السعر', service['formatted_price'] ?? ''),
              if (service['original_price'] != null)
                _buildDetailRow(
                  'السعر الأصلي',
                  service['formatted_original_price'] ?? '',
                ),
              _buildDetailRow('المزود', service['provider_name'] ?? ''),
              _buildDetailRow('هاتف المزود', service['provider_phone'] ?? ''),
              _buildDetailRow('بريد المزود', service['provider_email'] ?? ''),
              _buildDetailRow(
                'التقييم',
                '${service['formatted_rating'] ?? '0.0'} ⭐',
              ),
              _buildDetailRow(
                'عدد التقييمات',
                '${service['total_reviews'] ?? 0}',
              ),
              _buildDetailRow(
                'عدد الحجوزات',
                '${service['total_bookings'] ?? 0}',
              ),
              _buildDetailRow(
                'عدد المفضلة',
                '${service['total_favorites'] ?? 0}',
              ),
              _buildDetailRow('عدد العروض', '${service['total_offers'] ?? 0}'),
              _buildDetailRow('الموقع', service['location'] ?? 'غير محدد'),
              _buildDetailRow('العنوان', service['address'] ?? 'غير محدد'),
              _buildDetailRow('المدينة', service['city'] ?? 'غير محدد'),
              _buildDetailRow('الحالة', service['status_text'] ?? ''),
              _buildDetailRow('تاريخ الإنشاء', service['created_at'] ?? ''),
              _buildDetailRow('آخر تحديث', service['updated_at'] ?? ''),
              if (service['description'] != null &&
                  service['description'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'الوصف:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(service['description']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteService(service['id'] ?? 0, service['title'] ?? '');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف الخدمة'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  Widget _buildStatsCard() {
    if (stats == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات الخدمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'إجمالي الخدمات',
                    '${stats!['total_services'] ?? 0}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الخدمات النشطة',
                    '${stats!['active_services'] ?? 0}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الخدمات الموثقة',
                    '${stats!['verified_services'] ?? 0}',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الخدمات المميزة',
                    '${stats!['featured_services'] ?? 0}',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'متوسط التقييم',
                    '${(stats!['avg_rating'] ?? 0).toStringAsFixed(1)} ⭐',
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'إجمالي الحجوزات',
                    '${stats!['total_bookings'] ?? 0}',
                    Colors.teal,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'إجمالي المفضلة',
                    '${stats!['total_favorites'] ?? 0}',
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
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

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة الخدمات',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadServices(refresh: true),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: isLoading && services.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : services.isEmpty
                ? const Center(child: Text('لا توجد خدمات'))
                : RefreshIndicator(
                    onRefresh: () => loadServices(refresh: true),
                    child: ListView.builder(
                      itemCount: services.length + (hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == services.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final service = services[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(
                                service['is_active'],
                              ).withOpacity(0.2),
                              child: Icon(
                                Icons.business,
                                color: _getStatusColor(service['is_active']),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    service['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (service['is_featured'] == 1)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                if (service['is_verified'] == 1)
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الفئة: ${service['category_name'] ?? ''}',
                                ),
                                Text(
                                  'السعر: ${service['formatted_price'] ?? ''}',
                                ),
                                Text(
                                  'المزود: ${service['provider_name'] ?? ''}',
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'التقييم: ${service['formatted_rating'] ?? '0.0'} ⭐',
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          service['is_active'],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        service['status_text'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => showServiceDetails(service),
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'عرض التفاصيل',
                                ),
                                IconButton(
                                  onPressed: () => deleteService(
                                    service['id'] ?? 0,
                                    service['title'] ?? '',
                                  ),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'حذف',
                                ),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildActivityStat(
                                            'الحجوزات',
                                            service['total_bookings'] ?? 0,
                                            Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildActivityStat(
                                            'التعليقات',
                                            service['total_reviews'] ?? 0,
                                            Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildActivityStat(
                                            'المفضلة',
                                            service['total_favorites'] ?? 0,
                                            Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildActivityStat(
                                            'العروض',
                                            service['total_offers'] ?? 0,
                                            Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'تاريخ الإنشاء: ${service['created_at'] ?? ''}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (service['description'] != null &&
                                        service['description'].isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        'الوصف:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        service['description'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
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
}
