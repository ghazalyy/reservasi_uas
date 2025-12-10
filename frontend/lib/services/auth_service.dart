import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  // Fungsi Login
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Ambil data dari payload response backend
        final token = data['payload']['token']; 
        final role = data['payload']['role']; 

        // Simpan token DAN role ke HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        // Simpan Role
        await prefs.setString('role', role ?? 'USER'); 
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error Login: $e");
      return false;
    }
  }

  // Fungsi Cek apakah user sudah login (Ambil Token)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi Ambil Role
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'USER' 
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Register: $e");
      return false;
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role'); 
  }
}