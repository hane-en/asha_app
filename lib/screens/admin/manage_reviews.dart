import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';

class ManageReviews extends StatefulWidget {
  const ManageReviews({super.key});

  @override
  State<ManageReviews> createState() => _ManageReviewsState();
}

class _ManageReviewsState extends State<ManageReviews> {
  List<Map<String, dynamic>> categories = [];
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    setState(() => isLoading = true);
    try {
      final result = await AdminService.getAllReviewsDetailed();
      if (result['success'] == true) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(result['data'] ?? []);
          stats = result['stats'] ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          categories = [];
          stats = {};
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطأ في تحميل التعليقات: ${result['message'] ?? 'خطأ غير معروف'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        categories = [];
        stats = {};
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل التعليقات: $e')));
      }
    }
  }

  Future<void> deleteReview(
    int reviewId,
    String userName,
    String serviceTitle,
  ) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف التعليق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد حذف تعليق المستخدم "$userName"؟'),
            const SizedBox(height: 8),
            Text('الخدمة: $serviceTitle'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ سيتم إشعار المستخدم ومزود الخدمة بحذف التعليق',
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
        final result = await AdminService.deleteReviewWithNotification(
          reviewId: reviewId,
          reason: reasonController.text.trim().isEmpty
              ? 'تم حذف التعليق من قبل المدير'
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
          loadReviews(); // إعادة تحميل التعليقات
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

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات التعليقات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'إجمالي التعليقات',
                      '${stats['total_reviews'] ?? 0}',
                      Icons.comment,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'الخدمات',
                      '${stats['total_services'] ?? 0}',
                      Icons.work,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'الفئات',
                      '${stats['total_categories'] ?? 0}',
                      Icons.category,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'المزودين',
                      '${stats['total_providers'] ?? 0}',
                      Icons.person,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'المستخدمين',
                      '${stats['total_users'] ?? 0}',
                      Icons.people,
                      Colors.teal,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'متوسط التقييم',
                      '${(stats['average_rating'] ?? 0.0).toStringAsFixed(1)}',
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _parseColor(category['category_color'] ?? '#9C27B0'),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.category, color: Colors.white),
        ),
        title: Text(
          category['category_name'] ?? 'فئة غير محددة',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${category['services']?.length ?? 0} خدمة'),
        children: [
          ...(category['services'] as List<dynamic>).map(
            (service) => _buildServiceCard(service),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey[50],
      child: ExpansionTile(
        leading: const Icon(Icons.work, color: Colors.blue),
        title: Text(
          service['service_title'] ?? 'خدمة غير محددة',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المزود: ${service['provider_name'] ?? 'غير محدد'}'),
            Row(
              children: [
                Text(
                  'التقييم: ${service['service_rating']?.toStringAsFixed(1) ?? '0.0'}',
                ),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text('(${service['service_reviews_count'] ?? 0} تعليق)'),
              ],
            ),
          ],
        ),
        children: [
          if ((service['reviews'] as List<dynamic>).isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'لا توجد تعليقات لهذه الخدمة',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...(service['reviews'] as List<dynamic>).map(
              (review) => _buildReviewCard(review, service['service_title']),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, String serviceTitle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Text(
            (review['user_name'] ?? 'م').substring(0, 1),
            style: const TextStyle(color: Colors.purple),
          ),
        ),
        title: Text(
          review['review_comment'] ?? 'لا يوجد تعليق',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text('بواسطة: ${review['user_name'] ?? 'غير محدد'}'),
                const Spacer(),
                Row(
                  children: [
                    Text('${review['review_rating'] ?? 0}'),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ),
              ],
            ),
            Text('التاريخ: ${_formatDate(review['review_date'])}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => deleteReview(
            review['review_id'],
            review['user_name'] ?? 'غير محدد',
            serviceTitle,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.purple;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التعليقات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadReviews),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCard(),
                Expanded(
                  child: categories.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد تعليقات',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) =>
                              _buildCategoryCard(categories[index]),
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
        currentIndex: 0,
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
    );
  }
}
