import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../models/provider_model.dart';
import 'provider_services_page.dart';

class CategoryProvidersPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProvidersPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProvidersPage> createState() => _CategoryProvidersPageState();
}

class _CategoryProvidersPageState extends State<CategoryProvidersPage> {
  List<ProviderModel> providers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    try {
      final providersData = await ApiService.getProvidersByCategory(
        widget.categoryId,
      );

      setState(() {
        providers = providersData.map((data) => ProviderModel.fromJson(data)).toList();
      });
    } catch (e) {
      print('Error loading providers: $e');
      setState(() {
        providers = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToProviderServices(ProviderModel provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderServicesPage(
          providerId: provider.id,
          providerName: provider.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مزودي خدمات ${widget.categoryName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : providers.isEmpty
          ? const Center(
              child: Text(
                'لا يوجد مزودي خدمات لهذه الفئة',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToProviderServices(provider),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryColor,
                            child: provider.profileImage != null && provider.profileImage!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      provider.profileImage!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text(
                                          provider.firstLetter,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    provider.firstLetter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.description ?? 'لا يوجد وصف',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: provider.ratingColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider.formattedRating,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: provider.ratingColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${provider.reviewCount} تقييم)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: provider.verificationColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider.verificationStatus,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: provider.verificationColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${provider.city}, ${provider.country}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
