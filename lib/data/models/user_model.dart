class UserModel {
  final String userId;
  final String username;
  final String email;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(userId: $userId, username: $username, email: $email)';
}
