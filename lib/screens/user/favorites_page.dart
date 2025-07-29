import 'package:flutter/material.dart';
import 'package:asha_application/services/api_service.dart';
import 'package:asha_application/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - جلب من API
        final favorites = await ApiService.getFavorites(userId);
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      } else {
        // المستخدم غير مسجل دخول - جلب من التخزين المحلي
        final localFavorites = prefs.getStringList('local_favorites') ?? [];
        final allServices = await ApiService.getAllServices();

        final localFavoritesList = allServices
            .where((service) => localFavorites.contains(service.id.toString()))
            .map((service) => service.toJson())
            .toList();

        setState(() {
          _favorites = localFavoritesList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> remove(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - حذف من الخادم
        final success = await ApiService.removeFavorite(userId, serviceId);
        if (success) {
          setState(() {
            _favorites.removeWhere((s) => s['id'] == serviceId);
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم الحذف من المفضلة')));
        }
      } else {
        // المستخدم غير مسجل دخول - حذف من التخزين المحلي
        final localFavorites = prefs.getStringList('local_favorites') ?? [];
        localFavorites.remove(serviceId.toString());
        await prefs.setStringList('local_favorites', localFavorites);

        setState(() {
          _favorites.removeWhere((s) => s['id'] == serviceId);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم الحذف من المفضلة')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  Future<void> _navigateToBookings() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.bookingStatus,
      (route) => false,
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/user_home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد خدمات في المفضلة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final service = _favorites[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading:
                        service['images'] != null &&
                            (service['images'] as List).isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'http://127.0.0.1/asha_app_backend/uploads/${service['images'][0]}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                    title: Text(service['title'] ?? 'عنوان الخدمة'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['description'] ?? 'وصف الخدمة'),
                        const SizedBox(height: 4),
                        Text(
                          '${service['price'] ?? 0} ريال',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => remove(service['id']),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: service,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
