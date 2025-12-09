import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ReviewService {
  // Kirim Review
  Future<bool> createReview(int hotelId, int rating, String comment) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/reviews');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'hotelId': hotelId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        print("Gagal Review: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Error Review: $e");
      return false;
    }
  }

  // Ambil Review per Hotel (Optional, untuk ditampilkan di Detail Hotel)
  Future<List<dynamic>> getReviewsByHotel(int hotelId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/reviews/$hotelId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payload'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}