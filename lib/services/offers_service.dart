import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../constants/api_constants.dart';
import '../models/offer_model.dart';

class OffersService {
  static const String baseUrl = Config.apiBaseUrl;

  // جلب جميع العروض
  static Future<Map<String, dynamic>> getAllOffers({
    int? serviceId,
    bool isActive = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'is_active': isActive.toString(),
      };

      if (serviceId != null) {
        queryParams['service_id'] = serviceId.toString();
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final uri = Uri.parse('$baseUrl${ApiConstants.getAllOffers}?$queryString');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'فشل في تحميل العروض'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // جلب العروض لخدمة محددة
  static Future<Map<String, dynamic>> getOffersByService(int serviceId) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.getOffersByService}?service_id=$serviceId');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'فشل في تحميل العروض'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // تحويل البيانات إلى نموذج العرض
  static List<OfferModel> parseOffers(List<dynamic> offersData) {
    return offersData.map((data) => OfferModel.fromJson(data)).toList();
  }

  // جلب أفضل عرض صالح
  static OfferModel? getBestValidOffer(List<OfferModel> offers) {
    OfferModel? bestOffer;
    
    for (final offer in offers) {
      if (offer.isValid) {
        if (bestOffer == null || offer.discountPercentage > bestOffer.discountPercentage) {
          bestOffer = offer;
        }
      }
    }
    
    return bestOffer;
  }
} 