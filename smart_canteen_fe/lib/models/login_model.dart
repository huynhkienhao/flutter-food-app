class LoginModel {
  final String username;
  final String password;

  LoginModel({
    required this.username,
    required this.password,
  });

  // factory LoginModel.fromJson(Map<String, dynamic> json) {
  //   return LoginModel(
  //     username: json['username'] ?? '',
  //     password: json['password'] ?? '',
  //   );
  // }

  // Chuyển từ LoginModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
