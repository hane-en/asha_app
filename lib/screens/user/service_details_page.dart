import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class ServiceDetailsPage extends StatefulWidget {
  const ServiceDetailsPage({
    super.key,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceImage,
  });
  final int userId;
  final int serviceId;
  final String serviceTitle;
  final String serviceImage;

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  bool isFavorite = false;
  bool isLoading = true;
  Map<String, dynamic>? _serviceDetails;
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _ratingStats;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    try {
      // جلب تفاصيل الخدمة والتعليقات
      final response = await ApiService.getServiceDetails(widget.serviceId);

      if (response['success'] == true) {
        setState(() {
          _serviceDetails = response['data']['service'];
          _reviews = List<Map<String, dynamic>>.from(
            response['data']['reviews'],
          );
          _ratingStats = response['data']['rating_stats'];
        });
      }

      // التحقق من حالة المفضلة
      final favorites = await ApiService.getFavorites(widget.userId);
      setState(() {
        isFavorite = favorites.any((s) => s['id'] == widget.serviceId);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل تفاصيل الخدمة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> toggleFavorite() async {
    bool success;
    if (isFavorite) {
      success = await ApiService.removeFavorite(
        widget.userId,
        widget.serviceId,
      );
    } else {
      success = await ApiService.addToFavorites(
        widget.userId,
        widget.serviceId,
      );
    }

    if (success) {
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? '✅ أُضيفت إلى المفضلة' : '🗑️ تم الحذف من المفضلة',
          ),
        ),
      );
    }
  }

  void bookService() {
    // يمكنك ربط الحجز بقاعدة بيانات لاحقًا
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ تم إرسال طلب الحجز')));
  }

  Future<void> _onBookPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      Navigator.pushNamed(context, AppRoutes.login);
    } else {
      // أكمل عملية الحجز هنا
      bookService();
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceTitle),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة الخدمة
                  Image.network(
                    widget.serviceImage,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عنوان الخدمة
                        Text(
                          widget.serviceTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // تفاصيل الخدمة
                        if (_serviceDetails != null) ...[
                          Text(
                            'المزود: ${_serviceDetails!['provider_name'] ?? 'غير محدد'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الفئة: ${_serviceDetails!['category_name'] ?? 'غير محدد'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'السعر: ${_serviceDetails!['price']} ريال',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // التقييمات
                        if (_ratingStats != null &&
                            _ratingStats!['total_reviews'] > 0) ...[
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index <
                                          (_ratingStats!['avg_rating']
                                                  as double)
                                              .floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 20,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_ratingStats!['avg_rating']} (${_ratingStats!['total_reviews']} تقييم)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // أزرار الإجراءات
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: toggleFavorite,
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isFavorite
                                      ? 'إزالة من المفضلة'
                                      : 'إضافة إلى المفضلة',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFavorite
                                      ? Colors.grey
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _onBookPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('احجز الآن'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // قسم التعليقات
                        if (_reviews.isNotEmpty) ...[
                          const Text(
                            'التعليقات والتقييمات',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._reviews
                              .map((review) => _buildReviewCard(review))
                              .toList(),
                        ] else ...[
                          const Text(
                            'لا توجد تعليقات لهذه الخدمة بعد',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    ),
  );

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.purple[100],
                child: Text(
                  (review['user_name'] as String).isNotEmpty
                      ? (review['user_name'] as String)[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user_name'] ?? 'مستخدم غير معروف',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < (review['rating'] as int)
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review['rating']}/5',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review['created_at']),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (review['comment'] != null &&
              (review['comment'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review['comment'], style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return dateString;
    }
  }
}
