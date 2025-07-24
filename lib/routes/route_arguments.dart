import 'package:flutter/material.dart';

/// Route argument types for better type safety
/// This file defines the structure of arguments passed to routes

/// Arguments for service details route
class ServiceDetailsArguments {
  final int serviceId;
  final String? serviceName;
  final int? providerId;

  const ServiceDetailsArguments({
    required this.serviceId,
    this.serviceName,
    this.providerId,
  });
}

/// Arguments for booking status route
class BookingStatusArguments {
  final int userId;
  final int? bookingId;
  final String? status;

  const BookingStatusArguments({
    required this.userId,
    this.bookingId,
    this.status,
  });
}

/// Arguments for favorites route
class FavoritesArguments {
  final int userId;
  final String? category;

  const FavoritesArguments({required this.userId, this.category});
}

/// Arguments for send message route
class SendMessageArguments {
  final String receiverPhone;
  final String? receiverName;
  final String? initialMessage;

  const SendMessageArguments({
    required this.receiverPhone,
    this.receiverName,
    this.initialMessage,
  });
}

/// Arguments for edit service route
class EditServiceArguments {
  final int serviceId;
  final Map<String, dynamic>? serviceData;

  const EditServiceArguments({required this.serviceId, this.serviceData});
}

/// Arguments for user profile route
class UserProfileArguments {
  final int userId;
  final bool isEditable;

  const UserProfileArguments({required this.userId, this.isEditable = false});
}

/// Arguments for provider profile route
class ProviderProfileArguments {
  final int providerId;
  final bool isEditable;

  const ProviderProfileArguments({
    required this.providerId,
    this.isEditable = false,
  });
}

/// Arguments for service booking route
class ServiceBookingArguments {
  final int serviceId;
  final int providerId;
  final DateTime? preferredDate;
  final int? guestCount;

  const ServiceBookingArguments({
    required this.serviceId,
    required this.providerId,
    this.preferredDate,
    this.guestCount,
  });
}

/// Arguments for error route
class ErrorArguments {
  final String message;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorArguments({required this.message, this.title, this.onRetry});
}

/// Arguments for search route
class SearchArguments {
  final String? query;
  final String? category;
  final String? location;
  final Map<String, dynamic>? filters;

  const SearchArguments({
    this.query,
    this.category,
    this.location,
    this.filters,
  });
}
 