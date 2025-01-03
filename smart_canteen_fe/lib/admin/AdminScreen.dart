import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/itransport.dart';
import '../../config_url/config.dart';
import '../Order/order_history_admin.dart';
import '../Category/category_screen.dart';
import '../Order/order_screen.dart';
import '../Product/product_screen.dart';
import '../screen/login_screen.dart';
import '../Profile/Profile.dart';
import 'UserManagementAdminScreen.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late HubConnection _hubConnection;
  int _selectedIndex = 0; // Track selected index for bottom navigation.

  @override
  void initState() {
    super.initState();
    _initializeSignalR();
  }

  Future<void> _initializeSignalR() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      '${Config.apiBaseUrl}/notificationHub',
      options: HttpConnectionOptions(
        transport: HttpTransportType.WebSockets,
        skipNegotiation: true,
      ),
    )
        .withAutomaticReconnect()
        .build();

    _hubConnection.on("NewOrderCreated", (arguments) {
      final orderId = arguments?[0];
      final totalPrice = arguments?[1];
      final orderTime = arguments?[2];

      _showCustomNotification(context,
          "Đơn hàng mới: #$orderId - Tổng tiền: $totalPrice - Thời gian: $orderTime");
    });

    try {
      await _hubConnection.start();
      print("SignalR connection established for Admin");
    } catch (error) {
      print("SignalR connection error: $error");
    }
  }

  void _showCustomNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      overlayEntry.remove();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _scanQrCode(BuildContext context) async {
    try {
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Barcode) {
        final scannedData = result.rawContent.trim();
        print('Scanned Data: $scannedData');

        // Parse the scanned data and navigate to OrderScreen.
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
  void dispose() {
    _hubConnection.stop();
    super.dispose();
  }

  @override
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
      body: _selectedIndex == 0
          ? _buildMainDashboard(context)
          : _selectedIndex == 2
          ? ProfileScreen()
          : _buildMainDashboard(context), // Keep default dashboard or another widget.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Quét mã QR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Admin",
          ),
        ],
        onTap: (index) async {
          if (index == 1) {
            await _scanQrCode(context); // Trigger QR code scanning when tapping on the second item.
          } else {
            setState(() {
              _selectedIndex = index; // Update index only for other tabs.
            });
          }
        },
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
