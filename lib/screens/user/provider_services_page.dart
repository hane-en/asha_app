import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../models/service_model.dart';
import '../auth/login_page.dart';
import '../auth/signup_page.dart';
import 'booking_page.dart';
import 'service_details_page.dart';

class ProviderServicesPage extends StatefulWidget {
  final int providerId;
  final String providerName;

  const ProviderServicesPage({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ProviderServicesPage> createState() => _ProviderServicesPageState();
}

class _ProviderServicesPageState extends State<ProviderServicesPage> {
  List<Service> services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final servicesData = await ApiService.getServicesByProvider(
        widget.providerId,
      );

      setState(() {
        services = servicesData;
      });
    } catch (e) {
      print('Error loading services: $e');
      setState(() {
        services = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToFavorites(Service service) async {
    try {
      final userId = await _getUserId();
      if (userId != null) {
        await ApiService.addToFavorites(userId, service.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في الإضافة للمفضلة: $e')));
    }
  }

  Future<void> _bookService(Service service) async {
    final userId = await _getUserId();

    if (userId == null) {
      // المستخدم ليس لديه حساب
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignupPage(source: 'booking')),
      );

      if (result == true) {
        // تم إنشاء الحساب بنجاح
        _navigateToBooking(service);
      }
    } else {
      // التحقق من حالة تسجيل الدخول
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (!isLoggedIn) {
        // المستخدم مسجل خروج
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

        if (result == true) {
          // تم تسجيل الدخول بنجاح
          _navigateToBooking(service);
        }
      } else {
        // المستخدم مسجل دخول
        _navigateToBooking(service);
      }
    }
  }

  void _navigateToBooking(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPage(
          service: {
            'id': service.id,
            'title': service.title,
            'price': service.price,
            'provider_id': service.providerId,
            'provider_name': service.providerName,
          },
        ),
      ),
    );
  }

  void _showServiceDetails(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceDetailsPage(service: service)),
    );
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خدمات ${widget.providerName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
          ? const Center(
              child: Text(
                'لا توجد خدمات متاحة',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة الخدمة
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            color: AppColors.primaryColor.withOpacity(0.1),
                          ),
                          child: service.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    service.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                      ),

                      // معلومات الخدمة
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.price} ريال',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // الأزرار
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // زر عرض التفاصيل
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showServiceDetails(service),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  minimumSize: const Size(0, 30),
                                ),
                                child: const Text(
                                  'التفاصيل',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // زر الإضافة للمفضلة
                            IconButton(
                              onPressed: () => _addToFavorites(service),
                              icon: const Icon(Icons.favorite_border, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            // زر الحجز
                            IconButton(
                              onPressed: () => _bookService(service),
                              icon: const Icon(Icons.book_online, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
