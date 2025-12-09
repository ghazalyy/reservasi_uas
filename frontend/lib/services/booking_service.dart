import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class BookingService {
  // Fungsi POST Booking
  Future<bool> createBooking(int roomId, DateTime checkIn, DateTime checkOut) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bookings');
    
    // Ambil token dari penyimpanan HP
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Wajib kirim token
        },
        body: jsonEncode({
          'roomId': roomId,
          'checkIn': checkIn.toIso8601String(),  // Format tanggal standar
          'checkOut': checkOut.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return true; // Berhasil
      } else {
        final data = jsonDecode(response.body);
        print("Gagal Booking: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Error Booking: $e");
      return false;
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bookings/my');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payload']; // List booking
      }
      return [];
    } catch (e) {
      print("Error Get My Bookings: $e");
      return [];
    }
  }
}