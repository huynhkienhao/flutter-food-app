import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class UpdateUserScreen extends StatefulWidget {
  final String userId;
  final String? email;
  final String? fullName;
  final String? phoneNumber;

  UpdateUserScreen({
    required this.userId,
    this.email,
    this.fullName,
    this.phoneNumber,
  });

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? fullName;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    fullName = widget.fullName;
    phoneNumber = widget.phoneNumber;
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token != null) {
        try {
          await authService.updateUser(
            widget.userId,
            {
              "email": email,
              "fullName": fullName,
              "phoneNumber": phoneNumber,
            },
            token,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("user updated successfully!")),
          );

          Navigator.pop(context, true); // Quay lại HomeScreen và làm mới giao diện
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update user: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update user Info")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: fullName,
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Full name is required";
                  }
                  return null;
                },
                onSaved: (value) {
                  fullName = value;
                },
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Invalid email format";
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value;
                },
              ),
              TextFormField(
                initialValue: phoneNumber,
                decoration: InputDecoration(labelText: "Phone Number"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is required";
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return "Phone number must contain only digits";
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
