import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'booking_page.dart';
import '../../models/service_model.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.service});
  final Map<String, dynamic> service;

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
      try {
        final favorites = await ApiService.getFavorites(userId);
        setState(() {
          _isFavorite = favorites.any(
            (fav) => fav['id'] == widget.service['id'],
          );
        });
      } catch (e) {
        print('Error checking favorite status: $e');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول
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
      final serviceModel = ServiceModel(
        id: widget.service['id'],
        name: widget.service['name'] ?? '',
        description: widget.service['description'] ?? '',
        price: (widget.service['price'] ?? 0).toDouble(),
        category: widget.service['category'] ?? '',
        providerId: widget.service['provider_id'] ?? 0,
        providerName: widget.service['provider_name'] ?? '',
        providerPhone: widget.service['provider_phone'],
        image: widget.service['image'],
        rating: (widget.service['rating'] ?? 0).toDouble(),
        reviewCount: widget.service['review_count'] ?? 0,
        latitude: widget.service['latitude']?.toDouble(),
        longitude: widget.service['longitude']?.toDouble(),
        isActive: widget.service['is_active'] ?? true,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingPage(service: serviceModel)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user_home',
          (route) => false,
        );
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.service['name']),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الخدمة
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.service['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.purple[100],
                          child: const Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.purple,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // عنوان الخدمة
                Text(
                  widget.service['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),

                // مقدم الخدمة
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.service['provider_name'] ?? 'غير محدد',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // السعر
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.service['price'] ?? 0} ريال',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // الوصف
                const Text(
                  'الوصف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.service['description'] ?? 'لا يوجد وصف متاح',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),

                // أزرار الحجز والمفضلة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _toggleFavorite,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                        label: Text(
                          _isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFavorite
                              ? Colors.red
                              : Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onBookPressed,
                        child: const Text('احجز الآن'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
}
