import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Order/order_history_screen.dart';
import '../Category/category_screen.dart';
import '../screen/login_screen.dart';
import '../Profile/Profile.dart';
import '../screen/home_screen.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    CategoryManagementScreen(),
    ProfileScreen(),
  ];

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  void _navigateToOrderHistory(BuildContext context) async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(userId: userId),
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
      body: Column(
        children: [
          if (_selectedIndex == 0) // Hiển thị tìm kiếm chỉ ở màn hình Home
            SafeArea(
              child: Container(
                color: Colors.green,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm sản phẩm...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text("User Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _navigateToOrderHistory(context),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Danh mục",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Tôi",
          ),
        ],
      ),
    );
  }
}
