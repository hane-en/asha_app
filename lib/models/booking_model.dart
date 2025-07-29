import 'package:flutter/material.dart';

class BookingModel {
  BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.userName,
    required this.serviceName,
    required this.providerName,
    required this.date,
    required this.time,
    required this.note,
    required this.status,
    required this.totalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: int.tryParse(json['id'].toString()) ?? 0,
    userId: int.tryParse(json['user_id'].toString()) ?? 0,
    serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
    userName: json['user_name'] ?? '',
    serviceName: json['service_name'] ?? '',
    providerName: json['provider_name'] ?? '',
    date: json['date'] != null
        ? DateTime.tryParse(json['date']) ?? DateTime.now()
        : DateTime.now(),
    time: json['time'] ?? '',
    note: json['note'] ?? '',
    status: json['status'] ?? 'pending',
    totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'])
        : null,
  );
  final int id;
  final int userId;
  final int serviceId;
  final String userName;
  final String serviceName;
  final String providerName;
  final DateTime date;
  final String time;
  final String note;
  final String status;
  final double totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'service_id': serviceId,
    'user_name': userName,
    'service_name': serviceName,
    'provider_name': providerName,
    'date': date.toIso8601String(),
    'time': time,
    'note': note,
    'status': status,
    'total_price': totalPrice,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  BookingModel copyWith({
    int? id,
    int? userId,
    int? serviceId,
    String? userName,
    String? serviceName,
    String? providerName,
    DateTime? date,
    String? time,
    String? note,
    String? status,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BookingModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    serviceId: serviceId ?? this.serviceId,
    userName: userName ?? this.userName,
    serviceName: serviceName ?? this.serviceName,
    providerName: providerName ?? this.providerName,
    date: date ?? this.date,
    time: time ?? this.time,
    note: note ?? this.note,
    status: status ?? this.status,
    totalPrice: totalPrice ?? this.totalPrice,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BookingModel(id: $id, serviceName: $serviceName, status: $status, date: $date)';

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedPrice => '${totalPrice.toStringAsFixed(2)} ريال';
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد المراجعة';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isRejected => status.toLowerCase() == 'rejected';

  // التحقق من إمكانية الإلغاء
  bool get canBeCancelled {
    if (isCancelled || isRejected || isCompleted) return false;

    // إذا كان مؤكد، تحقق من الوقت
    if (isConfirmed && updatedAt != null) {
      final now = DateTime.now();
      final timeDiff = now.difference(updatedAt!);
      return timeDiff.inHours <= 24;
    }

    return true;
  }
}
