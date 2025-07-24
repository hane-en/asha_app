import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';

class BookingStatusPage extends StatefulWidget {
  const BookingStatusPage({super.key, required this.userId});
  final int userId;

  @override
  _BookingStatusPageState createState() => _BookingStatusPageState();
}

class _BookingStatusPageState extends State<BookingStatusPage> {
  List<BookingModel> bookings = [];
  bool isLoading = true;

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
        final results = await ApiService.getBookings(userId);
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
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : bookings.isEmpty
              ? Center(child: Text('لا توجد طلبات حتى الآن'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Icon(Icons.event_note, color: Colors.purple),
                        title: Text(booking.serviceName ?? 'خدمة غير محددة'),
                        subtitle: Text('الحالة: ${booking.status}'),
                      ),
                    );
                  },
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'المفضلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'الطلبات',
              ),
            ],
          ),
        ),
      ),
    );
}
