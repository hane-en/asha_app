import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/provider_service.dart';
import '../../models/provider_service_model.dart';
import '../../models/provider_service_with_categories_model.dart';
import '../../models/service_category_model.dart';
import 'edit_service_page.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  int currentIndex = 2;
  List<ProviderServiceWithCategories> services = [];
  bool _isLoading = false;
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
      final servicesData = await ProviderService.getMyServicesWithCategories();
      setState(() {
        services = servicesData
            .map((data) => ProviderServiceWithCategories.fromJson(data))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل الخدمات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteService(ProviderServiceWithCategories service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف الخدمة "${service.title}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await ProviderService.deleteService(service.id);
      if (success) {
        _loadServices(); // إعادة تحميل القائمة
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف الخدمة "${service.title}" بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في حذف الخدمة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editService(ProviderServiceWithCategories service) {
    // سيتم تنفيذ التعديل في صفحة منفصلة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة صفحة تعديل الخدمة قريباً'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _viewServiceDetails(ProviderServiceWithCategories service) {
    // عرض تفاصيل الخدمة في dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // صورة الخدمة
              if (service.imageUrl != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(service.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // معلومات الخدمة
              Text('الوصف: ${service.description}'),
              const SizedBox(height: 8),
              Text('السعر: ${service.formattedPrice}'),
              const SizedBox(height: 8),
              Text('الموقع: ${service.location ?? 'غير محدد'}'),
              const SizedBox(height: 8),
              Text('الفئة: ${service.categoryName}'),
              const SizedBox(height: 8),
              Text('الحالة: ${service.statusText}'),
              const SizedBox(height: 8),
              Text('عدد الحجوزات: ${service.bookingsCount}'),
              const SizedBox(height: 8),
              Text('عدد العروض: ${service.offersCount}'),
              const SizedBox(height: 16),

              // التقييم
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${service.formattedRating} (${service.reviewsCount} تقييم)',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // التعليقات
              if (service.reviews.isNotEmpty) ...[
                const Text(
                  'التعليقات:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...service.reviews
                    .take(3)
                    .map(
                      (review) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${review['rating'] ?? 0}/5'),
                                  const Spacer(),
                                  Text(
                                    review['formatted_date'] ??
                                        review['created_at'] ??
                                        '',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review['user_name'] ??
                                    review['userName'] ??
                                    'مستخدم',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(review['comment'] ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                if (service.reviews.length > 3)
                  Text(
                    'و ${service.reviews.length - 3} تعليق آخر...',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('خدماتي', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/provider-home',
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.pushNamed(context, '/provider-notifications');
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'القائمة الجانبية',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('الرئيسية'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-home',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('قيد الانتظار'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-pending',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('خدماتي'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('حجوزاتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-bookings',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('إعلاناتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-ads',
                (route) => false,
              ),
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
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
          : services.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.design_services, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد خدمات',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'قم بإضافة خدماتك الأولى',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    child: Column(
                      children: [
                        // صورة الخدمة
                        if (service.imageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(service.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                        // محتوى الخدمة
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // عنوان الخدمة والحالة
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      service.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: service.statusColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      service.statusText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // الوصف
                              Text(
                                service.description,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              // معلومات الخدمة
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(service.categoryName),
                                  const Spacer(),
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(service.location ?? 'غير محدد'),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // السعر والتقييم
                              Row(
                                children: [
                                  Text(
                                    service.formattedPrice,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(service.formattedRating),
                                      if (service.hasReviews) ...[
                                        const SizedBox(width: 4),
                                        Text('(${service.reviewsCount})'),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // إحصائيات
                              Row(
                                children: [
                                  _buildStatItem(
                                    Icons.book_online,
                                    '${service.bookingsCount} حجز',
                                  ),
                                  const SizedBox(width: 16),
                                  _buildStatItem(
                                    Icons.local_offer,
                                    '${service.offersCount} عرض',
                                  ),
                                  const SizedBox(width: 16),
                                  _buildStatItem(
                                    Icons.comment,
                                    '${service.reviewsCount} تعليق',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // أزرار الإجراءات
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _viewServiceDetails(service),
                                      icon: const Icon(
                                        Icons.visibility,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'عرض التفاصيل',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _editService(service),
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'تعديل',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _deleteService(service),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'حذف',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-home',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-pending',
                (route) => false,
              );
              break;
            case 2:
              // أنت بالفعل هنا
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-bookings',
                (route) => false,
              );
              break;
            case 4:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-ads',
                (route) => false,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'قيد الانتظار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'خدماتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'إعلاناتي',
          ),
        ],
      ),
    ),
  );
}
