import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/ad_model.dart';
import 'add_ad_page.dart';
import 'edit_ad_page.dart';

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  int currentIndex = 4;
  List<AdModel> _ads = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAds();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _loadAds() async {
    try {
      // سيتم إضافة هذه الدالة لاحقاً
      final ads = <AdModel>[];
      setState(() {
        _ads = ads.where((ad) => ad.providerId == _userId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading ads: $e');
    }
  }

  Future<void> _deleteAd(AdModel ad) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الإعلان "${ad.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // سيتم إضافة هذه الدالة لاحقاً
        final success = false;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم حذف الإعلان بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAds(); // إعادة تحميل الإعلانات
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ فشل في حذف الإعلان'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editAd(AdModel ad) async {
    // تحويل AdModel إلى Map للتوافق مع EditAdPage
    final adData = {
      'id': ad.id,
      'title': ad.title,
      'description': ad.description,
      'image': ad.image,
      'link': ad.link,
      'is_active': ad.isActive,
      'provider_id': ad.providerId,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAdPage(ad: adData)),
    );

    // إذا تم التعديل بنجاح، إعادة تحميل الإعلانات
    if (result == true) {
      _loadAds();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تحديث الإعلان بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildAdCard(AdModel ad) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة الإعلان
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: ad.image.isNotEmpty
                  ? Image.network(
                      'http://192.168.1.3/backend_php/${ad.image}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 60,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ),
            ),
          ),
          // معلومات الإعلان
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // زر تعديل الإعلان
                    IconButton(
                      onPressed: () => _editAd(ad),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'تعديل الإعلان',
                    ),
                    // زر حذف الإعلان
                    IconButton(
                      onPressed: () => _deleteAd(ad),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'حذف الإعلان',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ad.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تم الإضافة: ${ad.createdAt?.toString().split(' ')[0] ?? 'غير محدد'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ad.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ad.isActive ? 'نشط' : 'غير نشط',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _editAd(ad),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'تعديل الإعلان',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteAd(ad),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'حذف الإعلان',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('إعلاناتي', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/provider-home',
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث',
            onPressed: () => _loadAds(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.pushNamed(context, '/provider-notifications');
            },
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
                '/provider-home',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('قيد الانتظار'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-pending',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('خدماتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-services',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('حجوزاتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-bookings',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('إعلاناتي'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ads.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد إعلانات مضافة حالياً',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اضغط على زر + لإضافة إعلان جديد',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAds,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _ads.length,
                itemBuilder: (context, index) {
                  final ad = _ads[index];
                  return _buildAdCard(ad);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddAdPage()),
          );
          // إذا تم إضافة إعلان جديد، إعادة تحميل القائمة
          if (result == true) {
            _loadAds();
          }
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'إضافة إعلان',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-home',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-pending',
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-services',
                (route) => false,
              );
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-bookings',
                (route) => false,
              );
              break;
            case 4:
              // أنت بالفعل هنا
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
  );
}
