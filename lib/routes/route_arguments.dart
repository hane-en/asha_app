import 'package:flutter/material.dart';

/// Route argument types for better type safety
/// This file defines the structure of arguments passed to routes

/// Arguments for service details route
class ServiceDetailsArguments {

  const ServiceDetailsArguments({
    required this.serviceId,
    this.serviceName,
    this.providerId,
  });
  final int serviceId;
  final String? serviceName;
  final int? providerId;
}

/// Arguments for booking status route
class BookingStatusArguments {

  const BookingStatusArguments({
    required this.userId,
    this.bookingId,
    this.status,
  });
  final int userId;
  final int? bookingId;
  final String? status;
}

/// Arguments for favorites route
class FavoritesArguments {

  const FavoritesArguments({required this.userId, this.category});
  final int userId;
  final String? category;
}

/// Arguments for send message route
class SendMessageArguments {

  const SendMessageArguments({
    required this.receiverPhone,
    this.receiverName,
    this.initialMessage,
  });
  final String receiverPhone;
  final String? receiverName;
  final String? initialMessage;
}

/// Arguments for edit service route
class EditServiceArguments {

  const EditServiceArguments({required this.serviceId, this.serviceData});
  final int serviceId;
  final Map<String, dynamic>? serviceData;
}

/// Arguments for user profile route
class UserProfileArguments {

  const UserProfileArguments({required this.userId, this.isEditable = false});
  final int userId;
  final bool isEditable;
}

/// Arguments for provider profile route
class ProviderProfileArguments {

  const ProviderProfileArguments({
    required this.providerId,
    this.isEditable = false,
  });
  final int providerId;
  final bool isEditable;
}

/// Arguments for service booking route
class ServiceBookingArguments {

  const ServiceBookingArguments({
    required this.serviceId,
    required this.providerId,
    this.preferredDate,
    this.guestCount,
  });
  final int serviceId;
  final int providerId;
  final DateTime? preferredDate;
  final int? guestCount;
}

/// Arguments for error route
class ErrorArguments {

  const ErrorArguments({required this.message, this.title, this.onRetry});
  final String message;
  final String? title;
  final VoidCallback? onRetry;
}

/// Arguments for search route
class SearchArguments {

  const SearchArguments({
    this.query,
    this.category,
    this.location,
    this.filters,
  });
  final String? query;
  final String? category;
  final String? location;
  final Map<String, dynamic>? filters;
}
 