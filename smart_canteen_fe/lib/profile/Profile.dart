import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../settings/settings_screen.dart';
import '../Order/order_history_screen.dart';
import '../update_user/UpdateUserScreen.dart';

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

  bool isDarkMode = false; // Trạng thái chế độ sáng/tối

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

  // Chuyển đổi chế độ sáng/tối
  void _toggleThemeMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode ? "Chế độ tối đã bật" : "Chế độ sáng đã bật",
        ),
      ),
    );
  }

  void _navigateToOrderHistory(BuildContext context) async {
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(userId: userId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID not found. Please log in.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.green,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            onPressed: _toggleThemeMode, // Gọi hàm chuyển đổi chế độ
          ),
        ],
      ),
      body: Column(
        children: [
          // Thông tin người dùng
          Container(
            color: isDarkMode ? Colors.grey[900] : Colors.green[50],
            child: isLoading
                ? SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
                : Column(
              children: [
                // Phần thông tin người dùng
                Container(
                  color: isDarkMode ? Colors.grey[740] : Colors.green[50],
                  padding: EdgeInsets.only(
                    top: 30.0,
                    bottom: 10.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
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
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDarkMode
                              ? Colors.grey[700]
                              : Colors.green[100],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.green[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        fullName ?? "Tên người dùng",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        email ?? "Email người dùng",
                        style: TextStyle(
                          fontSize: 16,
                          color:
                          isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                // Phần thông tin bổ sung
                SizedBox(height: 16),
                Container(
                  color: isDarkMode ? Colors.black : Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        "Số điện thoại:",
                        phoneNumber ?? "Không có",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Heading "Tiện ích"
          Container(
            color: isDarkMode ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tiện ích',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),

          // Giảm khoảng cách giữa Heading và Card
          SizedBox(height: 4),

          // Phần "Xem lịch sử đơn hàng"
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OrderHistoryMomoCard(
                onTap: () => _navigateToOrderHistory(context),
                isDarkMode: isDarkMode, // Truyền trạng thái chế độ tối
              ),
            ),
          ),
        ],
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
            color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ],
    );
  }
}

class OrderHistoryMomoCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDarkMode; // Trạng thái chế độ tối

  const OrderHistoryMomoCard({
    Key? key,
    required this.onTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 80,
        margin: EdgeInsets.only(left: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon bên trái
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 24,
                color: isDarkMode ? Colors.white : Colors.green[800],
              ),
            ),
            // Văn bản bên phải icon
            Text(
              'Lịch sử đơn hàng',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.black : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
