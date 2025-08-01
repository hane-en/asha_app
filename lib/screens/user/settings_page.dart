import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/helpers.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('ar', 'SA');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> _navigateToFavorites(BuildContext context) async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.pushReplacementNamed(
        context,
        RouteNames.favorites,
        arguments: FavoritesArguments(userId: userId),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToBookings(BuildContext context) async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.pushReplacementNamed(
        context,
        RouteNames.bookingStatus,
        arguments: BookingStatusArguments(userId: userId),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localeNotifier.locale.languageCode == 'ar'
                ? 'الإعدادات'
                : 'Settings',
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                localeNotifier.locale.languageCode == 'ar'
                    ? 'اسم المستخدم'
                    : 'Username',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                localeNotifier.locale.languageCode == 'ar'
                    ? 'البريد الإلكتروني'
                    : 'Email',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.purple),
              title: Text(
                localeNotifier.locale.languageCode == 'ar'
                    ? 'اللغة'
                    : 'Language',
              ),
              trailing: DropdownButton<String>(
                value: localeNotifier.locale.languageCode,
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    localeNotifier.setLocale(
                      val == 'ar'
                          ? const Locale('ar', 'SA')
                          : const Locale('en', 'US'),
                    );
                  }
                },
              ),
            ),
            SwitchListTile(
              value: themeNotifier.isDarkMode,
              onChanged: themeNotifier.setDarkMode,
              title: Text(
                localeNotifier.locale.languageCode == 'ar'
                    ? 'الوضع الداكن'
                    : 'Dark Mode',
              ),
              secondary: const Icon(Icons.dark_mode, color: Colors.purple),
            ),
            const Divider(height: 32),
          ],
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
