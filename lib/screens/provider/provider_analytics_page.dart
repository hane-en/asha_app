import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/provider_service.dart';

class ProviderAnalyticsPage extends StatefulWidget {
  const ProviderAnalyticsPage({super.key});

  @override
  State<ProviderAnalyticsPage> createState() => _ProviderAnalyticsPageState();
}

class _ProviderAnalyticsPageState extends State<ProviderAnalyticsPage> {
  int _selectedIndex = 5; // 5 للإحصائيات
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _recentServices = [];
  List<Map<String, dynamic>> _recentAds = [];
  List<Map<String, dynamic>> _recentReviews = [];
  bool _isLoading = true;
  int? _providerId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _providerId = prefs.getInt('user_id');
    });
    await _loadStats();
  }

  Future<void> _loadStats() async {
    if (_providerId == null) return;

    setState(() => _isLoading = true);

    try {
      // جلب الإحصائيات التفصيلية
      final response = await ProviderService.getProviderDetailedStats(
        _providerId!,
      );

      if (response['success'] == true) {
        setState(() {
          _stats = response['stats'];
          _recentBookings = List<Map<String, dynamic>>.from(
            response['recent_bookings'] ?? [],
          );
          _recentServices = List<Map<String, dynamic>>.from(
            response['recent_services'] ?? [],
          );
          _recentAds = List<Map<String, dynamic>>.from(
            response['recent_ads'] ?? [],
          );
          _recentReviews = List<Map<String, dynamic>>.from(
            response['recent_reviews'] ?? [],
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الإحصائيات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _buildStatsList() {
    if (_stats == null) return [];

    return [
      {
        'label': 'الخدمات',
        'value': _stats!['services'] ?? 0,
        'subtitle': '${_stats!['active_services'] ?? 0} نشط',
        'icon': Icons.design_services,
        'color': Colors.purple,
      },
      {
        'label': 'الحجوزات',
        'value': _stats!['bookings'] ?? 0,
        'subtitle': '${_stats!['completed_bookings'] ?? 0} مكتمل',
        'icon': Icons.book_online,
        'color': Colors.green,
      },
      {
        'label': 'الإعلانات',
        'value': _stats!['ads'] ?? 0,
        'subtitle': '${_stats!['active_ads'] ?? 0} نشط',
        'icon': Icons.campaign,
        'color': Colors.orange,
      },
      {
        'label': 'التقييمات',
        'value': _stats!['rating'] ?? 0.0,
        'subtitle': '${_stats!['total_reviews'] ?? 0} تقييم',
        'icon': Icons.star,
        'color': const Color.fromARGB(255, 112, 33, 224),
      },
      {
        'label': 'الإيرادات',
        'value': '${_stats!['total_revenue'] ?? 0} ريال',
        'subtitle': 'إجمالي المكتملة',
        'icon': Icons.attach_money,
        'color': Colors.teal,
      },
      {
        'label': 'قيد الانتظار',
        'value': _stats!['pending_bookings'] ?? 0,
        'subtitle': 'حجوزات بانتظار',
        'icon': Icons.pending_actions,
        'color': Colors.amber,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إحصائيات المزود',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.providerHome,
            (route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
            tooltip: 'تحديث الإحصائيات',
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
                AppRoutes.providerHome,
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('قيد الانتظار'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.providerPending,
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('خدماتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.myServices,
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('حجوزاتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.myBookings,
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('إعلاناتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.myAds,
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.indigo),
              title: const Text('الإحصائيات'),
              selected: true,
              selectedTileColor: Colors.purple.shade50,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // إحصائيات عامة
                    const Text(
                      'إحصائيات عامة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                      children: _buildStatsList()
                          .map((stat) => _buildStatCard(stat))
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    // الحجوزات الأخيرة
                    if (_recentBookings.isNotEmpty) ...[
                      const Text(
                        'الحجوزات الأخيرة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBookingsTable(_recentBookings),
                      const SizedBox(height: 24),
                    ],

                    // الخدمات الأخيرة
                    if (_recentServices.isNotEmpty) ...[
                      const Text(
                        'الخدمات الأخيرة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildServicesTable(_recentServices),
                      const SizedBox(height: 24),
                    ],

                    // الإعلانات الأخيرة
                    if (_recentAds.isNotEmpty) ...[
                      const Text(
                        'الإعلانات الأخيرة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAdsTable(_recentAds),
                      const SizedBox(height: 24),
                    ],

                    // التقييمات الأخيرة
                    if (_recentReviews.isNotEmpty) ...[
                      const Text(
                        'التقييمات الأخيرة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildReviewsTable(_recentReviews),
                    ],
                  ],
                ),
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
            case 5:
              // أنت بالفعل في صفحة الإحصائيات
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
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'الإحصائيات',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) => Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat['icon'], color: stat['color'], size: 32),
          const SizedBox(height: 8),
          Text(
            stat['value'].toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: stat['color'],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            stat['label'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          if (stat['subtitle'] != null) ...[
            const SizedBox(height: 2),
            Text(
              stat['subtitle'],
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildBookingsTable(List<Map<String, dynamic>> bookings) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: DataTable(
      columns: const [
        DataColumn(label: Text('الخدمة')),
        DataColumn(label: Text('التاريخ')),
        DataColumn(label: Text('الحالة')),
      ],
      rows: bookings
          .map(
            (b) => DataRow(
              cells: [
                DataCell(
                  Text(b['service_title'] ?? b['service'] ?? 'غير محدد'),
                ),
                DataCell(Text(b['booking_date'] ?? b['date'] ?? 'غير محدد')),
                DataCell(_buildStatusChip(b['status'] ?? 'غير محدد')),
              ],
            ),
          )
          .toList(),
    ),
  );

  Widget _buildServicesTable(List<Map<String, dynamic>> services) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: DataTable(
      columns: const [
        DataColumn(label: Text('الخدمة')),
        DataColumn(label: Text('التقييم')),
        DataColumn(label: Text('الحالة')),
      ],
      rows: services
          .map(
            (s) => DataRow(
              cells: [
                DataCell(Text(s['title'] ?? 'غير محدد')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s['rating']?.toString() ?? '0'),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
                DataCell(
                  _buildStatusChip(s['is_active'] == 1 ? 'نشط' : 'غير نشط'),
                ),
              ],
            ),
          )
          .toList(),
    ),
  );

  Widget _buildAdsTable(List<Map<String, dynamic>> ads) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: DataTable(
      columns: const [
        DataColumn(label: Text('الإعلان')),
        DataColumn(label: Text('التاريخ')),
        DataColumn(label: Text('الحالة')),
      ],
      rows: ads
          .map(
            (a) => DataRow(
              cells: [
                DataCell(Text(a['title'] ?? 'غير محدد')),
                DataCell(Text(a['created_at'] ?? 'غير محدد')),
                DataCell(
                  _buildStatusChip(a['is_active'] == 1 ? 'نشط' : 'غير نشط'),
                ),
              ],
            ),
          )
          .toList(),
    ),
  );

  Widget _buildReviewsTable(List<Map<String, dynamic>> reviews) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: DataTable(
      columns: const [
        DataColumn(label: Text('المستخدم')),
        DataColumn(label: Text('التقييم')),
        DataColumn(label: Text('التعليق')),
      ],
      rows: reviews
          .map(
            (r) => DataRow(
              cells: [
                DataCell(Text(r['user_name'] ?? 'غير محدد')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(r['rating']?.toString() ?? '0'),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    r['comment'] ?? 'لا يوجد تعليق',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    ),
  );

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'قيد المراجعة':
      case 'بانتظار':
        color = Colors.orange;
        break;
      case 'confirmed':
      case 'مؤكد':
      case 'نشط':
        color = Colors.green;
        break;
      case 'completed':
      case 'مكتمل':
        color = Colors.blue;
        break;
      case 'cancelled':
      case 'ملغي':
        color = Colors.red;
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        break;
      case 'غير نشط':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
