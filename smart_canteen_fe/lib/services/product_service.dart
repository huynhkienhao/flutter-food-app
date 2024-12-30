import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config_url/config.dart';

class ProductService {
  final String baseUrl = "${Config.apiBaseUrl}/product";

  Future<List<dynamic>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Request URL: $baseUrl");
      print("Authorization Token: Bearer $token");
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in getProducts: $e");
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );

      print("Request URL: $baseUrl");
      print("Request Body: ${json.encode(productData)}");
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 201) {
        throw Exception("Failed to add product: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in addProduct: $e");
      rethrow;
    }
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      if (!productData.containsKey('categoryId') || productData['categoryId'] == null) {
        throw Exception("categoryId is required in the productData.");
      }

      final response = await http.put(
        Uri.parse("$baseUrl/$productId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );

      print("Request URL: $baseUrl/$productId");
      print("Request Body: ${json.encode(productData)}");
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 204) {
        throw Exception("Failed to update product: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in updateProduct: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/$productId"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Request URL: $baseUrl/$productId");
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 204) {
        throw Exception("Failed to delete product: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in deleteProduct: $e");
      rethrow;
    }
  }

  // Hàm getProductsByCategory nằm ở đây, không nằm trong bất kỳ hàm nào khác
  Future<List<dynamic>> getProductsByCategory(int categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/category/$categoryId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Request URL: $baseUrl/category/$categoryId");
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("No products found for this category.");
      } else {
        throw Exception("Failed to fetch products by category: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in getProductsByCategory: $e");
      rethrow;
    }
  }

}
