class RegisterModel {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String? role;

  RegisterModel({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.role,
  });

  // Chuyển từ JSON sang RegistrationModel
  // factory RegisterModel.fromJson(Map<String, dynamic> json) {
  //   return RegisterModel(
  //     username: json['username'] ?? '',
  //     email: json['email'] ?? '',
  //     password: json['password'] ?? '',
  //     fullName: json['fullName'] ?? '',
  //     role: json['role'], // Role có thể null
  //   );
  // }

  // Chuyển từ RegistrationModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role, // Role có thể null
    };
  }
}
