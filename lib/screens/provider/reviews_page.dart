import 'package:flutter/material.dart';
import '../../services/provider_service.dart';
import '../../models/service_model.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Map<String, dynamic>> _services = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isLoading = true);
      _currentPage = 1;
    }

    try {
      final response = await ProviderService.getProviderReviewsWithServices(
        page: _currentPage,
        limit: _perPage,
      );

      if (response['success'] == true) {
        setState(() {
          if (refresh) {
            _services = List<Map<String, dynamic>>.from(response['data']);
          } else {
            _services.addAll(List<Map<String, dynamic>>.from(response['data']));
          }
          _stats = response['stats'];
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
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التعليقات والتقييمات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadReviews(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات
          if (_stats != null) _buildStatsCard(),

          // قائمة الخدمات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد خدمات أو تعليقات',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return _buildServiceCard(service);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات التعليقات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'الخدمات',
                  _stats!['total_services'],
                  Colors.blue,
                ),
                _buildStatItem(
                  'التعليقات',
                  _stats!['total_reviews'],
                  Colors.green,
                ),
                _buildStatItem(
                  'المقييمون',
                  _stats!['unique_reviewers'],
                  Colors.orange,
                ),
                _buildStatItem(
                  'متوسط التقييم',
                  _stats!['average_rating'].toString(),
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final reviews = List<Map<String, dynamic>>.from(service['reviews'] ?? []);
    final hasReviews = reviews.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          service['title'] ?? 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الفئة: ${service['category_name'] ?? 'غير محدد'}'),
            Text('السعر: ${service['price']} ريال'),
            if (service['rating'] != null && service['rating'] > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < (service['rating'] as double).floor()
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${service['rating']} (${service['total_ratings']} تقييم)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasReviews ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hasReviews ? '${reviews.length} تعليق' : 'لا توجد تعليقات',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          if (hasReviews) ...[
            const Divider(),
            ...reviews.map((review) => _buildReviewCard(review)).toList(),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا توجد تعليقات لهذه الخدمة بعد',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
