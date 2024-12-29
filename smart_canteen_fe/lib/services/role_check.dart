import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_canteen_fe/screen/login_screen.dart';
import 'package:smart_canteen_fe/constants/token_handler.dart';

class RoleCheck {
  void checkAdminRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role = decodedToken['role'];

    if (role != "Admin" || role.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void checkUserRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role = decodedToken['role'];

    if (role != "User" || role.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }
}
