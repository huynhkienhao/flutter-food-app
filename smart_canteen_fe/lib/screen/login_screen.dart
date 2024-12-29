import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final AuthService authService = AuthService();

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await authService.login(
        usernameController.text,
        passwordController.text,
      );

      print("Login response: $response");

      if (response['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // Lưu token và userId
        final token = response['token'];
        final userId = response['userId'];

        if (token != null && userId != null) {
          await prefs.setString("jwt_token", token);
          await prefs.setString("user_id", userId);

          // Gọi API để lấy thông tin chi tiết tài khoản
          final userDetails = await authService.getUserDetails(userId, token);
          final email = userDetails['email'];
          print("Fetched Email: $email");

          // Lưu email vào SharedPreferences
          await prefs.setString("user_email", email);

          // Chuyển hướng tới màn hình Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          throw Exception("Token hoặc UserId không tồn tại");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response['message']}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
