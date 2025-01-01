import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../update_user/UpdateUserScreen.dart';

class SettingsScreen extends StatelessWidget {
  final String? userId;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const SettingsScreen({
    Key? key,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.brightness_6, color: Colors.green),
            title: Text('Chế độ sáng/tối'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: onThemeToggle,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.green),
            title: Text('Cập nhật thông tin'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateUserScreen(
                  userId: userId!,
                  email: email,
                  fullName: fullName,
                  phoneNumber: phoneNumber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
