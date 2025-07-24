import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class ServiceDetailsPage extends StatefulWidget {

  const ServiceDetailsPage({
    super.key,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceImage,
  });
  final int userId;
  final int serviceId;
  final String serviceTitle;
  final String serviceImage;

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final favorites = await ApiService.getFavorites(widget.userId);
    setState(() {
      isFavorite = favorites.any((s) => s['id'] == widget.serviceId);
      isLoading = false;
    });
  }

  Future<void> toggleFavorite() async {
    bool success;
    if (isFavorite) {
      success = await ApiService.removeFavorite(
        widget.userId,
        widget.serviceId,
      );
    } else {
      success = await ApiService.addToFavorites(
        widget.userId,
        widget.serviceId,
      );
    }

    if (success) {
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? '✅ أُضيفت إلى المفضلة' : '🗑️ تم الحذف من المفضلة',
          ),
        ),
      );
    }
  }

  void bookService() {
    // يمكنك ربط الحجز بقاعدة بيانات لاحقًا
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ تم إرسال طلب الحجز')));
  }

  Future<void> _onBookPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      Navigator.pushNamed(context, AppRoutes.login);
    } else {
      // أكمل عملية الحجز هنا
      bookService();
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.serviceTitle)),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Image.network(
                    widget.serviceImage,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20),
                  Text(widget.serviceTitle, style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(
                      isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFavorite ? Colors.grey : Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _onBookPressed,
                    child: Text('احجز الآن'),
                  ),
                ],
              ),
      ),
    );
}
