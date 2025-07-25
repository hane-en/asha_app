import 'package:flutter/material.dart';
import 'admin_home_page.dart';
import 'package:provider/provider.dart';
import '../user/settings_page.dart' show LocaleNotifier;
import '../../utils/helpers.dart' show ThemeNotifier;
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localeNotifier.locale.languageCode == 'ar'
                ? 'إعدادات المشرف'
                : 'Admin Settings',
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                localeNotifier.locale.languageCode == 'ar'
                    ? 'اسم المشرف'
                    : 'Admin Name',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'admin@email.com',
                style: TextStyle(color: Colors.grey),
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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomePage()),
                (route) => false,
              );
            }
            // إذا كنت بالفعل في صفحة الإعدادات لا تفعل شيئاً
          },
        ),
      ),
    );
  }
}
