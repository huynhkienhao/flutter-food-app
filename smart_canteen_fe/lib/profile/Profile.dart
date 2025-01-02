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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkModeProfile') ?? false;
    });
  }

  Future<void> _setThemeMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkModeProfile', value);
    setState(() {
      isDarkMode = value;
    });
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

  void _navigateToUpdateUser(BuildContext context) async {
    final updatedData = await Navigator.push(
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

    if (updatedData != null && mounted) {
      setState(() {
        email = updatedData['email'];
        fullName = updatedData['fullName'];
        phoneNumber = updatedData['phoneNumber'];
      });
    }
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

  void _navigateToSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          userId: userId,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          isDarkMode: isDarkMode,
          onThemeToggle: (value) => _setThemeMode(value),
        ),
      ),
    );
    await _loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.green,
      ),
      body: Column(
        children: [
          Container(
            color: isDarkMode ? Colors.grey[900] : Colors.green[50],
            child: isLoading
                ? SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
                : Column(
              children: [
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
                        onTap: () => _navigateToUpdateUser(context),
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
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
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
          SizedBox(height: 4),
          Column(
            children: [
              OrderHistoryCard(
                onTap: () => _navigateToOrderHistory(context),
                isDarkMode: isDarkMode,
              ),
              SettingsCard(
                onTap: () => _navigateToSettings(context),
                isDarkMode: isDarkMode,
              ),
            ],
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

class OrderHistoryCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDarkMode;

  const OrderHistoryCard({
    Key? key,
    required this.onTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 16,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
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
            Text(
              'Lịch sử đơn hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDarkMode;

  const SettingsCard({
    Key? key,
    required this.onTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 16,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                size: 24,
                color: isDarkMode ? Colors.white : Colors.green[800],
              ),
            ),
            Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
