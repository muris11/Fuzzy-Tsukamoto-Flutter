import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? Env.apiBaseUrl;

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('GET $path gagal: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
    if (res.statusCode != 200) {
      throw Exception('POST $path gagal: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }
}
