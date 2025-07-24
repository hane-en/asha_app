import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProviderNotificationsPage extends StatelessWidget {
  const ProviderNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إشعارات المزود',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/provider-home',
              (route) => false,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'لا توجد إشعارات حالياً',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
