import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config_url/config.dart';


class AuthService {
  // Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("${Config.apiBaseUrl}/Authenticate/login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }

  // Đăng ký
  Future<Map<String, dynamic>> register(
      String username, String email, String password, String fullName, String role) async {
    final url = Uri.parse("${Config.apiBaseUrl}/Authenticate/register");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to register: ${response.statusCode}");
    }
  }

  // Lấy thông tin chi tiết của User
  Future<Map<String, dynamic>> getUserDetails(String userId, String token) async {
    final url = Uri.parse("${Config.apiBaseUrl}/User/$userId");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch user details: ${response.statusCode}");
    }
  }

  // Cập nhật thông tin User
  Future<void> updateUser(
      String userId, Map<String, dynamic> userData, String token) async {
    final url = Uri.parse("${Config.apiBaseUrl}/User/$userId");
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update user: ${response.statusCode}");
    }
  }

}
