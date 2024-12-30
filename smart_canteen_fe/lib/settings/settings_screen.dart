import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../update_user/UpdateUserScreen.dart';
import '../screen/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String? userId;
  final String? email;
  final String? fullName;
  final String? phoneNumber;

  SettingsScreen({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
  });

  // Hàm đăng xuất
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa toàn bộ dữ liệu lưu trữ

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
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green, // Màu AppBar xanh lá cây
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Tùy chọn cập nhật thông tin
                ListTile(
                  leading: Icon(Icons.person, color: Colors.green), // Biểu tượng màu xanh lá
                  title: Text(
                    'Cập nhật thông tin',
                    style: TextStyle(color: Colors.black), // Màu chữ
                  ),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateUserScreen(
                          userId: userId!,
                          email: email,
                          fullName: fullName,
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    );

                    if (updated == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Thông tin đã được cập nhật.")),
                      );
                    }
                  },
                ),
                Divider(),
              ],
            ),
          ),

          // Nút đăng xuất ở dưới cùng
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Màu nền đỏ
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Đăng xuất",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
