import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/hotel_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelService {
  Future<List<Hotel>> getHotels() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/hotels');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['payload']; 
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data hotel');
      }
    } catch (e) {
      print("Error Fetching Hotels: $e");
      rethrow;
    }
  }

  Future<Hotel> getHotelById(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/hotels/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic data = responseData['payload']; 
        return Hotel.fromJson(data);
      } else {
        throw Exception('Gagal mengambil detail hotel');
      }
    } catch (e) {
      print("Error Detail Hotel: $e");
      rethrow;
    }
  }

  // UPDATE HOTEL
  Future<bool> updateHotel(int id, String name, String address, String description, File? imageFile) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/hotels/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Gunakan MultipartRequest karena mendukung upload file (mirip POST)
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';
    
    request.fields['name'] = name;
    request.fields['address'] = address;
    request.fields['description'] = description;

    // Hanya kirim gambar jika user memilih gambar baru
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  // DELETE HOTEL
  Future<bool> deleteHotel(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/hotels/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete: $e");
      return false;
    }
  }

  static String fixImageUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }
}