// static const String baseUrl = 'http://localhost:4000';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // iOS Simulator usually works with localhost. If not, change to 127.0.0.1
  static const String baseUrl = 'http://localhost:4000';

  Future<Map<String, dynamic>> signup({
    required String identifier,
    required String password,
    required String fullName,
    required String username,
    required String birthdate, // YYYY-MM-DD
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
        'fullName': fullName,
        'username': username,
        'birthdate': birthdate,
      }),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> confirmSignup({
    required String identifier,
    required String code,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/confirm-signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'code': code}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String identifier,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> confirmForgotPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/confirm-forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    return _handle(res);
  }

  Map<String, dynamic> _handle(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    final msg = (body is Map && body['message'] != null)
        ? body['message']
        : 'Request failed';
    throw Exception(msg);
  }
}
