import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ad_model.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';
import '../config/config.dart';

class AdsCarouselWidget extends StatefulWidget {
  final List<AdModel> ads;
  
  const AdsCarouselWidget({
    super.key,
    required this.ads,
  });

  @override
  State<AdsCarouselWidget> createState() => _AdsCarouselWidgetState();
}

class _AdsCarouselWidgetState extends State<AdsCarouselWidget> {
  ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;
  double _maxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }



  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (_scrollController.hasClients && widget.ads.isNotEmpty) {
        _maxScrollExtent = _scrollController.position.maxScrollExtent;
        
        if (_scrollPosition >= _maxScrollExtent) {
          // العودة إلى البداية
          _scrollPosition = 0.0;
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // التحرك للأمام
          _scrollPosition += 150.0; // سرعة متوسطة
          _scrollController.animateTo(
            _scrollPosition,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onAdTap(AdModel ad) {
    // إذا كان الإعلان يحتوي على رابط، انتقل إليه
    if (ad.link != null && ad.link!.isNotEmpty) {
      // يمكن إضافة منطق للانتقال إلى الرابط
      print('Navigate to: ${ad.link}');
    } else {
      // انتقل إلى صفحة مزود الخدمة إذا كان موجود
      if (ad.providerId != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.providerServices,
          arguments: {
            'provider_id': ad.providerId,
            'provider_name': ad.providerName ?? 'مزود الخدمة',
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120,
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
                  '${widget.ads.length} إعلان',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.ads.length,
              itemBuilder: (context, index) {
                final ad = widget.ads[index];
                return _buildAdCard(ad);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(AdModel ad) {
    return Container(
      width: 160, // عرض ثابت لكل إعلان
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 3,
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
                  height: 80,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (ad.providerName != null) ...[
                        Text(
                          'بواسطة: ${ad.providerName}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'انقر للتفاصيل',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
