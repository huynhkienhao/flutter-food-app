import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  String? userId;
  String? email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      final userId = prefs.getString("user_id");
      final email = prefs.getString("user_email");

      print("Token: $token");
      print("UserId: $userId");
      print("Email: $email");

      if (token != null && userId != null && email != null) {
        setState(() {
          this.userId = userId;
          this.email = email;
          isLoading = false;
        });
      } else {
        print("Token hoặc UserId hoặc email không tồn tại. Đăng xuất...");
        _logout();
      }
    } catch (e) {
      print("Error in _loadUserDetails: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading user details: $e")),
      );

      _logout();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove("jwt_token");
    // await prefs.remove("user_id");
    // await prefs.remove("user_email");

    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('User ID: $userId'),
            Text('Email: $email'),
          ],
        ),
      ),
    );
  }
}
