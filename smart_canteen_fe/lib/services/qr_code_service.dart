import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config_url/config.dart';

class QRCodeService {
  final String baseUrl = "${Config.apiBaseUrl}/QRCode";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<Map<String, dynamic>> getQRCodeByOrderId(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in again.");
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
      throw Exception("Failed to fetch QR Code for Order ID: ${response.statusCode}");
    }
  }
  Future<Map<String, dynamic>> generateQRCode(int orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in again.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/generate"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to generate QR Code: ${response.statusCode}");
    }
  }

}
