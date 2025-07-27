import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/service_card.dart';
import '../../models/service_model.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'details_page.dart';
import '../../routes/app_routes.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.userId});
  final int userId;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteServices = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - جلب المفضلة من الخادم
        final results = await ApiService.getFavorites(userId);
        setState(() {
          favoriteServices = results;
        });
      } else {
        // المستخدم غير مسجل دخول - عرض المفضلة المحلية
        final localFavorites = prefs.getStringList('local_favorites') ?? [];

        if (localFavorites.isNotEmpty) {
          // هنا يمكنك تحميل تفاصيل الخدمات المحلية
          // للتبسيط، سنعرض رسالة للمستخدم
          setState(() {
            favoriteServices = [];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يتم عرض المفضلة المحلية'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          setState(() {
            favoriteServices = [];
          });
        }
      }
    } catch (e) {
      setState(() {
        favoriteServices = [];
      });
    }
  }

  Future<void> remove(int serviceId) async {
    final success = await ApiService.removeFavorite(widget.userId, serviceId);
    if (success) {
      setState(() {
        favoriteServices.removeWhere((s) => s['id'] == serviceId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم الحذف من المفضلة')));
    }
  }

  Future<void> _navigateToBookings() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.bookingStatus,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.userHome,
        (route) => false,
      );
      return false;
    },
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, RouteNames.userHome),
          ),
        ),
        body: favoriteServices.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد خدمات مفضلة',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'أضف خدماتك المفضلة لتجدها هنا',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteServices.length,
                itemBuilder: (context, index) {
                  final service = favoriteServices[index];
                  // تحويل البيانات إلى Service
                  final serviceModel = Service(
                    id: service['id'] ?? 0,
                    providerId: service['provider_id'] ?? 0,
                    categoryId: service['category_id'] ?? 0,
                    title: service['name'] ?? '',
                    description: service['description'] ?? '',
                    price: (service['price'] ?? 0.0).toDouble(),
                    originalPrice: service['original_price'] != null
                        ? (service['original_price'] as num).toDouble()
                        : null,
                    duration: service['duration'] ?? 0,
                    images: service['images'] != null
                        ? List<String>.from(service['images'])
                        : [],
                    isActive: service['is_active'] ?? true,
                    isVerified: service['is_verified'] ?? false,
                    isFeatured: service['is_featured'] ?? false,
                    rating: (service['rating'] ?? 0.0).toDouble(),
                    totalRatings: service['total_ratings'] ?? 0,
                    bookingCount: service['booking_count'] ?? 0,
                    favoriteCount: service['favorite_count'] ?? 0,
                    specifications: service['specifications'],
                    tags: service['tags'] != null
                        ? List<String>.from(service['tags'])
                        : [],
                    location: service['location'] ?? '',
                    latitude: service['latitude'] != null
                        ? (service['latitude'] as num).toDouble()
                        : null,
                    longitude: service['longitude'] != null
                        ? (service['longitude'] as num).toDouble()
                        : null,
                    address: service['address'] ?? '',
                    city: service['city'] ?? '',
                    maxGuests: service['max_guests'],
                    cancellationPolicy: service['cancellation_policy'],
                    depositRequired: service['deposit_required'] ?? false,
                    depositAmount: service['deposit_amount'] != null
                        ? (service['deposit_amount'] as num).toDouble()
                        : null,
                    paymentTerms: service['payment_terms'],
                    availability: service['availability'],
                    createdAt: service['created_at'] ?? '',
                    updatedAt: service['updated_at'] ?? '',
                    categoryName: service['category_name'],
                    providerName: service['provider_name'],
                    providerRating: service['provider_rating'] != null
                        ? (service['provider_rating'] as num).toDouble()
                        : null,
                    providerImage: service['provider_image'],
                  );
                  return ServiceCard(
                    service: serviceModel,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/service_details',
                        arguments: {
                          'name': serviceModel.title,
                          'description': serviceModel.description,
                          'image': serviceModel.images.isNotEmpty
                              ? serviceModel.images.first
                              : '',
                          'price': serviceModel.price,
                          'provider_name': serviceModel.providerName ?? '',
                        },
                      );
                    },
                    onCall:
                        null, // حذف زر الاتصال لأنه يعتمد على خاصية غير موجودة
                  );
                },
              ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 2,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 2) return; // بالفعل في صفحة المفضلة
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, RouteNames.userHome);
                break;
              case 1:
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.serviceSearch,
                );
                break;
              case 3:
                _navigateToBookings();
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'الطلبات'),
          ],
        ),
      ),
    ),
  );
}
