import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class RoomService {
  // CREATE
  Future<bool> createRoom(int hotelId, String type, double price, int capacity, File? imageFile) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/rooms');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['hotelId'] = hotelId.toString();
    request.fields['type'] = type;
    request.fields['price'] = price.toString();
    request.fields['capacity'] = capacity.toString();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print("Error Create Room: $e");
      return false;
    }
  }

  // UPDATE
  Future<bool> updateRoom(int roomId, String type, double price, int capacity, File? imageFile) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/rooms/$roomId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['type'] = type;
    request.fields['price'] = price.toString();
    request.fields['capacity'] = capacity.toString();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update Room: $e");
      return false;
    }
  }

  // DELETE
  Future<bool> deleteRoom(int roomId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/rooms/$roomId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete Room: $e");
      return false;
    }
  }
}