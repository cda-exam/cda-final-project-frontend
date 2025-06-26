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
      birthday: _parseBirthday(json['birthday']),
      description: json['description'] ?? '',
      photo: json['photo'] ?? '',
      breed: json['breed'] ?? '',
      sex: json['sex'] ?? '',
    );
  }

  // Méthode pour analyser différents formats de date
  static DateTime _parseBirthday(dynamic birthday) {
    if (birthday == null) {
      return DateTime.now(); // Date par défaut
    }
    
    // Si c'est déjà un DateTime
    if (birthday is DateTime) {
      return birthday;
    }
    
    // Si c'est une chaîne au format ISO (YYYY-MM-DD)
    if (birthday is String) {
      try {
        return DateTime.parse(birthday);
      } catch (e) {
        print('Erreur lors du parsing de la date: $e');
        return DateTime.now();
      }
    }
    
    // Si c'est un timestamp en millisecondes
    if (birthday is int) {
      return DateTime.fromMillisecondsSinceEpoch(birthday);
    }
    
    // Par défaut
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    // Format la date en timestamp (millisecondes depuis l'époque)
    // Ce format est compatible avec java.util.Date
    return {
      'name': name,
      'birthday': birthday.millisecondsSinceEpoch,
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
