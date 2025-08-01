import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/service_model.dart';
import '../../services/unified_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/service_card.dart';
import '../../routes/route_names.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int serviceId;
  final String? serviceName;

  const ServiceDetailsScreen({
    Key? key,
    required this.serviceId,
    this.serviceName,
  }) : super(key: key);

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isLoading = true;
  bool _isAddingToFavorites = false;
  bool _isSubmittingReview = false;
  Map<String, dynamic>? _serviceData;
  int? _currentUserId;
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadServiceDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await UnifiedDataService.getServiceDetails(
        widget.serviceId,
        userId: _currentUserId,
      );

      if (response['success']) {
        setState(() {
          _serviceData = response['data'];
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response['message'] ?? 'فشل في تحميل تفاصيل الخدمة');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentUserId == null) {
      _showErrorSnackBar('يرجى تسجيل الدخول أولاً');
      return;
    }

    try {
      setState(() {
        _isAddingToFavorites = true;
      });

      final response = await UnifiedDataService.toggleFavorite(
        _currentUserId!,
        widget.serviceId,
      );

      if (response['success']) {
        _showSuccessSnackBar(response['message'] ?? 'تم تحديث المفضلة بنجاح');
        _loadServiceDetails(); // إعادة تحميل البيانات لتحديث حالة المفضلة
      } else {
        _showErrorSnackBar(response['message'] ?? 'فشل في تحديث المفضلة');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال: $e');
    } finally {
      setState(() {
        _isAddingToFavorites = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_currentUserId == null) {
      _showErrorSnackBar('يرجى تسجيل الدخول أولاً');
      return;
    }

    if (_selectedRating == 0) {
      _showErrorSnackBar('يرجى اختيار تقييم');
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى كتابة تعليق');
      return;
    }

    try {
      setState(() {
        _isSubmittingReview = true;
      });

      final response = await UnifiedDataService.createReview(
        userId: _currentUserId!,
        serviceId: widget.serviceId,
        rating: _selectedRating,
        comment: _reviewController.text.trim(),
      );

      if (response['success']) {
        _showSuccessSnackBar('تم إضافة التقييم بنجاح');
        _reviewController.clear();
        _selectedRating = 0;
        _loadServiceDetails(); // إعادة تحميل البيانات لتحديث التقييمات
      } else {
        _showErrorSnackBar(response['message'] ?? 'فشل في إضافة التقييم');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال: $e');
    } finally {
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceName ?? 'تفاصيل الخدمة',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _serviceData == null
          ? const Center(child: Text('لا توجد بيانات'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة الخدمة
                  if (_serviceData!['service']['image'] != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(
                            _serviceData!['service']['image'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // معلومات الخدمة
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _serviceData!['service']['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'السعر: ${_serviceData!['service']['price']} ريال',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _serviceData!['service']['description'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // معلومات المزود
                  if (_serviceData!['service']['provider_name'] != null)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'معلومات المزود',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الاسم: ${_serviceData!['service']['provider_name']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_serviceData!['service']['provider_phone'] !=
                                null)
                              Text(
                                'الهاتف: ${_serviceData!['service']['provider_phone']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // إحصائيات التقييم
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'التقييم العام',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_serviceData!['rating_stats']['avg_rating']} / 5',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'عدد التقييمات: ${_serviceData!['rating_stats']['total_reviews']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentUserId != null
                              ? _toggleFavorite
                              : null,
                          icon: Icon(
                            _serviceData!['is_favorite']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _serviceData!['is_favorite']
                                ? Colors.red
                                : null,
                          ),
                          label: Text(
                            _serviceData!['is_favorite']
                                ? 'إزالة من المفضلة'
                                : 'إضافة للمفضلة',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // التنقل إلى صفحة الحجز
                            Navigator.pushNamed(
                              context,
                              RouteNames.booking,
                              arguments: {
                                'id': widget.serviceId,
                                'title': _serviceData!['service']['name'],
                                'price': _serviceData!['service']['price'],
                                'provider_name':
                                    _serviceData!['service']['provider_name'],
                                'description':
                                    _serviceData!['service']['description'] ??
                                    '',
                              },
                            );
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('حجز الخدمة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // قسم التقييمات
                  const Text(
                    'التقييمات والتعليقات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // إضافة تقييم جديد
                  if (_serviceData!['can_review'] &&
                      !_serviceData!['user_has_reviewed'])
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'أضف تقييمك',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // اختيار التقييم
                            Row(
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRating = index + 1;
                                    });
                                  },
                                  child: Icon(
                                    index < _selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                    size: 30,
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // حقل التعليق
                            TextField(
                              controller: _reviewController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'اكتب تعليقك هنا...',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmittingReview
                                    ? null
                                    : _submitReview,
                                child: _isSubmittingReview
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('إرسال التقييم'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // قائمة التقييمات
                  if (_serviceData!['reviews'].isNotEmpty)
                    ...(_serviceData!['reviews'] as List).map((review) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        review['user_image'] != null
                                        ? NetworkImage(review['user_image'])
                                        : null,
                                    child: review['user_image'] == null
                                        ? Text(review['user_name'][0])
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['user_name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review['rating']
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.orange,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    review['created_at'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review['comment']),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  if (_serviceData!['reviews'].isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'لا توجد تقييمات بعد',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
