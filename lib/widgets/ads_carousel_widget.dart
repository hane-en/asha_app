import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

class AdsCarouselWidget extends StatefulWidget {
  const AdsCarouselWidget({super.key});

  @override
  State<AdsCarouselWidget> createState() => _AdsCarouselWidgetState();
}

class _AdsCarouselWidgetState extends State<AdsCarouselWidget> {
  List<AdModel> _ads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final ads = await ApiService.getActiveAds();
      setState(() {
        _ads = ads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading ads: $e');
    }
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
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'إعلانات مميزة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_ads.length} إعلان',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _ads.length,
              itemBuilder: (context, index) {
                final ad = _ads[index];
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
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: ad.image.isNotEmpty
                      ? Image.network(
                          'http://192.168.1.3/backend_php/${ad.image}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
              ),
              // معلومات الإعلان
              Padding(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ad.providerName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'بواسطة: ${ad.providerName}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
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
                            fontSize: 10,
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
