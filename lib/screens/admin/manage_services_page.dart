import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/admin_service.dart';
import '../../models/service_category_model.dart';

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({Key? key}) : super(key: key);

  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _services = [];
  Map<String, dynamic> _stats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AdminService.getAllServicesWithCategories();

      if (result['success'] == true) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _stats = result['stats'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'فشل في تحميل الخدمات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteServiceCategory(
    int categoryId,
    String categoryName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف فئة الخدمة "$categoryName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await AdminService.deleteServiceCategory(categoryId);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف فئة الخدمة "$categoryName" بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadServices(); // إعادة تحميل البيانات
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في حذف فئة الخدمة'),
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
  }

  Future<void> _deleteService(int serviceId, String serviceTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف الخدمة "$serviceTitle" وجميع فئاتها؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await AdminService.deleteServiceWithNotification(
          serviceId,
          'تم حذف الخدمة من قبل المدير',
        );

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الخدمة "$serviceTitle" وجميع فئاتها بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadServices(); // إعادة تحميل البيانات
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في حذف الخدمة: ${result['message']}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخدمات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadServices),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadServices,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // إحصائيات
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الخدمات',
                          '${_stats['total_services'] ?? 0}',
                          Icons.business,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الفئات',
                          '${_stats['total_categories'] ?? 0}',
                          Icons.category,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'الخدمات النشطة',
                          '${_stats['active_services'] ?? 0}',
                          Icons.check_circle,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                // قائمة الخدمات
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return _buildServiceCard(service);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final serviceCategories = List<Map<String, dynamic>>.from(
      service['service_categories'] ?? [],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            // صورة الخدمة
            if (service['images'] != null &&
                (service['images'] as List).isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: service['images'][0],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${service['provider']['name']} - ${service['category']['name']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        '${service['price']} ريال',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: service['is_active'] == true
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service['is_active'] == true ? 'نشط' : 'غير نشط',
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
            ),
            // زر حذف الخدمة
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteService(service['id'], service['title']),
            ),
          ],
        ),
        subtitle: Text(
          '${serviceCategories.length} فئة خدمة',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          // تفاصيل الخدمة
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوصف:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(service['description'] ?? 'لا يوجد وصف'),
                const SizedBox(height: 16),
                Text(
                  'فئات الخدمة:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (serviceCategories.isEmpty)
                  const Text(
                    'لا توجد فئات خدمة',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...serviceCategories.map(
                    (category) => _buildCategoryCard(category),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: category['image'] != null && category['image'].isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: category['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.category),
              ),
        title: Text(
          category['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category['description'] != null &&
                category['description'].isNotEmpty)
              Text(category['description']),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${category['price']} ريال',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (category['duration'] != null &&
                    category['duration'].isNotEmpty)
                  Text(' • ${category['duration']}'),
                if (category['size'] != null && category['size'].isNotEmpty)
                  Text(' • ${category['size']}'),
              ],
            ),
            if (category['materials'] != null &&
                category['materials'].isNotEmpty)
              Text(
                'المواد: ${category['materials']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () =>
              _deleteServiceCategory(category['id'], category['name']),
        ),
      ),
    );
  }
}
