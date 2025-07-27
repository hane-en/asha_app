import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/provider_service.dart';
import '../../models/booking_model.dart';
import 'booking_details_page.dart';

class ProviderBookingsPage extends StatefulWidget {
  const ProviderBookingsPage({super.key});

  @override
  State<ProviderBookingsPage> createState() => _ProviderBookingsPageState();
}

class _ProviderBookingsPageState extends State<ProviderBookingsPage> {
  List<Map<String, dynamic>> bookings = [];
  Map<String, dynamic>? stats;
  bool isLoading = true;
  String? selectedStatus;
  int currentPage = 1;
  bool hasMoreData = true;

  // الحالات المتاحة للحجوزات
  final Map<String, String> statusOptions = {
    'pending': 'قيد المراجعة',
    'confirmed': 'مؤكد',
    'completed': 'مكتمل',
    'rejected': 'مرفوض',
    'cancelled': 'ملغي',
  };

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMoreData = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final providerId = prefs.getInt('user_id');

      if (providerId == null) {
        throw Exception('لم يتم العثور على معرف المزود');
      }

      final results = await ProviderService.getMyBookings(
        providerId,
        status: selectedStatus,
      );

      if (refresh) {
        setState(() {
          bookings = results;
          isLoading = false;
        });
      } else {
        setState(() {
          bookings.addAll(results);
          isLoading = false;
          hasMoreData =
              results.length >= 10; // افتراض أن كل صفحة تحتوي على 10 عناصر
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الحجوزات: $e')));
      }
    }
  }

  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      final success = await ProviderService.updateBookingStatus(
        bookingId,
        newStatus,
      );
      if (success) {
        loadBookings(refresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ تم تحديث الحالة إلى: ${_getStatusText(newStatus)}',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ فشل في تحديث الحالة')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
      }
    }
  }

  String _getStatusText(String status) {
    return statusOptions[status] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // الحصول على الحالات المتاحة حسب الحالة الحالية
  List<String> getAvailableStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['confirmed', 'rejected'];
      case 'confirmed':
        return ['completed', 'cancelled'];
      case 'completed':
        return []; // لا يمكن تغيير الحالة بعد الإكمال
      case 'rejected':
        return []; // لا يمكن تغيير الحالة بعد الرفض
      case 'cancelled':
        return []; // لا يمكن تغيير الحالة بعد الإلغاء
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/provider-home',
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadBookings(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // فلاتر الحالة
          _buildStatusFilters(),

          // قائمة الحجوزات
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookings.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد حجوزات',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => loadBookings(refresh: true),
                    child: ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _buildBookingCard(booking);
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-home',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-pending',
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-services',
                (route) => false,
              );
              break;
            case 3:
              // أنت بالفعل هنا
              break;
            case 4:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-ads',
                (route) => false,
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'قيد الانتظار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'خدماتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'إعلاناتي',
          ),
        ],
      ),
    ),
  );

  Widget _buildStatusFilters() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'حالة الحجز',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('جميع الحجوزات'),
                ),
                ...statusOptions.entries.map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedStatus = value);
                loadBookings(refresh: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final bookingId = booking['id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          booking['service_title'] ?? 'خدمة غير محددة',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العميل: ${booking['user_name'] ?? 'غير محدد'}'),
            Text('التاريخ: ${booking['booking_date'] ?? 'غير محدد'}'),
            Text('الوقت: ${booking['booking_time'] ?? 'غير محدد'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // قائمة منسدلة لتغيير الحالة
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: _buildStatusDropdown(bookingId, status),
            ),
            // عرض الحالة الحالية
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(status),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الهاتف: ${booking['user_phone'] ?? 'غير محدد'}'),
                Text(
                  'البريد الإلكتروني: ${booking['user_email'] ?? 'غير محدد'}',
                ),
                Text('السعر: ${booking['total_price'] ?? 0} ريال'),
                if (booking['notes'] != null && booking['notes'].isNotEmpty)
                  Text('ملاحظات: ${booking['notes']}'),
                const SizedBox(height: 16),
                _buildActionButtons(booking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(int bookingId, String currentStatus) {
    final availableStatuses = getAvailableStatuses(currentStatus);

    if (availableStatuses.isEmpty) {
      return const SizedBox.shrink(); // لا تظهر القائمة إذا لم تكن هناك خيارات متاحة
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: null,
        hint: const Text('تغيير الحالة', style: TextStyle(fontSize: 12)),
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.purple),
        items: availableStatuses
            .map(
              (status) => DropdownMenuItem(
                value: status,
                child: Text(
                  statusOptions[status] ?? status,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )
            .toList(),
        onChanged: (newStatus) {
          if (newStatus != null) {
            _showStatusChangeDialog(bookingId, currentStatus, newStatus);
          }
        },
      ),
    );
  }

  void _showStatusChangeDialog(
    int bookingId,
    String currentStatus,
    String newStatus,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد تغيير الحالة'),
          content: Text(
            'هل أنت متأكد من تغيير الحالة من "${_getStatusText(currentStatus)}" إلى "${_getStatusText(newStatus)}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateBookingStatus(bookingId, newStatus);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final bookingId = booking['id'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (status == 'pending') ...[
          ElevatedButton.icon(
            onPressed: () => updateBookingStatus(bookingId, 'confirmed'),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton.icon(
            onPressed: () => updateBookingStatus(bookingId, 'rejected'),
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text('رفض', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
        if (status == 'confirmed') ...[
          ElevatedButton.icon(
            onPressed: () => updateBookingStatus(bookingId, 'completed'),
            icon: const Icon(Icons.done_all, color: Colors.white),
            label: const Text('إكمال', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsPage(booking: booking),
              ),
            );
          },
          icon: const Icon(Icons.info, color: Colors.white),
          label: const Text('التفاصيل', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
        ),
      ],
    );
  }
}
