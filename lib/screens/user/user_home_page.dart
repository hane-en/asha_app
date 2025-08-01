import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_names.dart';
import '../../widgets/ads_carousel_widget.dart';
import '../../services/api_service.dart';
import '../../models/category_model.dart';
import '../../models/ad_model.dart';
import 'category_providers_page.dart';
import '../auth/signup_page.dart';
import '../auth/login_page.dart';
import 'search_page.dart';
import 'booking_status_page.dart';
import '../admin/all_bookings_page.dart';
import 'delete_account_page.dart';
import 'favorites_page.dart';
import 'notifications_page.dart';
import 'user_help_page.dart';
import 'settings_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _userName;
  String? _userRole;

  List<CategoryModel> categories = [];
  List<AdModel> ads = [];
  bool _isLoadingCategories = false;
  bool _isLoadingAds = false;

  @override
  void initState() {
    super.initState();
    print('UserHomePage initState called'); // Debug info
    _loadUserData();
    _loadCategories();
    _loadAds();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      try {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _userName = prefs.getString('user_name');
          _userRole = prefs.getString('role');
        });
        print('User data loaded: $_userName, $_userRole'); // Debug info
      } catch (e) {
        print('Error loading user data: $e');
        setState(() {
          _userName = null;
          _userRole = null;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = null;
        _userRole = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      print('Loading categories...'); // Debug info
      final categoriesData = await ApiService.getAllCategories();
      print('Categories API response: $categoriesData'); // Debug info

      if (categoriesData['success'] && categoriesData['data'] != null) {
        final data = categoriesData['data'] as List;
        print('Categories data length: ${data.length}'); // Debug info
        print('Categories data: $data'); // Debug info

        if (data.isNotEmpty) {
          // إزالة التكرار في الفئات
          final uniqueCategories = <CategoryModel>[];
          final seenNames = <String>{};

          for (final item in data) {
            try {
              print('Processing category item: $item'); // Debug info
              final category = CategoryModel.fromJson(item);
              print('Created category: ${category.title}'); // Debug info

              if (!seenNames.contains(category.title)) {
                seenNames.add(category.title);
                uniqueCategories.add(category);
              }
            } catch (e) {
              print(
                'Error creating category from item $item: $e',
              ); // Debug info
            }
          }

          // عرض فقط أول 6 فئات أساسية
          final categoriesList = uniqueCategories.take(6).toList();

          print(
            'Categories loaded successfully: ${categoriesList.length}',
          ); // Debug info
          print(
            'Categories titles: ${categoriesList.map((c) => c.title).toList()}',
          ); // Debug info
          setState(() {
            categories = categoriesList;
          });
        } else {
          print(
            'No categories data found, adding default categories',
          ); // Debug info
          // إضافة فئات افتراضية
          setState(() {
            categories = [
              CategoryModel(
                id: 1,
                title: 'قاعات الأفراح',
                description: 'قاعات احتفالات وأفراح',
                icon: 'celebration',
                color: '#8e24aa',
                servicesCount: 2,
                isActive: true,
                createdAt: DateTime.now().toString(),
              ),
              CategoryModel(
                id: 2,
                title: 'الموسيقى والصوت',
                description: 'خدمات الموسيقى والصوتيات',
                icon: 'music_note',
                color: '#2196f3',
                servicesCount: 1,
                isActive: true,
                createdAt: DateTime.now().toString(),
              ),
              CategoryModel(
                id: 3,
                title: 'التصوير',
                description: 'خدمات التصوير الاحترافي',
                icon: 'camera_alt',
                color: '#ff9800',
                servicesCount: 2,
                isActive: true,
                createdAt: DateTime.now().toString(),
              ),
              CategoryModel(
                id: 4,
                title: 'التزيين والديكور',
                description: 'خدمات التزيين والديكور',
                icon: 'local_florist',
                color: '#4caf50',
                servicesCount: 2,
                isActive: true,
                createdAt: DateTime.now().toString(),
              ),
              CategoryModel(
                id: 5,
                title: 'الحلويات',
                description: 'حلويات المناسبات',
                icon: 'cake',
                color: '#e91e63',
                servicesCount: 2,
                isActive: true,
                createdAt: DateTime.now().toString(),
              ),
              CategoryModel(
                id: 6,
                title: 'الأزياء',
                description: 'فساتين وأزياء المناسبات',
                icon: 'checkroom',
                color: '#9c27b0',
                servicesCount: 2,
                isActive: true,
                createdAt: DateTime.now().toString(),
              ),
            ];
          });
        }
      } else {
        print(
          'Categories API failed: ${categoriesData['message']}, adding default categories',
        ); // Debug info
        // إضافة فئات افتراضية في حالة فشل API
        setState(() {
          categories = [
            CategoryModel(
              id: 1,
              title: 'قاعات الأفراح',
              description: 'قاعات احتفالات وأفراح',
              icon: 'celebration',
              color: '#8e24aa',
              servicesCount: 2,
              isActive: true,
              createdAt: DateTime.now().toString(),
            ),
            CategoryModel(
              id: 2,
              title: 'التصوير',
              description: 'خدمات التصوير الاحترافي',
              icon: 'camera_alt',
              color: '#ff9800',
              servicesCount: 2,
              isActive: true,
              createdAt: DateTime.now().toString(),
            ),
            CategoryModel(
              id: 3,
              title: 'الديكور',
              description: 'خدمات التزيين والديكور',
              icon: 'local_florist',
              color: '#4caf50',
              servicesCount: 2,
              isActive: true,
              createdAt: DateTime.now().toString(),
            ),
            CategoryModel(
              id: 4,
              title: 'الجاتوهات',
              description: 'جاتوهات وحلويات المناسبات',
              icon: 'cake',
              color: '#e91e63',
              servicesCount: 2,
              isActive: true,
              createdAt: DateTime.now().toString(),
            ),
            CategoryModel(
              id: 5,
              title: 'الموسيقى',
              description: 'خدمات الموسيقى والصوتيات',
              icon: 'music_note',
              color: '#2196f3',
              servicesCount: 1,
              isActive: true,
              createdAt: DateTime.now().toString(),
            ),
            CategoryModel(
              id: 6,
              title: 'الفساتين',
              description: 'فساتين وأزياء المناسبات',
              icon: 'checkroom',
              color: '#9c27b0',
              servicesCount: 2,
              isActive: true,
              createdAt: DateTime.now().toString(),
            ),
          ];
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        categories = [
          CategoryModel(
            id: 1,
            title: 'قاعات الأفراح',
            description: 'قاعات احتفالات وأفراح',
            icon: 'celebration',
            color: '#8e24aa',
            servicesCount: 2,
            isActive: true,
            createdAt: DateTime.now().toString(),
          ),
          CategoryModel(
            id: 2,
            title: 'التصوير',
            description: 'خدمات التصوير الاحترافي',
            icon: 'camera_alt',
            color: '#ff9800',
            servicesCount: 2,
            isActive: true,
            createdAt: DateTime.now().toString(),
          ),
          CategoryModel(
            id: 3,
            title: 'الديكور',
            description: 'خدمات التزيين والديكور',
            icon: 'local_florist',
            color: '#4caf50',
            servicesCount: 2,
            isActive: true,
            createdAt: DateTime.now().toString(),
          ),
          CategoryModel(
            id: 4,
            title: 'الجاتوهات',
            description: 'جاتوهات وحلويات المناسبات',
            icon: 'cake',
            color: '#e91e63',
            servicesCount: 2,
            isActive: true,
            createdAt: DateTime.now().toString(),
          ),
          CategoryModel(
            id: 5,
            title: 'الموسيقى',
            description: 'خدمات الموسيقى والصوتيات',
            icon: 'music_note',
            color: '#2196f3',
            servicesCount: 1,
            isActive: true,
            createdAt: DateTime.now().toString(),
          ),
          CategoryModel(
            id: 6,
            title: 'الفساتين',
            description: 'فساتين وأزياء المناسبات',
            icon: 'checkroom',
            color: '#9c27b0',
            servicesCount: 2,
            isActive: true,
            createdAt: DateTime.now().toString(),
          ),
        ];
      });
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadAds() async {
    setState(() => _isLoadingAds = true);
    try {
      final adsData = await ApiService.getAllAds();

      if (adsData['success'] && adsData['data'] != null) {
        final data = adsData['data'] as List;
        print('Ads data length: ${data.length}'); // Debug info
        print('Ads data: $data'); // Debug info

        if (data.isNotEmpty) {
          final uniqueAds = <AdModel>[];
          final seenTitles = <String>{};

          for (final item in data) {
            try {
              final ad = AdModel.fromJson(item);
              if (!seenTitles.contains(ad.title)) {
                seenTitles.add(ad.title);
                uniqueAds.add(ad);
              }
            } catch (e) {
              print(
                'Error creating ad from item $item: $e',
              ); // Debug info
            }
          }

          setState(() {
            ads = uniqueAds;
          });
          print(
            'Ads loaded successfully: ${ads.length}',
          ); // Debug info
        } else {
          print('No ads data found, adding default ads'); // Debug info
          setState(() {
            ads = [
              AdModel(
                id: 1,
                title: 'إعلان 1',
                subtitle: 'وصف لإعلان 1',
                imageUrl: 'assets/images/ad1.jpg',
                rating: '4.5',
                createdAt: DateTime.now().toString(),
              ),
              AdModel(
                id: 2,
                title: 'إعلان 2',
                subtitle: 'وصف لإعلان 2',
                imageUrl: 'assets/images/ad2.jpg',
                rating: '4.0',
                createdAt: DateTime.now().toString(),
              ),
              AdModel(
                id: 3,
                title: 'إعلان 3',
                subtitle: 'وصف لإعلان 3',
                imageUrl: 'assets/images/ad3.jpg',
                rating: '4.8',
                createdAt: DateTime.now().toString(),
              ),
            ];
          });
        }
      } else {
        print(
          'Ads API failed: ${adsData['message']}, adding default ads',
        ); // Debug info
        setState(() {
          ads = [
            AdModel(
              id: 1,
              title: 'إعلان 1',
              subtitle: 'وصف لإعلان 1',
              imageUrl: 'assets/images/ad1.jpg',
              rating: '4.5',
              createdAt: DateTime.now().toString(),
            ),
            AdModel(
              id: 2,
              title: 'إعلان 2',
              subtitle: 'وصف لإعلان 2',
              imageUrl: 'assets/images/ad2.jpg',
              rating: '4.0',
              createdAt: DateTime.now().toString(),
            ),
            AdModel(
              id: 3,
              title: 'إعلان 3',
              subtitle: 'وصف لإعلان 3',
              imageUrl: 'assets/images/ad3.jpg',
              rating: '4.8',
              createdAt: DateTime.now().toString(),
            ),
          ];
        });
      }
    } catch (e) {
      print('Error loading ads: $e');
      setState(() {
        ads = [];
      });
    } finally {
      setState(() => _isLoadingAds = false);
    }
  }

  Widget _buildAdCard(
    String title,
    String subtitle,
    String imagePath,
    String rating,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الإعلان
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple[400]!, Colors.purple[600]!],
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // محتوى الإعلان
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  void _navigateToCategory(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProvidersPage(
          categoryId: category.id,
          categoryName: category.title,
        ),
      ),
    );
  }

  Future<void> _navigateToFavorites() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesPage()),
    );
  }

  Future<void> _navigateToNotifications() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  Future<void> _navigateToHelp() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserHelpPage()),
    );
  }

  Future<void> _navigateToSettings() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  Future<void> _navigateToDeleteAccount() async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DeleteAccountPage(userId: userId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToBookings() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.bookingStatus,
      (route) => false,
    );
  }

  // إضافة خدمة إلى المفضلة
  Future<void> _addToFavorites(ServiceWithOffersModel service) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - إضافة إلى API
        final serviceMap = {
          'id': service.id,
          'title': service.title,
          'description': service.description,
          'price': service.price,
          'provider_name': service.provider?.name ?? 'مزود غير محدد',
          'category_name': service.category?.name ?? 'فئة غير محددة',
          'images': service.imageUrl != null ? [service.imageUrl!] : [],
        };

        final result = await ApiService.toggleFavorite(
          userId: userId,
          serviceId: service.id,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تمت الإضافة إلى المفضلة'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل في الإضافة إلى المفضلة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // المستخدم غير مسجل دخول - إضافة إلى المفضلة المحلية
        final localFavorites = prefs.getStringList('local_favorites') ?? [];

        // التحقق من عدم وجود الخدمة مسبقاً
        final serviceExists = localFavorites.any((serviceJson) {
          final existingService = json.decode(serviceJson);
          return existingService['id'] == service.id;
        });

        if (!serviceExists) {
          final serviceMap = {
            'id': service.id,
            'title': service.title,
            'description': service.description,
            'price': service.price,
            'provider_name': service.provider?.name ?? 'مزود غير محدد',
            'category_name': service.category?.name ?? 'فئة غير محددة',
            'images': service.imageUrl != null ? [service.imageUrl!] : [],
          };

          localFavorites.add(json.encode(serviceMap));
          await prefs.setStringList('local_favorites', localFavorites);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت الإضافة إلى المفضلة المحلية'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الخدمة موجودة بالفعل في المفضلة'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error adding to favorites: $e'); // Debug info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الإضافة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      'UserHomePage build - categories count: ${categories.length}, isLoading: $_isLoading, isLoadingCategories: $_isLoadingCategories',
    ); // Debug info

    return WillPopScope(
      onWillPop: () async => true,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.event, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'خدمات المناسبات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white),
                onPressed: () {
                  _navigateToFavorites();
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  _navigateToNotifications();
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // ترحيب - ثابت
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.purple[400]!, Colors.purple[600]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('👋', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'مرحباً بك!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'كتشف أفضل خدمات المناسبات في منطقتك',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // الإعلانات المميزة
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // عنوان الإعلانات
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.campaign,
                                        color: Colors.purple,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'إعلانات مميزة',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '11 إعلان',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // الإعلانات
                            SizedBox(
                              height: 180,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                children: [
                                  _buildAdCard(
                                    'ضوء القمر',
                                    'ديكورات فاخرة ومميزة',
                                    'assets/images/ad1.jpg',
                                    '4.0',
                                  ),
                                  _buildAdCard(
                                    'بارتي كوين',
                                    'تزيين وديكورات احترافية',
                                    'assets/images/ad2.jpg',
                                    '4.5',
                                  ),
                                  _buildAdCard(
                                    'إشراق السالمي',
                                    'تصوير مميز وبأسعار منافسة',
                                    'assets/images/ad3.jpg',
                                    '4.8',
                                  ),
                                  _buildAdCard(
                                    'أضواء فوتو',
                                    'تصوير احترافي لجميع المناسبات',
                                    'assets/images/ad4.jpg',
                                    '4.2',
                                  ),
                                ],
                              ),
                            ),
                            // نقاط التنقل
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // الخدمات المميزة
                      if (featuredServices.isNotEmpty &&
                          _showFeaturedServices) ...[
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'خدمات مميزة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteNames.serviceSearch,
                                  );
                                },
                                child: const Text('عرض الكل'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 160,
                          child: _isLoadingServices
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: featuredServices.length,
                                  itemBuilder: (context, index) {
                                    final service = featuredServices[index];
                                    return Container(
                                      width: 160,
                                      height: 160,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Card(
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // صورة الخدمة
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                              child: Container(
                                                height: 60,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                ),
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 25,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            // محتوى الخدمة
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // عنوان الخدمة
                                                    Text(
                                                      service.title,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    // اسم المزود
                                                    Text(
                                                      service.provider?.name ??
                                                          'مزود غير محدد',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 3),
                                                    // التقييم
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          size: 10,
                                                          color: Colors.amber,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        const Text(
                                                          '0.0',
                                                          style: TextStyle(
                                                            fontSize: 8,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    // السعر
                                                    Text(
                                                      '${(service.price ?? 3000.0).toStringAsFixed(0)} ر.ي',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.purple,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // المزودين المميزين - مؤقتاً مخفي

                      // الفئات
                      _isLoadingCategories
                          ? Container(
                              height: 120,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : categories.isEmpty
                          ? Container(
                              height: 120,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'لا توجد فئات متاحة',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'جاري تحميل الفئات...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // عنوان الفئات
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.category,
                                        color: Colors.purple,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'فئات الخدمات (${categories.length})',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // عرض الفئات بشكل عمودي
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.2,
                                        ),
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      try {
                                        final category = categories[index];
                                        print(
                                          'Building category card for: ${category.title}',
                                        );

                                        return Container(
                                          child: GestureDetector(
                                            onTap: () =>
                                                _navigateToCategory(category),
                                            child: Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      category.colorData
                                                          .withOpacity(0.8),
                                                      category.colorData
                                                          .withOpacity(0.6),
                                                    ],
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // صورة الخلفية
                                                    Positioned.fill(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                color: category
                                                                    .colorData
                                                                    .withOpacity(
                                                                      0.3,
                                                                    ),
                                                              ),
                                                          child: Icon(
                                                            category.iconData,
                                                            size: 30,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // المحتوى
                                                    Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      12,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              Colors.black
                                                                  .withOpacity(
                                                                    0.7,
                                                                  ),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Text(
                                                          category.title,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      } catch (e) {
                                        print(
                                          'Error building category card: $e',
                                        );
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 0,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: (index) async {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getInt('user_id') ?? 0;

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
                case 2:
                  Navigator.pushReplacementNamed(
                    context,
                    RouteNames.favorites,
                    arguments: {'userId': userId},
                  );
                  break;
                case 3:
                  Navigator.pushReplacementNamed(
                    context,
                    RouteNames.bookingStatus,
                    arguments: {'userId': userId},
                  );
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'المفضلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_online),
                label: 'الحجوزات',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
            ],
          ),
        ),
      ),
    );
  }
}
