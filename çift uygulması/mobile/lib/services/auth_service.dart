import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<String?> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url');
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = await getServerUrl();
    if (url == null) return {'success': false, 'message': 'Sunucu URL ayarlanmamış.'};

    final response = await http.post(
      Uri.parse('$url/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Kayıt başarısız.'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = await getServerUrl();
    if (url == null) return {'success': false, 'message': 'Sunucu URL ayarlanmamış.'};

    final response = await http.post(
      Uri.parse('$url/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['accessToken']);
      await prefs.setInt('userId', data['id']);
      await prefs.setString('username', data['username']);
      if (data['coupleId'] != null) {
        await prefs.setInt('coupleId', data['coupleId']);
      }
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Giriş başarısız.'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('coupleId');
  }
}
