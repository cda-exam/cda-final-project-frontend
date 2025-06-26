import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String? _authToken;
  static const String _baseUrl = kDebugMode
      ? 'http://192.168.1.170:8080'  // Adresse spéciale qui pointe vers l'hôte depuis l'émulateur Android
      : 'https://votre-api-production.com';

  static const Duration _timeout = Duration(seconds: 30);

  /// Configurer le token d'authentification
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Supprimer le token d'authentification
  static void clearAuthToken() {
    _authToken = null;
  }

  // Headers par défaut
  static Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Ajouter le token d'authentification si disponible
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    // Ajouter les headers supplémentaires
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // Méthode générique pour les requêtes GET
  static Future<dynamic> get(
      String endpoint, {
        Map<String, String>? queryParams,
        String? token,
      }) async {
    try {
      Uri url = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams);
      }

      if (kDebugMode) {
        print('API GET: $url');
      }

      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode générique pour les requêtes GET qui renvoient un tableau JSON
  static Future<List<dynamic>> getList(
      String endpoint, {
        Map<String, String>? queryParams,
        String? token,
      }) async {
    try {
      Uri url = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams);
      }

      if (kDebugMode) {
        print('API GET (List): $url');
      }

      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(_timeout);

      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode générique pour les requêtes POST
  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');

      if (kDebugMode) {
        print('API POST: $url');
        print('Data: ${jsonEncode(data)}');
      }

      final response = await http
          .post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode pour upload de fichiers (multipart)
  static Future<dynamic> postMultipart(
      String endpoint,
      Map<String, dynamic> data,
      Map<String, File> files, {
        String? token,
      }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');

      if (kDebugMode) {
        print('API POST Multipart: $url');
        print('Data: $data');
        print('Files: ${files.keys.toList()}');
      }

      var request = http.MultipartRequest('POST', url);

      // Ajouter les headers
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Ajouter les données texte
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Ajouter les fichiers
      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode PUT
  static Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');

      if (kDebugMode) {
        print('API PUT: $url');
        print('Data: ${jsonEncode(data)}');
      }

      final response = await http
          .put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode DELETE
  static Future<dynamic> delete(
      String endpoint, {
        String? token,
      }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');

      if (kDebugMode) {
        print('API DELETE: $url');
      }

      final response = await http
          .delete(url, headers: _getHeaders())
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gestion des réponses
  static dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('API Response [${response.statusCode}]: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }

      try {
        // Décoder la réponse JSON (peut être un objet ou un tableau)
        final dynamic decodedResponse = jsonDecode(response.body);
        return decodedResponse;
      } catch (e) {
        throw ApiException(
          message: 'Erreur de format de réponse',
          statusCode: response.statusCode,
        );
      }
    } else {
      Map<String, dynamic> errorBody = {};
      try {
        errorBody = jsonDecode(response.body);
      } catch (e) {
        errorBody = {'message': 'Erreur serveur'};
      }

      throw ApiException(
        message: errorBody['message'] ?? 'Erreur inconnue',
        statusCode: response.statusCode,
        errors: errorBody['errors'],
      );
    }
  }

  // Gestion des réponses pour les tableaux JSON
  static List<dynamic> _handleListResponse(http.Response response) {
    if (kDebugMode) {
      print('API Response [${response.statusCode}]: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }

      try {
        // Décoder la réponse JSON comme un tableau
        final List<dynamic> decodedResponse = jsonDecode(response.body);
        return decodedResponse;
      } catch (e) {
        throw ApiException(
          message: 'Erreur de format de réponse: la réponse n\'est pas un tableau JSON valide',
          statusCode: response.statusCode,
        );
      }
    } else {
      Map<String, dynamic> errorBody = {};
      try {
        errorBody = jsonDecode(response.body);
      } catch (e) {
        errorBody = {'message': 'Erreur serveur'};
      }

      throw ApiException(
        message: errorBody['message'] ?? 'Erreur inconnue',
        statusCode: response.statusCode,
        errors: errorBody['errors'],
      );
    }
  }

  // Gestion des erreurs
  static ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is SocketException) {
      return ApiException(
        message: 'Pas de connexion internet',
        statusCode: 0,
      );
    }

    if (error is http.ClientException) {
      return ApiException(
        message: 'Erreur de connexion au serveur',
        statusCode: 0,
      );
    }

    if (error.toString().contains('TimeoutException')) {
      return ApiException(
        message: 'Délai d\'attente dépassé',
        statusCode: 0,
      );
    }

    return ApiException(
      message: 'Erreur inattendue: ${error.toString()}',
      statusCode: 0,
    );
  }

  // Getter pour l'URL de base (utile pour d'autres services)
  static String get baseUrl => _baseUrl;
}

// Classe d'exception personnalisée
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;

  // Méthodes utilitaires pour identifier le type d'erreur
  bool get isValidationError => statusCode == 400 && errors != null;
  bool get isConflictError => statusCode == 409;
  bool get isServerError => statusCode >= 500;
  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
}