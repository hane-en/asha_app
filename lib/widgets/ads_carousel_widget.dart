import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ad_model.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';
import '../config/config.dart';

class AdsCarouselWidget extends StatefulWidget {
  const AdsCarouselWidget({super.key});

  @override
  State<AdsCarouselWidget> createState() => _AdsCarouselWidgetState();
}

class _AdsCarouselWidgetState extends State<AdsCarouselWidget> {
  List<AdModel> _ads = [];
  bool _isLoading = true;
  PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAds() async {
    try {
      final ads = await ApiService.getActiveAds();
      setState(() {
        _ads = ads;
        _isLoading = false;
      });

      // بدء الحركة التلقائية إذا كان هناك إعلانات
      if (_ads.isNotEmpty) {
        _startAutoScroll();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading ads: $e');
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_ads.isNotEmpty) {
        _currentPage = (_currentPage + 1) % _ads.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onAdTap(AdModel ad) {
    // إذا كان الإعلان يحتوي على رابط، انتقل إليه
    if (ad.hasLink) {
      // يمكن إضافة منطق للانتقال إلى الرابط
      print('Navigate to: ${ad.link}');
    } else {
      // انتقل إلى صفحة مزود الخدمة أو صفحة الخدمات
      if (ad.providerId != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.serviceSearch,
          arguments: {'provider_id': ad.providerId},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.purple, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'إعلانات مميزة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_ads.length} إعلان',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _ads.length,
                  itemBuilder: (context, index) {
                    final ad = _ads[index];
                    return _buildAdCard(ad);
                  },
                ),
                // مؤشرات الصفحات
                if (_ads.length > 1)
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _ads.length,
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.purple
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(AdModel ad) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _onAdTap(ad),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الإعلان
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: ad.image.isNotEmpty
                      ? Image.network(
                          '${Config.apiBaseUrl}/backend_php/${ad.image}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                ),
              ),
              // معلومات الإعلان
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ad.providerName != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        'بواسطة: ${ad.providerName}',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 10,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'انقر للتفاصيل',
                          style: TextStyle(
                            fontSize: 8,
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
        ),
      ),
    );
  }
}
