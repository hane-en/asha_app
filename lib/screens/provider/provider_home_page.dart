import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_names.dart';
import 'my_services_page.dart';
import 'add_service_page.dart';
import 'my_ads_page.dart';
import 'my_bookings_page.dart';
import 'send_massage_page.dart';
import 'reviews_page.dart';

class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _providerName;
  String? _providerStatus;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _providerName = prefs.getString('provider_name');
        _providerStatus = prefs.getString('provider_status');
      });
    } catch (e) {
      print('Error loading provider data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showStatusMessage() {
    var message = '';
    Color color = Colors.green;

    switch (_providerStatus) {
      case 'pending':
        message = 'حسابك قيد المراجعة من قبل الإدارة';
        color = Colors.orange;
        break;
      case 'approved':
        message = 'حسابك مفعل ويمكنك تقديم الخدمات';
        color = Colors.green;
        break;
      case 'rejected':
        message = 'تم رفض حسابك، يرجى التواصل مع الإدارة';
        color = Colors.red;
        break;
      default:
        message = 'حالة الحساب غير معروفة';
        color = Colors.grey;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
              const Icon(Icons.business, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'لوحة مزود الخدمة',
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
              tooltip: 'الإشعارات',
              onPressed: () {
                Navigator.pushNamed(context, '/provider-notifications');
              },
            ),
            IconButton(
              icon: const Icon(Icons.info, color: Colors.white),
              tooltip: 'حالة الحساب',
              onPressed: _showStatusMessage,
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
                          Icons.business,
                          size: 40,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _providerName ?? 'مزود الخدمة',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _providerStatus == 'approved'
                              ? 'مفعل'
                              : 'قيد المراجعة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
                      leading: const Icon(Icons.home, color: Colors.purple),
                      title: const Text('الرئيسية'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedIndex = 0);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      title: const Text('قيد الانتظار'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.providerPending);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.design_services,
                        color: Colors.blue,
                      ),
                      title: const Text('الخدمات'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyServicesPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.book_online,
                        color: Colors.purple,
                      ),
                      title: const Text('الحجوزات'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.campaign, color: Colors.red),
                      title: const Text('الإعلانات'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyAdsPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.rate_review,
                        color: Colors.amber,
                      ),
                      title: const Text('التعليقات والتقييمات'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReviewsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.analytics,
                        color: Colors.indigo,
                      ),
                      title: const Text('الإحصائيات'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.providerAnalytics,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: const Text('تعديل البيانات الشخصية'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          RouteNames.editProviderProfile,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: const Text('الإعدادات'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.providerSettings,
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help, color: Colors.grey),
                      title: const Text('المساعدة'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.providerHelp);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ترحيب
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple,
                            Color.fromARGB(255, 170, 14, 201),
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مرحباً ${_providerName ?? 'بك'}! 👋',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _providerStatus == 'approved'
                                          ? 'حسابك مفعل ويمكنك تقديم الخدمات'
                                          : 'حسابك قيد المراجعة من قبل الإدارة',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // الإحصائيات السريعة
                    const Text(
                      'إحصائيات سريعة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'الخدمات',
                            '12',
                            Icons.design_services,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'الحجوزات',
                            '8',
                            Icons.book_online,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'الإعلانات',
                            '5',
                            Icons.campaign,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'التقييمات',
                            '4.8',
                            Icons.star,
                            Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // الإجراءات السريعة
                    const Text(
                      'الإجراءات السريعة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionCard(
                          'إضافة خدمة',
                          Icons.add_circle,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddServicePage()),
                          ),
                        ),
                        _buildActionCard(
                          'إعلاناتي وإضافة إعلان',
                          Icons.campaign,
                          Colors.orange,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyAdsPage(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'إرسال رسالة',
                          Icons.message,
                          Colors.purple,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SendMessagePage(
                                receiverPhone: '+967xxxxxxxxx',
                              ),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'عرض الإحصائيات',
                          Icons.analytics,
                          Colors.indigo,
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.providerAnalytics,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // التنبيهات
                    if (_providerStatus != 'approved')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حسابك قيد المراجعة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'سيتم مراجعة حسابك من قبل الإدارة قريباً',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.deepPurple,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.providerHome,
                  (route) => false,
                );
                break;
              case 1:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.providerPending,
                  (route) => false,
                );
                break;
              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.myServices,
                  (route) => false,
                );
                break;
              case 3:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.myBookings,
                  (route) => false,
                );
                break;
              case 4:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.myAds,
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
    ),
  );

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
