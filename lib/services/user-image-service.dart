import 'package:cda_final_project_frontend/services/api-service.dart';

class UserImageService {
  static const String baseUrl = '/user-images';

  /// Récupère l'URL complète de l'image de profil à partir de son ID
  static String getProfileImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return ''; // Retourne une chaîne vide si pas d'ID d'image
    }
    
    // Construit l'URL complète pour l'image
    return '${ApiService.baseUrl}$baseUrl/$imageId';
  }
  
  /// Vérifie si l'utilisateur a une image de profil valide
  static bool hasProfileImage(String? imageId) {
    return imageId != null && imageId.isNotEmpty;
  }
}
