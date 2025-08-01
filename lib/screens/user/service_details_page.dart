import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/service_with_offers_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../routes/route_names.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'booking_screen.dart';

class ServiceDetailsPage extends StatefulWidget {
  final int serviceId;
  final String? serviceTitle;

  const ServiceDetailsPage({
    super.key,
    required this.serviceId,
    this.serviceTitle,
  });

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  bool _isLoading = true;
  bool _isLoadingReviews = false;
  bool _isAddingToFavorites = false;
  bool _isSubmittingReview = false;

  Map<String, dynamic>? _serviceDetails;
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _userBookingStatus;
  bool _isFavorite = false;
  bool _canReview = false;
  bool _canBook = true;

  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 0.0;

  int? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadServiceDetails();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getInt('user_id');
        _userName = prefs.getString('user_name');
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadServiceDetails() async {
    setState(() => _isLoading = true);

    try {
      final params = {'service_id': widget.serviceId};
      if (_userId != null) {
        params['user_id'] = _userId!;
      }

      final result = await ApiService.getServiceDetails(params);

      if (result['success'] && result['data'] != null) {
        setState(() {
          _serviceDetails = result['data'];
          _reviews = List<Map<String, dynamic>>.from(
            _serviceDetails!['reviews'] ?? [],
          );
          _userBookingStatus = _serviceDetails!['user_booking_status'];
          _isFavorite = _serviceDetails!['is_favorite'] ?? false;
        });

        _checkUserPermissions();
      } else {
        _showErrorSnackBar(result['message'] ?? 'فشل في تحميل تفاصيل الخدمة');
      }
    } catch (e) {
      print('Error loading service details: $e');
      _showErrorSnackBar('خطأ في تحميل تفاصيل الخدمة');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkUserPermissions() async {
    if (_userId == null) return;

    try {
      final params = {'user_id': _userId, 'service_id': widget.serviceId};

      final result = await ApiService.checkUserBookingStatus(params);

      if (result['success'] && result['data'] != null) {
        setState(() {
          _canReview = result['data']['can_review'] ?? false;
          _canBook = result['data']['can_book'] ?? true;
        });
      }
    } catch (e) {
      print('Error checking user permissions: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() => _isAddingToFavorites = true);

    try {
      final result = await ApiService.toggleFavorite(
        userId: _userId!,
        serviceId: widget.serviceId,
      );

      if (result['success']) {
        setState(() => _isFavorite = !_isFavorite);
        _showSuccessSnackBar(
          _isFavorite ? 'تمت الإضافة إلى المفضلة' : 'تم الحذف من المفضلة',
        );
      } else {
        _showErrorSnackBar(result['message'] ?? 'فشل في تحديث المفضلة');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      _showErrorSnackBar('خطأ في تحديث المفضلة');
    } finally {
      setState(() => _isAddingToFavorites = false);
    }
  }

  Future<void> _bookService() async {
    if (_userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    if (!_canBook) {
      _showErrorSnackBar('لا يمكن الحجز في الوقت الحالي');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          serviceId: widget.serviceId,
          serviceData: _serviceDetails,
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    if (_selectedRating == 0.0) {
      _showErrorSnackBar('يرجى اختيار تقييم');
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى كتابة تعليق');
      return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final reviewData = {
        'user_id': _userId,
        'service_id': widget.serviceId,
        'rating': _selectedRating.toInt(),
        'comment': _reviewController.text.trim(),
      };

      final result = await ApiService.createReview(reviewData);

      if (result['success']) {
        _showSuccessSnackBar('تم إرسال التقييم بنجاح');
        _reviewController.clear();
        _selectedRating = 0.0;
        setState(() => _canReview = false);
        _loadServiceDetails(); // إعادة تحميل البيانات لتحديث التقييمات
      } else {
        _showErrorSnackBar(result['message'] ?? 'فشل في إرسال التقييم');
      }
    } catch (e) {
      print('Error submitting review: $e');
      _showErrorSnackBar('خطأ في إرسال التقييم');
    } finally {
      setState(() => _isSubmittingReview = false);
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text('يجب تسجيل الدخول للقيام بهذا الإجراء'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _serviceDetails?['title'] ?? widget.serviceTitle ?? 'تفاصيل الخدمة',
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _serviceDetails == null
          ? const Center(child: Text('الخدمة غير موجودة'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة الخدمة
                  if (_serviceDetails!['images'] != null &&
                      (_serviceDetails!['images'] as List).isNotEmpty)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _serviceDetails!['images'][0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // عنوان الخدمة
                  Text(
                    _serviceDetails!['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // السعر والتقييم
                  Row(
                    children: [
                      Text(
                        '${_serviceDetails!['price']?.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_serviceDetails!['rating_avg']?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_serviceDetails!['rating_count'] ?? 0})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // معلومات المزود
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.purple,
                          child: Text(
                            (_serviceDetails!['provider_name'] ?? 'م')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _serviceDetails!['provider_name'] ??
                                    'مزود غير محدد',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _serviceDetails!['category_name'] ??
                                    'فئة غير محددة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // وصف الخدمة
                  const Text(
                    'الوصف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _serviceDetails!['description'] ?? 'لا يوجد وصف متاح',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // زر عرض المزودين
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.serviceProviders,
                          arguments: {
                            'service_id': widget.serviceId,
                            'service_name':
                                _serviceDetails!['name'] ?? 'الخدمة',
                          },
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('عرض المزودين'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر الحجز
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _canBook ? _bookService : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _canBook ? 'حجز الخدمة' : 'لا يمكن الحجز حالياً',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // التقييمات
                  Row(
                    children: [
                      const Text(
                        'التقييمات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_reviews.length} تقييم',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // إضافة تقييم (إذا كان مسموحاً)
                  if (_canReview) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
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

                          // النجوم
                          Row(
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRating = index + 1.0;
                                  });
                                },
                                child: Icon(
                                  index < _selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: _isSubmittingReview
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('إرسال التقييم'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // قائمة التقييمات
                  if (_reviews.isNotEmpty) ...[
                    ..._reviews
                        .map(
                          (review) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.purple,
                                      child: Text(
                                        (review['user_name'] ?? 'م')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review['user_name'] ?? 'مستخدم',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              ...List.generate(5, (index) {
                                                return Icon(
                                                  index < review['rating']
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                );
                                              }),
                                              const SizedBox(width: 8),
                                              Text(
                                                review['created_at'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (review['comment'] != null &&
                                    review['comment']
                                        .toString()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    review['comment'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ] else ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'لا توجد تقييمات بعد',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
