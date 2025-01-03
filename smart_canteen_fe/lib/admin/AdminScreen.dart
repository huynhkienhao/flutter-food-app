import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:convert';
import '../Order/order_screen.dart';
import '../Category/category_screen.dart';
import '../Product/product_screen.dart';
import '../Profile/Profile.dart';
import '../Order/order_history_admin.dart';
import 'UserManagementAdminScreen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  Future<void> _scanQrCode(BuildContext context) async {
    try {
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Barcode) {
        final scannedData = result.rawContent.trim();
        print('Scanned Data: $scannedData');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderScreen(
              orderData: _parseScannedData(scannedData),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error occurred while scanning QR Code: $e');
    }
  }

  Map<String, dynamic> _parseScannedData(String data) {
    try {
      return json.decode(data);
    } catch (e) {
      print('Invalid QR Code format: $e');
      return {};
    }
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
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQrCode(context),
        backgroundColor: Colors.green,
        shape: CircleBorder(),
        child: Icon(Icons.qr_code_scanner, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _selectedIndex == 0
              ? _buildMainDashboard(context)
              : ProfileScreen(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0), // Thêm padding để tạo khoảng cách
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left items
              Row(
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard,
                    label: "Dashboard",
                    index: 0,
                  ),
                ],
              ),
              // Right items
              Row(
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.person,
                    label: "Admin",
                    index: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.grey),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context) {
    return SingleChildScrollView(
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
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: NeverScrollableScrollPhysics(),
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
              ],
            ),
          ],
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
