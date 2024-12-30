import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_canteen_fe/screen/register_screen.dart';
import '../services/auth_service.dart';
import '../Admin/AdminScreen.dart';
import '../User/UserScreen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final AuthService authService = AuthService();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await authService.login(
          usernameController.text.trim(),
          passwordController.text.trim(),
        );

        if (response['status'] == true) {
          final prefs = await SharedPreferences.getInstance();

          // Lưu token và thông tin người dùng
          final token = response['token'];
          final userId = response['userId'];
          final role = response['role'];

          if (token != null && userId != null && role != null) {
            await prefs.setString("jwt_token", token);
            await prefs.setString("user_id", userId);
            await prefs.setString("user_role", role);

            // Điều hướng dựa trên vai trò
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Role không xác định!")),
              );
            }
          } else {
            throw Exception("Thông tin phản hồi từ API không đầy đủ.");
          }
        } else {
          // Hiển thị thông báo lỗi khi đăng nhập sai
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Đăng nhập sai mật khẩu",
                style: TextStyle(color: Colors.white), // Màu chữ trắng
              ),
              backgroundColor: Colors.red, // Màu nền đỏ
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Đăng nhập sai mật khẩu",
              style: TextStyle(color: Colors.white), // Màu chữ trắng
            ),
            backgroundColor: Colors.red, // Màu nền đỏ
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Logo ở góc trên bên trái
          Positioned(
            top: 40,
            left: 20,
            child: Image.asset(
              'assets/images/logo.png', // Đường dẫn logo
              height: 150, // Chiều cao logo
              width: 150, // Chiều rộng logo
            ),
          ),
          // Nội dung chính của màn hình
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 200), // Khoảng cách margin top
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Đăng nhập",
                      style: TextStyle(
                        fontSize: 36,
                        color: Color.fromRGBO(56, 56, 56, .9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Tên người dùng',
                                floatingLabelStyle: TextStyle(color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu',
                                floatingLabelStyle: TextStyle(color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: "Chưa có tài khoản? ", // Phần văn bản thông thường
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16, // Tăng kích thước font
                        ),
                        children: [
                          TextSpan(
                            text: "Đăng ký ngay", // Phần văn bản có thể nhấn
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Tăng kích thước font
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Điều hướng tới trang đăng ký
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center, // Căn giữa dòng chữ
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}