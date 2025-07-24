import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> _navigateToFavorites(BuildContext context) async {
    Navigator.pushReplacementNamed(context, RouteNames.favorites);
  }

  Future<void> _navigateToBookings(BuildContext context) async {
    Navigator.pushReplacementNamed(context, RouteNames.bookingStatus);
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إشعارات المستخدم',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, RouteNames.userHome),
          ),
        ),
        body: Center(
          child: Text(
            localeNotifier.locale.languageCode == 'ar'
                ? 'لا توجد إشعارات حالياً'
                : 'No notifications yet',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
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
                _navigateToFavorites(context);
                break;
              case 3:
                _navigateToBookings(context);
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
    );
  }
}
