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
                    // تحويل البيانات إلى ServiceModel
                    final serviceModel = ServiceModel(
                      id: service['id'],
                      name: service['title'] ?? service['name'] ?? '',
                      description: service['description'] ?? '',
                      price: (service['price'] ?? 0).toDouble(),
                      category: service['category'] ?? '',
                      providerId: service['provider_id'] ?? 0,
                      providerName: service['provider_name'] ?? '',
                      providerPhone: service['provider_phone'],
                      image: service['image'],
                      rating: (service['rating'] ?? 0).toDouble(),
                      reviewCount: service['review_count'] ?? 0,
                      latitude: service['latitude']?.toDouble(),
                      longitude: service['longitude']?.toDouble(),
                      isActive: service['is_active'] ?? true,
                    );

                    return ServiceCard(
                      service: serviceModel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailsPage(
                              service: {
                                'name': serviceModel.name,
                                'description': serviceModel.description,
                                'image': serviceModel.image,
                                'price': serviceModel.price,
                                'provider_name': serviceModel.providerName,
                              },
                            ),
                          ),
                        );
                      },
                      onCall: serviceModel.providerPhone != null
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري الاتصال...'),
                                  backgroundColor: Colors.purple,
                                ),
                              );
                            }
                          : null,
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'المفضلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'الطلبات',
              ),
            ],
          ),
        ),
      ),
    );
}
