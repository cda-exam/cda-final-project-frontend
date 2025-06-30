import 'package:intl/intl.dart';

/// Modèle représentant une promenade
class Walk {
  final int? id;
  final DateTime date;
  final int duration; // en minutes
  final int participantsMax;
  final String description;
  final String location;
  
  Walk({
    this.id,
    required this.date,
    required this.duration,
    required this.participantsMax,
    required this.description,
    required this.location,
  });
  
  /// Crée une instance de Walk à partir d'un objet JSON
  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
      id: json['id'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      participantsMax: json['participantsMax'],
      description: json['description'],
      location: json['location'],
    );
  }
  
  /// Convertit l'instance en objet JSON
  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    return {
      'id': id,
      'date': formatter.format(date),
      'duration': duration,
      'participantsMax': participantsMax,
      'description': description,
      'location': location,
    };
  }
}
