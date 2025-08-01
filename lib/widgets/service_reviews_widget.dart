import 'package:flutter/material.dart';
import '../services/reviews_service.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class ServiceReviewsWidget extends StatefulWidget {
  final int serviceId;
  final String serviceTitle;

  const ServiceReviewsWidget({
    Key? key,
    required this.serviceId,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  State<ServiceReviewsWidget> createState() => _ServiceReviewsWidgetState();
}

class _ServiceReviewsWidgetState extends State<ServiceReviewsWidget> {
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic>? stats;
  Map<String, dynamic>? userEligibility;
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMorePages = true;

  // متغيرات إضافة تقييم جديد
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isAddingReview = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _checkUserEligibility();
  }

  Future<void> _loadReviews() async {
    if (isLoadingMore) return;

    setState(() {
      if (currentPage == 1) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
    });

    try {
      final response = await ReviewsService.getReviews(
        widget.serviceId,
        page: currentPage,
        limit: 10,
      );

      if (response['success']) {
        final data = response['data'];
        final newReviews = List<Map<String, dynamic>>.from(data['reviews']);
        
        setState(() {
          if (currentPage == 1) {
            reviews = newReviews;
            stats = data['stats'];
            userEligibility = data['user_eligibility'];
          } else {
            reviews.addAll(newReviews);
          }
          
          hasMorePages = data['pagination']['current_page'] < data['pagination']['total_pages'];
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        _showErrorSnackBar(response['error'] ?? 'حدث خطأ في تحميل التقييمات');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      _showErrorSnackBar('حدث خطأ في الاتصال');
    }
  }

  Future<void> _checkUserEligibility() async {
    try {
      final response = await ReviewsService.checkEligibility(widget.serviceId);
      if (response['success']) {
        setState(() {
          userEligibility = response['data'];
        });
      }
    } catch (e) {
      // تجاهل الأخطاء في التحقق من الأهلية
    }
  }

  Future<void> _addReview() async {
    if (_selectedRating == 0) {
      _showErrorSnackBar('يرجى اختيار تقييم');
      return;
    }

    setState(() {
      _isAddingReview = true;
    });

    try {
      final response = await ReviewsService.addReview(
        serviceId: widget.serviceId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      if (response['success']) {
        _showSuccessSnackBar('تم إضافة التقييم بنجاح');
        _commentController.clear();
        _selectedRating = 0;
        
        // إعادة تحميل التقييمات
        setState(() {
          currentPage = 1;
          hasMorePages = true;
        });
        await _loadReviews();
        await _checkUserEligibility();
      } else {
        _showErrorSnackBar(response['error'] ?? 'حدث خطأ في إضافة التقييم');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في الاتصال');
    } finally {
      setState(() {
        _isAddingReview = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildRatingStars(int rating, {double size = 20, bool isSelectable = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isSelectable ? () {
            setState(() {
              _selectedRating = index + 1;
            });
          } : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    review['user_name']?[0]?.toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['user_name'] ?? 'مستخدم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ReviewsService.formatDate(review['created_at']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(review['rating']),
              ],
            ),
            if (review['comment']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                review['comment'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewSection() {
    if (userEligibility == null) {
      return const SizedBox.shrink();
    }

    if (!userEligibility!['can_review']) {
      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userEligibility!['reason'],
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أضف تقييمك',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('التقييم: '),
                _buildRatingStars(_selectedRating, isSelectable: true),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب تعليقك هنا (اختياري)...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAddingReview ? null : _addReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isAddingReview
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('نشر التقييم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'التقييمات والتعليقات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (stats != null) ...[
                const Spacer(),
                Text(
                  '${stats!['total_reviews']} تقييم',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),

        // إحصائيات التقييمات
        if (stats != null) ...[
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        stats!['average_rating'].toString(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      _buildRatingStars(stats!['average_rating'].round()),
                      Text(
                        ReviewsService.getRatingText(stats!['average_rating']),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, stats!['rating_distribution']['five_star'], stats!['total_reviews']),
                        _buildRatingBar(4, stats!['rating_distribution']['four_star'], stats!['total_reviews']),
                        _buildRatingBar(3, stats!['rating_distribution']['three_star'], stats!['total_reviews']),
                        _buildRatingBar(2, stats!['rating_distribution']['two_star'], stats!['total_reviews']),
                        _buildRatingBar(1, stats!['rating_distribution']['one_star'], stats!['total_reviews']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // قسم إضافة تقييم
        _buildAddReviewSection(),

        // قائمة التقييمات
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'لا توجد تقييمات بعد',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: [
              ...reviews.map((review) => _buildReviewCard(review)),
              if (hasMorePages)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: isLoadingMore ? null : () {
                        setState(() {
                          currentPage++;
                        });
                        _loadReviews();
                      },
                      child: isLoadingMore
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('تحميل المزيد'),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Row(
              children: [
                Text('$stars'),
                const Icon(Icons.star, size: 16, color: Colors.amber),
              ],
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
} 