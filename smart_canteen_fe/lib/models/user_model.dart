class UserModel {
  final String id;
  final String email;
  final String? userName;
  final List<String>? role;

  UserModel({
    required this.id,
    required this.email,
    this.userName,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        email: json['email'],
        userName: json['userName'],
        role: json['roles'] != null ? List<String>.from(json['roles']) : null,
    );
  }
}