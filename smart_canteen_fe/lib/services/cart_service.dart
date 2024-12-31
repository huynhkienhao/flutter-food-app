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

  Future<Map<String, dynamic>> createOrder(List<int> cartIds) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy token từ SharedPreferences
    final token = prefs.getString("jwt_token");
    if (token == null) {
      throw Exception("Authentication token not found. Please log in again.");
    }

    // Lấy userId từ SharedPreferences
    final userId = prefs.getString("user_id");
    if (userId == null) {
      throw Exception("User ID not found. Please log in again.");
    }

    try {
      final url = "${Config.apiBaseUrl}/order";
      print("Calling API: $url with UserID: $userId and Cart IDs: $cartIds");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'cartIds': cartIds,
        }),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return json.decode(response.body); // Trả về dữ liệu hóa đơn
      } else {
        throw Exception("Failed to create order: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in createOrder: $e");
      rethrow;
    }
  }

  Future<int> getCartItemCount(String userId) async {
    final url = Uri.parse('${Config.apiBaseUrl}/Cart/count?userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0; // Đảm bảo trả về số lượng sản phẩm
      } else {
        throw Exception("Failed to fetch cart item count");
      }
    } catch (e) {
      print("Error in getCartItemCount: $e");
      return 0; // Trả về 0 nếu có lỗi
    }
  }

}
