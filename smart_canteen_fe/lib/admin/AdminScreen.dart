import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Category/category_screen.dart';
import '../Product/product_screen.dart';
import '../screen/login_screen.dart';
import '../profile/Profile.dart';

class AdminScreen extends StatelessWidget {
  // Hàm đăng xuất
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Điều hướng về màn hình Login
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
        title: Text("admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, admin!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryManagementScreen()),
                );
              },
              child: Text("Manage Categories"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen()),
                );
              },
              child: Text("Manage Products"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text("View Profile"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _logout(context);
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
