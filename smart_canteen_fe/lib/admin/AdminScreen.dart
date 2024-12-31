import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../QrCode/qr_code_scanner.dart';
import '../Order/order_history_admin.dart';
import '../Category/category_screen.dart';
import '../Product/product_screen.dart';
import '../screen/login_screen.dart';
import '../Profile/Profile.dart';
import 'UserManagementAdminScreen.dart';

class AdminScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
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
        title: Text(
          "Bảng điều khiển Admin",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chào mừng, Admin!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    title: "Quản lý danh mục",
                    icon: Icons.category,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Quản lý sản phẩm",
                    icon: Icons.shopping_cart,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Quản lý hóa đơn",
                    icon: Icons.receipt,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderHistoryAdminScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Quản lý người dùng",
                    icon: Icons.people,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserManagementAdminScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Quét mã QR",
                    icon: Icons.qr_code_scanner,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrCodeScanner(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Xem hồ sơ",
                    icon: Icons.person,
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Đăng xuất",
                    icon: Icons.logout,
                    color: Colors.grey,
                    onTap: () {
                      _logout(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
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
    );
  }
}
