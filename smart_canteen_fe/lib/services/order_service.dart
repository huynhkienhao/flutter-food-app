import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config_url/config.dart';

class OrderService {
  final String baseUrl = "${Config.apiBaseUrl}/Order";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<List<dynamic>> getOrderHistoryByUserId(String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch order history: ${response.statusCode}");
    }
  }
  Future<Map<String, dynamic>> getOrderDetailsById(int orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/$orderId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch order details: ${response.statusCode}");
    }
  }
  Future<List<dynamic>> getAllOrderHistories() async {
    final token = await _getToken(); // Lấy token từ phương thức _getToken()
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    // Gọi API với endpoint để lấy toàn bộ lịch sử đơn hàng
    final response = await http.get(
      Uri.parse("https://earlysageshop67.conveyor.cloud/api/order"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Parse response body thành danh sách JSON
      return json.decode(response.body);
    } else {
      // Xử lý lỗi nếu xảy ra
      throw Exception("Failed to fetch all order histories: ${response.statusCode}");
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/$orderId/status"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(status),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update order status: ${response.statusCode}");
    }
  }

}
