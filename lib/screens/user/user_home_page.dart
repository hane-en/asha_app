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
    print('🏠 UserHomePage initState called');
    _loadUserData();
    _loadCategories();
    _loadAds();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _userName = prefs.getString('user_name');
          _userRole = prefs.getString('role');
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categoriesData = await ApiService.getCategories();

      if (categoriesData.isNotEmpty) {
        setState(() {
          categories = categoriesData
              .map((data) => CategoryModel.fromJson(data))
              .toList();
        });
      } else {
        setState(() {
          categories = [];
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        categories = [];
      });
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadAds() async {
    setState(() => _isLoadingAds = true);
    try {
      final adsData = await ApiService.getAllAds();

      setState(() {
        ads = adsData;
      });
    } catch (e) {
      print('Error loading ads: $e');
      setState(() {
        ads = [];
      });
    } finally {
      setState(() => _isLoadingAds = false);
    }
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
    print('🏠 UserHomePage build method called');
    return WillPopScope(
      onWillPop: () async => true,
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.purple, Colors.purpleAccent],
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
                          _userName ?? 'المستخدم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _userRole == 'admin' ? 'مدير' : 'مستخدم',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
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
                        leading: const Icon(Icons.home),
                        title: const Text('الرئيسية'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('المفضلة'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToFavorites();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.book_online),
                        title: const Text('حجوزاتي'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToBookings();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('الإشعارات'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToNotifications();
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('المساعدة'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToHelp();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('الإعدادات'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToSettings();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'حذف الحساب',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToDeleteAccount();
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('إنشاء حساب جديد'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SignupPage(source: 'drawer'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('تسجيل الدخول'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout),
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
              : Column(
                  children: [
                    // الإعلانات
                    if (ads.isNotEmpty)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.all(16),
                        child: AdsCarouselWidget(ads: ads),
                      ),

                    // الفئات
                    Expanded(
                      child: _isLoadingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : categories.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد فئات متاحة',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.2,
                                  ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return GestureDetector(
                                  onTap: () => _navigateToCategory(category),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primaryColor,
                                            AppColors.primaryColor.withOpacity(
                                              0.8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.category,
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            category.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });

              switch (index) {
                case 0:
                  // البقاء في الصفحة الرئيسية
                  break;
                case 1:
                  _navigateToFavorites();
                  break;
                case 2:
                  _navigateToBookings();
                  break;
                case 3:
                  // إعدادات المستخدم
                  break;
              }
            },
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.grey,
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
