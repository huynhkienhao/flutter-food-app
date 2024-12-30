import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import '../Admin/AdminScreen.dart';
import '../User/UserScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Canteen Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Màn hình kiểm tra role ban đầu
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString("user_role");

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminScreen()),
      );
    } else if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

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
        final role = response['role'];

        if (token != null && userId != null && role != null) {
          await prefs.setString("jwt_token", token);
          await prefs.setString("user_id", userId);
          await prefs.setString("user_role", role);

          // Điều hướng dựa trên role
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          } else if (role == 'user') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          } else {
            throw Exception("Không xác định được vai trò");
          }
        } else {
          throw Exception("Token, UserId hoặc Role không tồn tại");
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
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Tên người dùng'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
