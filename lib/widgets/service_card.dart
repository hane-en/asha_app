import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../config/config.dart';

class ServiceCard extends StatelessWidget {

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.onCall,
    this.showProviderInfo = true,
    this.showRating = true,
    this.showPrice = true,
    this.showDiscount = true,
    this.showStatusBadges = true,
  });
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onCall;
  final bool showProviderInfo;
  final bool showRating;
  final bool showPrice;
  final bool showDiscount;
  final bool showStatusBadges;

  @override
  Widget build(BuildContext context) => Card(
      elevation: Config.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Config.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Config.defaultBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            _buildImageSection(),

            // Content section
            Padding(
              padding: const EdgeInsets.all(Config.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status badges
                  _buildTitleSection(),

                  const SizedBox(height: 8),

                  // Description
                  _buildDescriptionSection(),

                  const SizedBox(height: 8),

                  // Provider info
                  if (showProviderInfo) _buildProviderSection(),

                  const SizedBox(height: 8),

                  // Location info
                  if (service.hasLocation || service.hasCoordinates)
                    _buildLocationSection(),

                  const SizedBox(height: 8),

                  // Rating and price
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildImageSection() => Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Config.defaultBorderRadius),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: service.hasImages
                ? Image.network(
                    service.mainImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),

        // Status badges
        if (showStatusBadges) _buildStatusBadges(),

        // Action buttons
        _buildActionButtons(),
      ],
    );

  Widget _buildStatusBadges() => Positioned(
      top: 8,
      right: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (service.isFeatured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'مميز',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (service.isVerified) ...[
            if (service.isFeatured) const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'موثق',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildActionButtons() => Positioned(
      top: 8,
      left: 8,
      child: Row(
        children: [
          if (onFavorite != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onFavorite,
                icon: const Icon(Icons.favorite_border),
                iconSize: 20,
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          if (onShare != null) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                iconSize: 20,
                color: Colors.purple,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildTitleSection() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            service.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showDiscount && service.hasDiscount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              service.discountText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );

  Widget _buildDescriptionSection() => Text(
      service.description,
      style: const TextStyle(fontSize: 14, color: Colors.grey),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

  Widget _buildProviderSection() => Row(
      children: [
        if (service.providerImage != null && service.providerImage!.isNotEmpty)
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(service.providerImage!),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle error silently
            },
          )
        else
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple[100],
            child: Text(
              service.providerName.isNotEmpty
                  ? service.providerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.purple,
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
                service.providerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onCall != null && service.providerPhone != null)
          IconButton(
            onPressed: onCall,
            icon: const Icon(Icons.phone, color: Colors.green),
            iconSize: 20,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );

  Widget _buildLocationSection() => Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: service.hasCoordinates ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.locationText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (service.hasCoordinates && service.distance != null) ...[
                const SizedBox(height: 2),
                Text(
                  service.formattedDistance,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

  Widget _buildBottomSection() => Row(
      children: [
        // Rating
        if (showRating && service.hasReviews) ...[
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                service.formattedRating,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${service.reviewCount})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
        ],

        // Price
        if (showPrice)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (service.hasDiscount) ...[
                Text(
                  service.formattedOriginalPrice,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                service.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
      ],
    );
}
