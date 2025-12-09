import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminService {
  Future<Map<String, dynamic>?> getDashboardStats() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/admin/dashboard');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payload'];
      }
    } catch (e) {
      print("Error Stats: $e");
    }
    return null;
  }

  Future<String?> downloadReport() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/admin/export');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return response.body; 
      }
    } catch (e) {
      print("Error Export: $e");
    }
    return null;
  }
}