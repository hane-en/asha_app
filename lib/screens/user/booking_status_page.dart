import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import '../../utils/helpers.dart';

class BookingStatusPage extends StatefulWidget {
  const BookingStatusPage({super.key, required this.userId});
  final int userId;

  @override
  _BookingStatusPageState createState() => _BookingStatusPageState();
}

class _BookingStatusPageState extends State<BookingStatusPage> {
  List<BookingModel> bookings = [];
  bool isLoading = true;
  String? selectedStatus;

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

  Future<void> _navigateToFavorites() async {
    Navigator.pushReplacementNamed(context, RouteNames.favorites);
  }

  Future<void> loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - جلب الطلبات من الخادم
        final results = await ApiService.getBookings(
          userId,
          status: selectedStatus,
        );
        setState(() {
          bookings = results;
          isLoading = false;
        });
      } else {
        // المستخدم غير مسجل دخول - عرض رسالة
        setState(() {
          bookings = [];
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول لعرض الطلبات'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الطلبات: $e')));
    }
  }

  Future<void> cancelBooking(BookingModel booking) async {
    // التحقق من إمكانية الإلغاء
    if (!booking.canBeCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن إلغاء هذا الحجز'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // عرض تأكيد الإلغاء
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'تأكيد الإلغاء',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await ApiService.cancelBooking(booking.id);
      if (success) {
        loadBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إلغاء الحجز بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ فشل في إلغاء الحجز'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.userHome,
        (route) => false,
      );
      return false;
    },
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حالة الطلبات'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.userHome,
                (route) => false,
              );
            },
          ),
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
                        'لا توجد طلبات حتى الآن',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadBookings,
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
          type: BottomNavigationBarType.fixed,
          currentIndex: 3,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 3) return; // بالفعل في صفحة الطلبات
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, RouteNames.userHome);
                break;
              case 1:
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.serviceSearch,
                );
                break;
              case 2:
                _navigateToFavorites();
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'الطلبات'),
          ],
        ),
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
                loadBookings();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ExpansionTile(
        leading: Icon(Icons.event_note, color: Colors.purple),
        title: Text(
          booking.serviceName ?? 'خدمة غير محددة',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المزود: ${booking.providerName}'),
            Text('التاريخ: ${booking.formattedDate}'),
            Text('الوقت: ${booking.time}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: booking.statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            booking.statusText,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السعر: ${booking.formattedPrice}'),
                if (booking.note.isNotEmpty) Text('ملاحظات: ${booking.note}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (booking.canBeCancelled)
                      ElevatedButton.icon(
                        onPressed: () => cancelBooking(booking),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text(
                          'إلغاء الحجز',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    if (!booking.canBeCancelled && booking.isConfirmed)
                      const Text(
                        'لا يمكن الإلغاء بعد 24 ساعة من التأكيد',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
