import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/unified_data_service.dart';
import '../models/ad_model.dart';
import '../utils/image_utils.dart';

class AdsCarouselWidget extends StatefulWidget {
  const AdsCarouselWidget({super.key});

  @override
  State<AdsCarouselWidget> createState() => _AdsCarouselWidgetState();
}

class _AdsCarouselWidgetState extends State<AdsCarouselWidget>
    with TickerProviderStateMixin {
  List<AdModel> _ads = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _loadAds();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAds() async {
    try {
      final result = await UnifiedDataService.getActiveAds();

      if (result['success'] == true) {
        final adsData = result['data'] as List<dynamic>;
        if (adsData.isNotEmpty) {
          final adsList = adsData
              .map((item) {
                try {
                  return AdModel.fromJson(item);
                } catch (e) {
                  print('Error creating ad from item $item: $e');
                  return null;
                }
              })
              .where((ad) => ad != null)
              .cast<AdModel>()
              .toList();

          setState(() {
            _ads = adsList;
          });
        } else {
          print('No ads data found, showing empty state');
          setState(() {
            _ads = [];
          });
        }
      } else {
        print('Ads API failed: ${result['message']}, showing empty state');
        setState(() {
          _ads = [];
        });
      }
    } catch (e) {
      print('Error loading ads: $e, showing empty state');
      setState(() {
        _ads = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AdsCarouselWidget build - ads count: ${_ads.length}'); // Debug info

    if (_ads.isEmpty) {
      print(
        'AdsCarouselWidget: No ads available, showing empty state',
      ); // Debug info
      return Container(
        height: 120,
        width: double.infinity,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'لا توجد إعلانات متاحة',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    print('AdsCarouselWidget: Showing ${_ads.length} ads'); // Debug info
    return Column(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          child: Stack(
            children: [
              // البطاقات الأفقية
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _ads.length,
                itemBuilder: (context, index) {
                  final ad = _ads[index];
                  print(
                    'AdsCarouselWidget: Building ad $index: ${ad.title}',
                  ); // Debug info
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildAdCard(ad),
                  );
                },
              ),
              // أزرار التنقل
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: () {
                        // التنقل للخلف
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        // التنقل للأمام
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // مؤشرات التنقل
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _ads.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == 0
                    ? Colors.purple
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdImage(String imageUrl, AdModel ad) {
    // التحقق من نوع الصورة
    if (imageUrl.startsWith('assets/')) {
      // صورة محلية
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('AdsCarouselWidget: Error loading local image: $error');
          return _buildPlaceholderImage();
        },
      );
    } else if (imageUrl.startsWith('http')) {
      // صورة من الإنترنت
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('AdsCarouselWidget: Error loading network image: $error');
          return _buildPlaceholderImage();
        },
      );
    } else {
      // صورة افتراضية
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return ImageUtils.createPlaceholderImage(
      text: 'صورة غير متاحة',
      backgroundColor: Colors.grey[300]!,
      textColor: Colors.grey[600]!,
    );
  }

  Widget _buildAdCard(AdModel ad) {
    return GestureDetector(
      onTap: () {
        // التنقل إلى تفاصيل الإعلان
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('إعلان: ${ad.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.9),
              Colors.purple.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // عنوان الإعلان
              Text(
                ad.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // وصف الإعلان
              Expanded(
                child: Text(
                  ad.description,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // اسم المزود
              Text(
                ad.providerName ?? 'مزود غير محدد',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
