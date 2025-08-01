import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/config.dart';
import 'routes/app_routes.dart';
import 'screens/provider/settings_page.dart' show ProviderLocaleNotifier;
import 'screens/user/settings_page.dart' show LocaleNotifier;
import 'utils/constants.dart';
import 'utils/helpers.dart' show ThemeNotifier;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // تعيين اتجاه التطبيق من اليمين إلى اليسار
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تعيين شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(
          create: (_) => ProviderLocaleNotifier(),
        ), // لدعم إعدادات اللغة للمزود
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    return MaterialApp(
      title: Config.appName,
      debugShowCheckedModeBanner: false,
      locale: localeNotifier.locale,
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.userHome,
      builder: (context, child) => Directionality(
        textDirection: localeNotifier.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        ),
      ),
    );
  }
}
