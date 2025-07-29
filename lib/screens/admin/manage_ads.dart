import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class ManageAdsPage extends StatefulWidget {
  const ManageAdsPage({super.key});

  @override
  State<ManageAdsPage> createState() => _ManageAdsPageState();
}

class _ManageAdsPageState extends State<ManageAdsPage> {
  List<Map<String, dynamic>> ads = [];
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  Future<void> loadAds() async {
    setState(() => isLoading = true);
    try {
      final adsList = await AdminService.getAllAds();

      setState(() {
        ads = adsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        ads = [];
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الإعلانات: $e')));
      }
    }
  }

  Future<void> deleteAd(int adId, String adTitle, String providerName) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف الإعلان'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد حذف الإعلان "$adTitle"؟'),
            const SizedBox(height: 8),
            Text('المزود: $providerName'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ سيتم إشعار المزود بحذف الإعلان',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text('سبب الحذف (اختياري):'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'أدخل سبب الحذف...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await AdminService.deleteAdWithNotification(
          adId,
          reasonController.text.trim().isEmpty
              ? 'تم حذف الإعلان من قبل المدير'
              : reasonController.text.trim(),
        );

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${result['message']}'),
                backgroundColor: Colors.green,
              ),
            );
          }
          loadAds(); // إعادة تحميل الإعلانات
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${result['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة الإعلانات',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadAds,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // إحصائيات الإعلانات
                  if (stats != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'إجمالي الإعلانات',
                            stats!['total_ads']?.toString() ?? '0',
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'الإعلانات النشطة',
                            stats!['active_ads']?.toString() ?? '0',
                            Colors.green,
                          ),
                          _buildStatCard(
                            'الإعلانات غير النشطة',
                            stats!['inactive_ads']?.toString() ?? '0',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  // قائمة الإعلانات
                  Expanded(
                    child: ads.isEmpty
                        ? const Center(child: Text('لا توجد إعلانات'))
                        : ListView.builder(
                            itemCount: ads.length,
                            itemBuilder: (context, index) {
                              final ad = ads[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: ad['image'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            'http://192.168.1.3/backend_php/${ad['image']}',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  title: Text(
                                    ad['title'] ?? 'بدون عنوان',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ad['description'] ?? 'بدون وصف'),
                                      const SizedBox(height: 4),
                                      Text(
                                        'المزود: ${ad['provider_name'] ?? 'غير محدد'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'الحالة: ${ad['is_active'] == 1 ? 'نشط' : 'غير نشط'}',
                                        style: TextStyle(
                                          color: ad['is_active'] == 1
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => deleteAd(
                                      ad['id'],
                                      ad['title'] ?? 'بدون عنوان',
                                      ad['provider_name'] ?? 'غير محدد',
                                    ),
                                    tooltip: 'حذف الإعلان',
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomePage()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
