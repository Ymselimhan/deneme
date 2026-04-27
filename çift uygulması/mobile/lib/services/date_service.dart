import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/special_date.dart';

class DateService {
  Future<String?> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> getCoupleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coupleId');
  }

  Future<List<SpecialDate>> getSpecialDates() async {
    final url = await getServerUrl();
    final token = await getToken();
    final coupleId = await getCoupleId();

    if (url == null || token == null || coupleId == null) return [];

    final response = await http.get(
      Uri.parse('$url/api/dates/$coupleId'),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SpecialDate.fromJson(item)).toList();
    } else {
      throw Exception('Özel günler yüklenemedi');
    }
  }

  Future<SpecialDate> createSpecialDate(String title, DateTime date, String type, String? description) async {
    final url = await getServerUrl();
    final token = await getToken();
    final coupleId = await getCoupleId();

    if (url == null || token == null || coupleId == null) throw Exception('Eksik bilgi');

    final response = await http.post(
      Uri.parse('$url/api/dates'),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token,
      },
      body: jsonEncode({
        'title': title,
        'date': date.toIso8601String(),
        'type': type,
        'description': description,
        'coupleId': coupleId,
      }),
    );

    if (response.statusCode == 201) {
      return SpecialDate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Özel gün oluşturulamadı');
    }
  }

  Future<void> deleteSpecialDate(int id) async {
    final url = await getServerUrl();
    final token = await getToken();

    if (url == null || token == null) throw Exception('Eksik bilgi');

    final response = await http.delete(
      Uri.parse('$url/api/dates/$id'),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Silme işlemi başarısız');
    }
  }
}
