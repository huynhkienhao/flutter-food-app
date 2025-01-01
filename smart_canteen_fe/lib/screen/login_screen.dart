import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth_service.dart';
import '../Admin/AdminScreen.dart';
import '../User/UserScreen.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();


  bool rememberMe = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLoginInfo();
  }

  Future<void> _loadSavedLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRememberMe = prefs.getBool('remember_me') ?? false;
    if (savedRememberMe) {
      setState(() {
        rememberMe = true;
        usernameController.text = prefs.getString('saved_username') ?? '';
        passwordController.text = prefs.getString('saved_password') ?? '';
      });
    }
  }

  Future<void> _saveLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_username', usernameController.text);
      await prefs.setString('saved_password', passwordController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await authService.login(
        usernameController.text,
        passwordController.text,
      );

      if (response['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        final token = response['token'];
        final userId = response['userId'];
        final role = response['role'];

        if (token != null && userId != null && role != null) {
          await prefs.setString("jwt_token", token);
          await prefs.setString("user_id", userId);
          await prefs.setString("user_role", role);
          await _saveLoginInfo();

          if (role == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          } else if (role == 'User') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          } else {
            throw Exception("Không xác định được vai trò người dùng.");
          }
        } else {
          throw Exception("Thiếu thông tin đăng nhập quan trọng.");
        }
      } else {
        _showSnackBar("Đăng nhập thất bại: ${response['message']}");
      }
    } catch (error) {
      _showSnackBar("Lỗi: ${error.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _launchUrl(String url, String errorMessage) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception(errorMessage);
      }
    } catch (e) {
      _showSnackBar("Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                  SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('TÀI KHOẢN'),
                        _buildTextField(
                          controller: usernameController,
                          hintText: 'Nhập tài khoản',
                        ),
                        SizedBox(height: 20),
                        _buildLabel('MẬT KHẨU'),
                        _buildPasswordField(),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value!;
                                });
                              },
                            ),
                            Text('Ghi nhớ đăng nhập'),
                          ],
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildHelpLink(),
                        SizedBox(height: 120),
                        _buildSocialLinks(),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Nhập mật khẩu',
        suffixIcon: IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildHelpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Đăng nhập không được? ',
          style: TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: 'Xem hướng dẫn tại đây',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(
                  'https://qlcntt.hutech.edu.vn/chi-tiet-ho-tro/1007011',
                  'Không thể mở liên kết.',
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.facebook, color: Colors.blue, size: 40),
          onPressed: () => _launchUrl(
            'https://www.facebook.com/hutechuniversity?mibextid=ZbWKwL',
            'Không thể mở liên kết Facebook.',
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Image.asset('assets/images/youtube_logo.webp', width: 50, height: 50),
          onPressed: () => _launchUrl(
            'https://youtube.com/@hutechuniversity?si=fB-i1qlYOKLkwo43',
            'Không thể mở liên kết YouTube.',
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: ClipOval(
            child: Image.asset(
              'assets/images/instagram_logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          onPressed: () => _launchUrl(
            'https://www.instagram.com',
            'Không thể mở liên kết Instagram.',
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: Text(
          'e-HUTECH ©2025 · Phiên bản 3.4.9 - a402',
          style: TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
