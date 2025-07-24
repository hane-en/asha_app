import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_names.dart';
import 'favorites_page.dart';
import '../auth/signup_page.dart';
import '../auth/login_page.dart';
import 'search_page.dart';
import 'service_list_page.dart';
import 'booking_status_page.dart';
import '../admin/all_bookings_page.dart';

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

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'القاعات',
      'image': 'assets/images/halls.jpg',
      'icon': Icons.meeting_room,
      'color': const Color(0xFF8e24aa),
      'description': 'قاعات الأفراح والحفلات',
    },
    {
      'title': 'الجاتوهات',
      'image': 'assets/images/cakes.jpg',
      'icon': Icons.cake,
      'color': const Color(0xFFce93d8),
      'description': 'حلويات وأكواب كيك مميزة',
    },
    {
      'title': 'الديكور',
      'image': 'assets/images/decor.jpg',
      'icon': Icons.celebration,
      'color': const Color(0xFFba68c8),
      'description': 'تنسيقات وديكورات احتفالية',
    },
    {
      'title': 'التصوير',
      'image': 'assets/images/photo.jpg',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFab47bc),
      'description': 'تصوير احترافي للمناسبات',
    },
    {
      'title': 'فساتين الأفراح',
      'image': 'assets/images/dresses.jpg',
      'icon': Icons.checkroom,
      'color': const Color(0xFF8e24aa),
      'description': 'فساتين عرائس أنيقة',
    },
    {
      'title': 'DJ',
      'image': 'assets/images/dj.jpg',
      'icon': Icons.music_note,
      'color': const Color(0xFFce93d8),
      'description': 'موسيقى وترفيه احترافي',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name');
        _userRole = prefs.getString('role');
      });
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceListPage(category: category)),
    );
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
  Widget build(BuildContext context) => WillPopScope(
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
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                RouteNames.serviceSearch,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, RouteNames.favorites),
            ),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
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
                      title: const Text('الصفحة الرئيسية'),
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
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.login, color: Colors.purple),
                      title: const Text('تسجيل الدخول'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                    const Divider(),
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
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app, color: Colors.red),
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
            : Column(
                children: [
                  // ترحيب
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8e24aa), Color(0xFFba68c8)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً ${_userName ?? 'بك'}! 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 237, 172, 255),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اكتشف أفضل خدمات المناسبات في منطقتك',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 221, 155, 233),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // الفئات
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () => _navigateToCategory(category['title']),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    category['color'].withOpacity(0.8),
                                    category['color'].withOpacity(0.6),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // صورة الخلفية
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: category['color'].withOpacity(
                                            0.3,
                                          ),
                                        ),
                                        child: Icon(
                                          category['icon'],
                                          size: 60,
                                          color: Colors.white.withOpacity(0.3),
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
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['title'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            category['description'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
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
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.userHome,
                  (route) => false,
                );
                break;
              case 1:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.serviceSearch,
                  (route) => false,
                );
                break;
              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.favorites,
                  (route) => false,
                );
                break;
              case 3:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.bookingStatus,
                  (route) => false,
                );
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
