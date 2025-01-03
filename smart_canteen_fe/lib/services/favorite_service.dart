import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config_url/config.dart';

class FavoriteService {
  final String baseUrl = "${Config.apiBaseUrl}/api/Favorite";

  // Lấy danh sách sản phẩm yêu thích của người dùng
  Future<List<dynamic>> getFavoritesByUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");

    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch favorites. Status: ${response.statusCode}");
    }
  }

  // Thêm sản phẩm vào danh sách yêu thích
  Future<void> addToFavorite(String userId, int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");

    final body = {
      "userId": userId,
      "productId": productId,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add to favorite. Status: ${response.statusCode}");
    }
  }

  // Xóa sản phẩm khỏi danh sách yêu thích
  Future<void> removeFromFavorite(int favoriteId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");

    final response = await http.delete(
      Uri.parse("$baseUrl/$favoriteId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to remove from favorite. Status: ${response.statusCode}");
    }
  }
}
