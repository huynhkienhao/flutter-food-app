import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config_url/config.dart';

class UserService {
  final String baseUrl = "${Config.apiBaseUrl}/User";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  // Lấy danh sách tất cả người dùng
  Future<List<dynamic>> getAllUsers() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch users: ${response.statusCode}");
    }
  }

  // Lấy danh sách người dùng theo vai trò
  Future<List<dynamic>> getUsersByRole(String role) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/role/$role"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch users by role: ${response.statusCode}");
    }
  }

  // Xóa một người dùng
  Future<void> deleteUser(String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete user: ${response.statusCode}");
    }
  }

  // Lấy người dùng theo vai trò tự động theo tab
  Future<List<dynamic>> getUsersForCurrentTab(bool isAdminTab) async {
    final role = isAdminTab ? 'Admin' : 'User';
    return await getUsersByRole(role);
  }
}