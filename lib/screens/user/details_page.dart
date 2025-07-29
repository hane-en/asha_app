import 'package:flutter/material.dart';
import 'package:asha_application/models/service_model.dart';
import 'package:asha_application/services/api_service.dart';
import 'package:asha_application/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> service;

  const DetailsPage({Key? key, required this.service}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      // المستخدم مسجل دخول - فحص من API
      try {
        final favorites = await ApiService.getFavorites(userId);
        setState(() {
          _isFavorite = favorites.any((f) => f['id'] == widget.service['id']);
        });
      } catch (e) {
        print('Error checking favorite status: $e');
      }
    } else {
      // المستخدم غير مسجل دخول - فحص من التخزين المحلي
      final localFavorites = prefs.getStringList('local_favorites') ?? [];
      setState(() {
        _isFavorite = localFavorites.contains(widget.service['id'].toString());
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - استخدام API
        if (_isFavorite) {
          await ApiService.removeFavorite(userId, widget.service['id']);
        } else {
          await ApiService.addToFavorites(userId, widget.service['id']);
        }

        setState(() => _isFavorite = !_isFavorite);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة',
            ),
            backgroundColor: Colors.purple,
          ),
        );
      } else {
        // المستخدم غير مسجل دخول - حفظ في التخزين المحلي
        final localFavorites = prefs.getStringList('local_favorites') ?? [];
        final serviceId = widget.service['id'].toString();

        if (_isFavorite) {
          localFavorites.remove(serviceId);
        } else {
          localFavorites.add(serviceId);
        }

        await prefs.setStringList('local_favorites', localFavorites);
        setState(() => _isFavorite = !_isFavorite);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة',
            ),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onBookPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      // تحويل البيانات إلى Service
      final serviceModel = Service(
        id: widget.service['id'] ?? 0,
        providerId: widget.service['provider_id'] ?? 0,
        categoryId: widget.service['category_id'] ?? 0,
        title: widget.service['title'] ?? '',
        description: widget.service['description'] ?? '',
        price: (widget.service['price'] ?? 0.0).toDouble(),
        originalPrice: widget.service['original_price'] != null
            ? (widget.service['original_price'] as num).toDouble()
            : null,
        duration: widget.service['duration'] ?? 0,
        images: widget.service['images'] != null
            ? List<String>.from(widget.service['images'])
            : [],
        isActive: widget.service['is_active'] ?? true,
        isVerified: widget.service['is_verified'] ?? false,
        isFeatured: widget.service['is_featured'] ?? false,
        rating: (widget.service['rating'] ?? 0.0).toDouble(),
        totalRatings: widget.service['total_ratings'] ?? 0,
        bookingCount: widget.service['booking_count'] ?? 0,
        favoriteCount: widget.service['favorite_count'] ?? 0,
        specifications: widget.service['specifications'],
        tags: widget.service['tags'] != null
            ? List<String>.from(widget.service['tags'])
            : [],
        location: widget.service['location'] ?? '',
        latitude: widget.service['latitude'] != null
            ? (widget.service['latitude'] as num).toDouble()
            : null,
        longitude: widget.service['longitude'] != null
            ? (widget.service['longitude'] as num).toDouble()
            : null,
        address: widget.service['address'] ?? '',
        city: widget.service['city'] ?? '',
        maxGuests: widget.service['max_guests'],
        cancellationPolicy: widget.service['cancellation_policy'],
        depositRequired: widget.service['deposit_required'] ?? false,
        depositAmount: widget.service['deposit_amount'] != null
            ? (widget.service['deposit_amount'] as num).toDouble()
            : null,
        paymentTerms: widget.service['payment_terms'],
        availability: widget.service['availability'],
        createdAt: widget.service['created_at'] ?? '',
        updatedAt: widget.service['updated_at'] ?? '',
        categoryName: widget.service['category_name'],
        providerName: widget.service['provider_name'],
        providerRating: widget.service['provider_rating'] != null
            ? (widget.service['provider_rating'] as num).toDouble()
            : null,
      );

      Navigator.pushNamed(context, '/booking', arguments: serviceModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service['title'] ?? 'تفاصيل الخدمة'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الخدمة
            if (widget.service['images'] != null &&
                (widget.service['images'] as List).isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: (widget.service['images'] as List).length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      'http://127.0.0.1/asha_app_backend/uploads/${widget.service['images'][index]}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50),
                        );
                      },
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الخدمة
                  Text(
                    widget.service['title'] ?? 'عنوان الخدمة',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // وصف الخدمة
                  Text(
                    widget.service['description'] ?? 'وصف الخدمة',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // معلومات الخدمة
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        widget.service['city'] ?? 'المدينة',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        widget.service['category_name'] ?? 'الفئة',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        widget.service['provider_name'] ?? 'المزود',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // السعر
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'السعر',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${widget.service['price'] ?? 0} ريال',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _isLoading ? null : _toggleFavorite,
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _onBookPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('احجز الآن'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // المواصفات
                  if (widget.service['specifications'] != null &&
                      (widget.service['specifications'] as List)
                          .isNotEmpty) ...[
                    const Text(
                      'المواصفات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(widget.service['specifications'] as List).map((spec) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(spec.toString())),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // العلامات
                  if (widget.service['tags'] != null &&
                      (widget.service['tags'] as List).isNotEmpty) ...[
                    const Text(
                      'العلامات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.service['tags'] as List).map((tag) {
                        return Chip(
                          label: Text(tag.toString()),
                          backgroundColor: Colors.purple[100],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // شروط الدفع
                  if (widget.service['payment_terms'] != null &&
                      (widget.service['payment_terms'] as List).isNotEmpty) ...[
                    const Text(
                      'شروط الدفع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(widget.service['payment_terms'] as List).map((term) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.payment, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(child: Text(term.toString())),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // التوفر
                  if (widget.service['availability'] != null &&
                      (widget.service['availability'] as List).isNotEmpty) ...[
                    const Text(
                      'التوفر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(widget.service['availability'] as List).map((
                      availability,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(child: Text(availability.toString())),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
