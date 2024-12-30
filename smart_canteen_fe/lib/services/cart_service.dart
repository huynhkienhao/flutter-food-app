import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config_url/config.dart';

class CartService {
  final String baseUrl = "${Config.apiBaseUrl}/Cart";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<List<dynamic>> getCartItems(String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch cart items.");
    }
  }

  Future<void> addToCart(String userId, int productId, int quantity) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add to cart.");
    }
  }

  Future<void> removeFromCart(int cartId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/$cartId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to remove item from cart.");
    }
  }
}
