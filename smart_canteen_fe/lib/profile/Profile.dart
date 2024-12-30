import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
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
        SnackBar(content: Text("Error loading user details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'user Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('user ID: $userId'),
            Text('Email: $email'),
            Text('Full Name: $fullName'),
            Text('Phone Number: $phoneNumber'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
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
                  _loadUserDetails();
                }
              },
              child: Text("Update user Info"),
            ),
          ],
        ),
      ),
    );
  }
}
