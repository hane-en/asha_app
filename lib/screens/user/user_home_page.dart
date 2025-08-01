import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_names.dart';
import '../../widgets/ads_carousel_widget.dart';
import '../../services/api_service.dart';
import '../../models/category_model.dart';
import '../../models/service_with_offers_model.dart';
import 'favorites_page.dart';
import '../auth/register_screen.dart';
import '../auth/login_screen.dart';
import 'search_page.dart';
import 'service_list_page.dart';
import 'booking_status_page.dart';
import '../admin/all_bookings_page.dart';
import 'delete_account_page.dart';
import 'providers_by_category_screen.dart';
import 'dart:convert'; // Added for json.decode

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
  List<ServiceWithOffersModel> featuredServices = [];
  List<Map<String, dynamic>> providers = [];
  bool _isLoadingCategories = false;
  bool _isLoadingServices = false;
  bool _isLoadingProviders = false;
  bool _showFeaturedServices = true; // متغير للتحكم في ظهور الخدمات المميزة

  @override
  void initState() {
    super.initState();
    print('UserHomePage initState called'); // Debug info
    _loadUserData();
    _loadCategories();
    _loadFeaturedServices();
    _loadProviders();
  }

  @override
  void dispose() {
    // تنظيف الموارد
    print('UserHomePage dispose called'); // Debug info
    super.dispose();
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
      print(
        'Error loading categories: $e, adding default categories',
      ); // Debug info
      // إضافة فئات افتراضية في حالة الخطأ
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

  Future<void> _loadFeaturedServices() async {
    setState(() => _isLoadingServices = true);
    try {
      // جلب الخدمات المميزة من قاعدة البيانات
      final result = await ApiService.getAllServices();
      print('Featured services API response: $result'); // Debug info
      if (result['success'] && result['data'] != null) {
        final servicesData = result['data'] as List;
        print(
          'Featured services data length: ${servicesData.length}',
        ); // Debug info

        // إزالة التكرار واختيار خدمات مختلفة فقط
        final uniqueServices = <ServiceWithOffersModel>[];
        final seenTitles = <String>{};

        for (final data in servicesData) {
          final service = ServiceWithOffersModel.fromJson(data);
          if (!seenTitles.contains(service.title)) {
            seenTitles.add(service.title);
            uniqueServices.add(service);
          }
          // إيقاف عند الوصول لـ 6 خدمات مختلفة
          if (uniqueServices.length >= 6) break;
        }

        setState(() {
          featuredServices = uniqueServices;
        });
        print(
          'Featured services loaded: ${featuredServices.length}',
        ); // Debug info
      } else {
        print(
          'Featured services API failed: ${result['message']}',
        ); // Debug info
        setState(() {
          featuredServices = [];
        });
      }
    } catch (e) {
      print('Error loading featured services: $e');
      setState(() {
        featuredServices = [];
      });
    } finally {
      setState(() => _isLoadingServices = false);
    }
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoadingProviders = true);
    try {
      final result = await ApiService.getAllProviders();
      print('Providers API response: $result'); // Debug info
      if (result['success'] && result['data'] != null) {
        final providersData = result['data']['providers'] as List;
        print('Providers data length: ${providersData.length}'); // Debug info

        setState(() {
          providers = providersData.cast<Map<String, dynamic>>();
        });
        print('Providers loaded: ${providers.length}'); // Debug info
      } else {
        print('Providers API failed: ${result['message']}'); // Debug info
        setState(() {
          providers = [];
        });
      }
    } catch (e) {
      print('Error loading providers: $e');
      setState(() {
        providers = [];
      });
    } finally {
      setState(() => _isLoadingProviders = false);
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
    try {
      print('Navigating to category: ${category.title}'); // Debug info
      Navigator.pushNamed(
        context,
        RouteNames.providersByCategory,
        arguments: {'categoryId': category.id, 'categoryName': category.title},
      );
    } catch (e) {
      print('Error navigating to category: $e'); // Debug info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التنقل إلى الفئة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToFavorites() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.favorites,
      (route) => false,
    );
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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            backgroundColor: Colors.purple,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white),
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  RouteNames.favorites,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  RouteNames.serviceSearch,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  RouteNames.bookingStatus,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ],
          ),
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8e24aa), Color(0xFFce93d8)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userName ?? 'مرحباً بك',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_userRole != null)
                          Text(
                            _userRole == 'user' ? 'مستخدم' : 'مزود خدمة',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home, color: Colors.purple),
                        title: const Text('خدمات المناسبات'),
                        selected: _selectedIndex == 0,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 0);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: const Text('المفضلة'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToFavorites();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.event, color: Colors.green),
                        title: const Text('الطلبات'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToBookings();
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.person_add,
                          color: Colors.orange,
                        ),
                        title: const Text('إنشاء حساب'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.login, color: Colors.purple),
                        title: const Text('تسجيل الدخول'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.login,
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue),
                        title: const Text('تعديل البيانات الشخصية'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            RouteNames.editUserProfile,
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text('حذف الحساب'),
                        onTap: () async {
                          Navigator.pop(context);
                          final userId = await _getUserId();
                          if (userId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeleteAccountPage(userId: userId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى تسجيل الدخول أولاً'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: const Text('الإعدادات'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.userSettings);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.grey),
                        title: const Text('المساعدة'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.help);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.storage, color: Colors.green),
                        title: const Text('اختبار قاعدة البيانات'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, RouteNames.databaseTest);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                        title: const Text('تسجيل الخروج'),
                        onTap: () {
                          Navigator.pop(context);
                          _logout();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            selectedItemColor: Colors.purple,
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
}
