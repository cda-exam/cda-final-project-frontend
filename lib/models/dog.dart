import 'dart:convert';

class Dog {
  final String? id;
  final String name;
  final DateTime birthday;
  final String description;
  final String photo;
  final String breed;
  final String sex;

  Dog({
    this.id,
    required this.name,
    required this.birthday,
    required this.description,
    required this.photo,
    required this.breed,
    required this.sex,
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'] is String 
          ? DateTime.parse(json['birthday'])
          : DateTime.fromMillisecondsSinceEpoch(json['birthday']),
      description: json['description'] ?? '',
      photo: json['photo'] ?? '',
      breed: json['breed'] ?? '',
      sex: json['sex'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthday': birthday.toIso8601String(),
      'description': description,
      'photo': photo,
      'breed': breed,
      'sex': sex,
    };
  }

  Dog copyWith({
    String? id,
    String? name,
    DateTime? birthday,
    String? description,
    String? photo,
    String? breed,
    String? sex,
  }) {
    return Dog(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
    );
  }
}
