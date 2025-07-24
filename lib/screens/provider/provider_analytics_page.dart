import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProviderAnalyticsPage extends StatefulWidget {
  const ProviderAnalyticsPage({super.key});

  @override
  State<ProviderAnalyticsPage> createState() => _ProviderAnalyticsPageState();
}

class _ProviderAnalyticsPageState extends State<ProviderAnalyticsPage> {
  int _selectedIndex = 5; // 5 للإحصائيات

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'label': 'الخدمات',
        'value': 12,
        'icon': Icons.design_services,
        'color': Colors.blue,
      },
      {
        'label': 'الحجوزات',
        'value': 8,
        'icon': Icons.book_online,
        'color': Colors.green,
      },
      {
        'label': 'الإعلانات',
        'value': 5,
        'icon': Icons.campaign,
        'color': Colors.orange,
      },
      {
        'label': 'التقييمات',
        'value': 4.8,
        'icon': Icons.star,
        'color': Colors.yellow[800],
      },
    ];
    final bookings = [
      {'service': 'قاعة أفراح', 'date': '2024-06-01', 'status': 'مؤكد'},
      {'service': 'ديكور', 'date': '2024-06-05', 'status': 'بانتظار'},
      {'service': 'تصوير', 'date': '2024-06-10', 'status': 'ملغي'},
    ];
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات عامة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.map((stat) => _buildStatCard(stat)).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'جدول الحجوزات الأخيرة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildBookingsTable(bookings),
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

  Widget _buildStatCard(Map stat) => Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat['icon'], color: stat['color'], size: 32),
          const SizedBox(height: 8),
          Text(
            stat['value'].toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: stat['color'],
            ),
          ),
          const SizedBox(height: 4),
          Text(stat['label'], style: const TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );

  Widget _buildBookingsTable(List bookings) => Card(
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
                DataCell(Text(b['service'])),
                DataCell(Text(b['date'])),
                DataCell(Text(b['status'])),
              ],
            ),
          )
          .toList(),
    ),
  );
}
