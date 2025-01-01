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
            throw Exception("Không xác định được role");
          }
        } else {
          throw Exception("Token, UserId hoặc Role không tồn tại");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response['message']}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _launchGuideUrl() async {
    const guideUrl = 'https://qlcntt.hutech.edu.vn/chi-tiet-ho-tro/1007011';
    try {
      final Uri url = Uri.parse(guideUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Không thể mở liên kết.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _launchFacebookUrl() async {
    const facebookUrl = 'https://www.facebook.com/hutechuniversity?mibextid=ZbWKwL';
    try {
      final Uri url = Uri.parse(facebookUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Không thể mở liên kết Facebook.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _launchYouTubeUrl() async {
    const youtubeUrl = 'https://youtube.com/@hutechuniversity?si=fB-i1qlYOKLkwo43';
    try {
      final Uri url = Uri.parse(youtubeUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Không thể mở liên kết YouTube.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _launchInstagramUrl() async {
    const instagramUrl = 'https://www.instagram.com/hutechuniversity?igsh=OHIwbmE5Y3lwamxq';
    try {
      final Uri url = Uri.parse(instagramUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Không thể mở liên kết Instagram.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
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
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TÀI KHOẢN',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tài khoản',
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'MẬT KHẨU',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu',
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            border: const UnderlineInputBorder(),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                            const Text('Ghi nhớ đăng nhập'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Đăng nhập không được? ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Xem hướng dẫn tại đây',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _launchGuideUrl,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10), // Thêm khoảng cách dưới
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.facebook, color: Colors.blue, size: 40),
                  onPressed: _launchFacebookUrl, // Sử dụng hàm _launchFacebookUrl
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/images/youtube_logo.webp',
                    width: 50, height: 50,
                  ),
                  onPressed: _launchYouTubeUrl, // Sử dụng hàm _launchYouTubeUrl
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Container(
                    width: 50, // Kích thước của logo
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Tạo hình tròn
                      border: Border.all(
                        color: Colors.white, // Màu viền (có thể thay đổi)
                        width: 2, // Độ dày của viền
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/instagram_logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover, // Đảm bảo logo không bị biến dạng
                      ),
                    ),
                  ),
                  onPressed: _launchInstagramUrl, // Sử dụng hàm _launchInstagramUrl
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 20), // Thêm margin dưới cho dòng chữ
            child: Text(
              'e-HUTECH ©2025 · Phiên bản 3.4.9 - a402',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
