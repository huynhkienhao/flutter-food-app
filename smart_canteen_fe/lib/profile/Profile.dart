import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  String? userId;
  String? email;
  String? fullName;
  String? phoneNumber;
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

      if (token != null && userId != null) {
        final userDetails = await authService.getUserDetails(userId, token);

        setState(() {
          this.userId = userId;
          email = userDetails["email"];
          fullName = userDetails["fullName"];
          phoneNumber = userDetails["phoneNumber"];
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải thông tin người dùng: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    userId: userId,
                    email: email,
                    fullName: fullName,
                    phoneNumber: phoneNumber,
                  ),
                ),
              );
              if (updated == true) {
                setState(() {
                  isLoading = true; // Hiển thị vòng tròn tải
                });
                await _loadUserDetails(); // Tải lại dữ liệu
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.green[50], // Màu nền xanh lá nhạt
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Phần trên: Avatar và tên người dùng
                    Container(
                      color: Colors.green.shade100,
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Colors.brown.shade300, // Màu xám nâu
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName ?? "Tên người dùng",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900, // Màu xanh đậm
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                email ?? "Email người dùng",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .green.shade700, // Màu xanh nhạt hơn
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Phần thông tin chi tiết
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              "Số điện thoại:", phoneNumber ?? "Không có"),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}
