class LoginModel {
  final String token;
  final String role;
  final String userId;
  final String email;
  final String name;

  LoginModel({
    required this.token,
    required this.role,
    required this.userId,
    required this.email,
    required this.name,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'],
      role: json['user']['role']['type'],
      userId: json['user']['id'],
      email: json['user']['email'],
      name: json['user']['name'],
    );
  }
}
