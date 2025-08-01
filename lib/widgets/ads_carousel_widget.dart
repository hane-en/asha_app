import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/unified_data_service.dart';
import '../models/ad_model.dart';
import '../utils/image_utils.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        _maxScrollExtent = _scrollController.position.maxScrollExtent;
        if (_scrollPosition >= _maxScrollExtent) {
          _scrollPosition = 0.0;
        } else {
          _scrollPosition += 160.0;
        }
        _scrollController.animateTo(
          _scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onAdTap(AdModel ad) {
    // Handle ad tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('إعلان: ${ad.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
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

    return Column(
      children: [
        Container(
          height: 120,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.ads.length,
            itemBuilder: (context, index) {
              return _buildAdCard(widget.ads[index]);
            },
          ),
        ),
      ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الإعلان
              Expanded(
                flex: 2,
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
