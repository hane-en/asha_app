import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../models/service_model.dart';
import 'service_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
=======
import '../../services/api_service.dart';
import '../../widgets/service_card.dart';
import '../../models/service_model.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'details_page.dart';
import '../../routes/app_routes.dart';
import 'dart:convert';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.userId});
  final int userId;
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

<<<<<<< HEAD
class _FavoritesPageState extends State<FavoritesPage> {
  List<Service> favorites = [];
  bool _isLoading = false;
=======
class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> favoriteServices = [];
  bool isLoading = false;
  String? error;
  String searchQuery = '';
  String selectedCategory = 'الكل';
  List<String> categories = ['الكل'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
=======
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
      error = null;
    });

>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
    try {
      final userId = await _getUserId();
      if (userId != null) {
<<<<<<< HEAD
        final favoritesData = await ApiService.getFavorites(userId);

        setState(() {
          favorites = favoritesData.map((data) => Service.fromJson(data)).toList();
        });
=======
        // المستخدم مسجل دخول - جلب المفضلة من الخادم
        try {
          final results = await ApiService.getUserFavorites(userId);

          if (results['success'] && results['data'] != null) {
            final data = results['data'] as List;
            setState(() {
              favoriteServices = data.cast<Map<String, dynamic>>();
              isLoading = false;
            });
            _updateCategories();
            _animationController.forward();
          } else {
            setState(() {
              favoriteServices = [];
              isLoading = false;
              error = results['message'] ?? 'فشل في تحميل المفضلة';
            });
          }
        } catch (e) {
          setState(() {
            favoriteServices = [];
            isLoading = false;
            error = 'خطأ في الاتصال: $e';
          });
        }
      } else {
        // المستخدم غير مسجل دخول - جلب المفضلة المحلية
        final localFavorites = prefs.getStringList('local_favorites') ?? [];

        if (localFavorites.isNotEmpty) {
          final localFavoritesData = localFavorites.map((serviceJson) {
            final service = json.decode(serviceJson);
            return service as Map<String, dynamic>;
          }).toList();

          setState(() {
            favoriteServices = localFavoritesData;
            isLoading = false;
          });
          _updateCategories();
          _animationController.forward();
        } else {
          // عرض بيانات تجريبية
          final demoFavorites = [
            {
              'id': 1,
              'name': 'قاعة الزين',
              'title': 'قاعة الزين',
              'description': 'قاعة تلبي كل المناسبات',
              'price': 500000.0,
              'images': ['hall1.jpg'],
              'is_active': true,
              'is_verified': true,
              'is_featured': false,
              'rating': 4.5,
              'avg_rating': 4.5,
              'total_ratings': 12,
              'reviews_count': 12,
              'booking_count': 5,
              'favorite_count': 3,
              'provider_id': 2,
              'provider_name': 'قاعة الزين',
              'category_id': 1,
              'category_name': 'قاعات الأفراح',
              'created_at': '2025-07-30 21:07:36',
              'updated_at': '2025-07-30 21:07:36',
            },
            {
              'id': 2,
              'name': 'أضواء فوتو',
              'title': 'أضواء فوتو',
              'description': 'لتصوير كل المناسبات والأفراح',
              'price': 500000.0,
              'images': ['photo1.jpg'],
              'is_active': true,
              'is_verified': true,
              'is_featured': true,
              'rating': 4.8,
              'avg_rating': 4.8,
              'total_ratings': 8,
              'reviews_count': 8,
              'booking_count': 3,
              'favorite_count': 2,
              'provider_id': 5,
              'provider_name': 'أضواء فوتو',
              'category_id': 3,
              'category_name': 'التصوير',
              'created_at': '2025-07-30 21:07:36',
              'updated_at': '2025-07-30 21:07:36',
            },
            {
              'id': 3,
              'name': 'سونا كيك',
              'title': 'سونا كيك',
              'description': 'حلويات مناسبتك علينا',
              'price': 4000.0,
              'images': ['cake1.jpg'],
              'is_active': true,
              'is_verified': true,
              'is_featured': false,
              'rating': 4.2,
              'avg_rating': 4.2,
              'total_ratings': 15,
              'reviews_count': 15,
              'booking_count': 7,
              'favorite_count': 4,
              'provider_id': 6,
              'provider_name': 'سونا كيك',
              'category_id': 5,
              'category_name': 'الحلويات',
              'created_at': '2025-07-30 21:07:36',
              'updated_at': '2025-07-30 21:07:36',
            },
          ];

          setState(() {
            favoriteServices = demoFavorites;
            isLoading = false;
          });
          _updateCategories();
          _animationController.forward();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('عرض بيانات تجريبية للمفضلة'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
      }
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
<<<<<<< HEAD
        favorites = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(Service service) async {
    try {
      final userId = await _getUserId();
      if (userId != null) {
        await ApiService.removeFromFavorites(userId, service.id);
        setState(() {
          favorites.removeWhere((item) => item.id == service.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إزالة الخدمة من المفضلة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في إزالة الخدمة: $e')));
=======
        favoriteServices = [];
        isLoading = false;
        error = 'خطأ في تحميل المفضلة: $e';
      });
    }
  }

  void _updateCategories() {
    final categorySet = <String>{'الكل'};
    for (final service in favoriteServices) {
      final categoryName = service['category_name'] as String?;
      if (categoryName != null) {
        categorySet.add(categoryName);
      }
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
    }
    setState(() {
      categories = categorySet.toList();
    });
  }

<<<<<<< HEAD
  void _showServiceDetails(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceDetailsPage(service: service)),
    );
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
=======
  List<Map<String, dynamic>> get filteredServices {
    return favoriteServices.where((service) {
      final matchesSearch =
          searchQuery.isEmpty ||
          service['name'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          service['description'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      final matchesCategory =
          selectedCategory == 'الكل' ||
          service['category_name'] == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('المفضلة', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
=======
        title: const Text(
          'المفضلة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadFavorites,
            tooltip: 'تحديث',
          ),
        ],
      ),
<<<<<<< HEAD
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
=======
      body: Column(
        children: [
          // شريط البحث والفلترة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // حقل البحث
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'البحث في المفضلة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // فلتر الفئات
                if (categories.length > 1)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.purple.shade100,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.purple.shade700
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // إحصائيات سريعة
          if (favoriteServices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
                children: [
                  Icon(Icons.favorite, color: Colors.purple.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredServices.length} خدمة في المفضلة',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    'إجمالي: ${favoriteServices.length}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
<<<<<<< HEAD
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final service = favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _showServiceDetails(service),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // صورة الخدمة
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primaryColor.withOpacity(0.1),
                            ),
                            child: service.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      service.images.first,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                          ),

                          const SizedBox(width: 16),

                          // معلومات الخدمة
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${service.price} ريال',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (service.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    service.description!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // زر الإزالة من المفضلة
                          IconButton(
                            onPressed: () => _removeFromFavorites(service),
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            tooltip: 'إزالة من المفضلة',
                          ),
                        ],
                      ),
=======
            ),

          // قائمة الخدمات
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? _buildErrorWidget()
                : filteredServices.isEmpty
                ? _buildEmptyWidget()
                : _buildServicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildServiceCard(service),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteNames.serviceProviders,
            arguments: {
              'service_id': service['id'],
              'service_name': service['name'] ?? 'الخدمة',
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // صورة الخدمة
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          service['images'] != null &&
                              service['images'].isNotEmpty
                          ? Image.network(
                              service['images'][0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // تفاصيل الخدمة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? 'خدمة غير محددة',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          service['description'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${service['rating'] ?? 0.0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${service['reviews_count'] ?? 0} تقييم)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
                    ),
                  ),

                  // زر الحذف من المفضلة
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _removeFromFavorites(service),
                    tooltip: 'إزالة من المفضلة',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // معلومات إضافية
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service['category_name'] ?? 'غير محدد',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${service['price']?.toStringAsFixed(0) ?? '0'} ريال',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات في المفضلة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة الخدمات التي تعجبك إلى المفضلة',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.userHome);
            },
            icon: const Icon(Icons.explore),
            label: const Text('استكشف الخدمات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'فشل في تحميل المفضلة',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: loadFavorites,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromFavorites(Map<String, dynamic> service) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // حذف من الخادم - سيتم إضافة API call لاحقاً
        // await ApiService.removeFromFavorites(userId, service['id']);
      } else {
        // حذف من التخزين المحلي
        final localFavorites = prefs.getStringList('local_favorites') ?? [];
        localFavorites.removeWhere((serviceJson) {
          final serviceData = json.decode(serviceJson);
          return serviceData['id'] == service['id'];
        });
        await prefs.setStringList('local_favorites', localFavorites);
      }

      setState(() {
        favoriteServices.removeWhere((s) => s['id'] == service['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('تم إزالة ${service['name']} من المفضلة'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('فشل في إزالة الخدمة من المفضلة'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
