class Organizations {
  final String id;
  final String userName;
  final String email;
  final String password;
  final String imageUrl;
  final String role;

  Organizations({
    required this.id,
    required this.userName,
    required this.email,
    required this.password,
    required this.imageUrl,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': userName,
        'email': email,
        'password': password,
        'imageUrl' : imageUrl,
        'role' :role,
      };

  static Organizations fromJson(Map<String, dynamic> json) => Organizations(
        id: json['id'],
        imageUrl: json['imageUrl'],
        email: json['email'],
        password: json['password'],
        role: json['role'],
        userName: json['username']
      );
}
