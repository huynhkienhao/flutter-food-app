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
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? "Đăng nhập thất bại");
      }
      // return json.decode(response.body);
    } else {
      throw Exception("Không đăng nhập được: ${response.statusCode}");
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
        'fullName': fullName,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Không đăng ký được: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String userId, String token) async {
    final url = Uri.parse("${Config.apiBaseUrl}/User/$userId");
    print("Đang lấy thông tin chi tiết người dùng cho URL: $url");
    print("Authorization Token: $token");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Đã lấy thông tin chi tiết người dùng thành công: ${response.body}");
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      print("Không thể lấy thông tin chi tiết người dùng: ${response.statusCode}, ${response.body}");
      throw Exception("Không thể lấy thông tin chi tiết người dùng: ${response.statusCode}");
    }
  }
}
