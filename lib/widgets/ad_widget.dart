import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../config/config.dart';

class AdWidget extends StatelessWidget {

  const AdWidget({super.key, required this.ad, this.onTap});
  final AdModel ad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!ad.isValid) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    ad.image.isNotEmpty ? ad.image : Config.defaultImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                  ),
                ),
                // Priority badge
                if (ad.priority > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مميز',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Link indicator
                if (ad.hasLink)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (ad.description.isNotEmpty) ...[
                    Text(
                      ad.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Date range
                  if (ad.startDate != null || ad.endDate != null) ...[
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getDateRangeText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    var text = '';

    if (ad.startDate != null && ad.endDate != null) {
      text = 'من ${_formatDate(ad.startDate!)} إلى ${_formatDate(ad.endDate!)}';
    } else if (ad.startDate != null) {
      if (now.isBefore(ad.startDate!)) {
        text = 'يبدأ في ${_formatDate(ad.startDate!)}';
      } else {
        text = 'بدأ في ${_formatDate(ad.startDate!)}';
      }
    } else if (ad.endDate != null) {
      if (now.isAfter(ad.endDate!)) {
        text = 'انتهى في ${_formatDate(ad.endDate!)}';
      } else {
        text = 'ينتهي في ${_formatDate(ad.endDate!)}';
      }
    }

    return text;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
