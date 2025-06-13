class User {
  final String id;
  final String email;
  final String nickname;
  final String? city;
  final String? description;
  final String? profilePicture;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.city,
    this.description,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      city: json['city'] ?? '',
      description: json['description'] ?? '',
      profilePicture: json['profilePicture'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'city': city ?? '',
      'description': description ?? '',
      'profilePicture': profilePicture ?? '',
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? city,
    String? description,
    String? profilePicture,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      city: city ?? this.city,
      description: description ?? this.description,
      profilePicture: profilePicture ?? this.profilePicture
    );
  }
}