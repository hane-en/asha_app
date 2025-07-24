import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../user/settings_page.dart' show LocaleNotifier;

class ProviderLocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('ar', 'SA');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class ProviderSettingsPage extends StatelessWidget {
  const ProviderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<ProviderLocaleNotifier>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localeNotifier.locale.languageCode == 'ar'
                ? 'إعدادات المزود'
                : 'Provider Settings',
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/provider-home',
              (route) => false,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple,
              child: Icon(Icons.business, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'اسم مزود الخدمة',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'البريد الإلكتروني',
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
                    // غيّر اللغة في LocaleNotifier العالمي ليتم تغيير لغة كل الصفحات
                    Provider.of<LocaleNotifier>(
                      context,
                      listen: false,
                    ).setLocale(
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
      ),
    );
  }
}
