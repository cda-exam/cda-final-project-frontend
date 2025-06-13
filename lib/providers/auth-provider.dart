import 'package:cda_final_project_frontend/models/user.dart';
import 'package:cda_final_project_frontend/services/api-service.dart';
import 'package:cda_final_project_frontend/services/auth-service.dart';
import 'package:cda_final_project_frontend/states/auth-state.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial();

  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners(); // Déclenche le rebuild des widgets
  }

  AuthState get state => _state;
  User? get user => _state.user;
  String? get token => _state.token;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get error => _state.error;

  // INITIALISATION AU DÉMARRAGE
  Future<void> initialize() async {
    _updateState(AuthState.loading());

    try {
      final authData = await _authService.getStoredAuthData();

      if (authData.token != null && authData.user != null) {
        // Vérifier si le token est encore valide
        final isValid = await _authService.validateToken(authData.token!);

        if (isValid) {
          _updateState(AuthState.authenticated(
            user: authData.user!,
            token: authData.token!,
          ));
          ApiService.setAuthToken(authData.token!);
          return;
        }
      }

      // Token invalide ou inexistant
      await _authService.clearAuthData();
      _updateState(AuthState.unauthenticated());
    } catch (e) {
      _updateState(AuthState.error('Erreur d\'initialisation'));
    }
  }

  // CONNEXION AVEC RÉCUPÉRATION DU PROFIL
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _updateState(AuthState.loading());

    try {
      final result = await _authService.loginComplete(
        username: username,
        password: password,
      );

      if (result.isSuccess) {
        // Sauvegarder localement
        await _authService.saveAuthData(
          token: result.token!,
          user: result.user!,
        );

        // Configurer le token globalement
        ApiService.setAuthToken(result.token!);

        _updateState(AuthState.authenticated(
          user: result.user!,
          token: result.token!,
        ));

        return true;
      } else {
        _updateState(AuthState.error(result.error!));
        return false;
      }
    } catch (e) {
      _updateState(AuthState.error('Erreur de connexion inattendue'));
      return false;
    }
  }

  // RAFRAÎCHIR LE PROFIL UTILISATEUR
  Future<void> refreshUserProfile() async {
    if (_state.token != null) {
      try {
        final user = await _authService.fetchUserProfile(_state.token!);

        // Mettre à jour l'état avec les nouvelles données
        _updateState(_state.copyWith(user: user));

        // Sauvegarder localement
        await _authService.saveAuthData(
          token: _state.token!,
          user: user,
        );
      } catch (e) {
        print('Erreur lors du rafraîchissement du profil: $e');
      }
    }
  }

  // DÉCONNEXION
  Future<void> logout() async {
    _updateState(AuthState.loading());

    try {
      // Si vous avez un endpoint de logout côté backend
      if (_state.token != null) {
        try {
          await ApiService.post('/logout', {});
        } catch (e) {
          // Continuer même si l'appel échoue
          print('Erreur lors de la déconnexion côté serveur: $e');
        }
      }
    } finally {
      await _authService.clearAuthData();
      _updateState(AuthState.unauthenticated());
    }
  }

  // VÉRIFIER LA VALIDITÉ DU TOKEN
  Future<bool> checkTokenValidity() async {
    if (_state.token == null) return false;

    try {
      final isValid = await _authService.validateToken(_state.token!);
      if (!isValid) {
        await logout();
      }
      return isValid;
    } catch (e) {
      await logout();
      return false;
    }
  }

  void clearError() {
    if (_state.hasError) {
      _updateState(_state.copyWith(
        status: AuthStatus.unauthenticated,
        error: null,
      ));
    }
  }
}