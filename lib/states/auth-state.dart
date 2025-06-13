// lib/models/auth_state.dart
import 'package:cda_final_project_frontend/models/user.dart';

enum AuthStatus {
  initial,        // État initial, pas encore vérifié
  loading,        // En cours de vérification/connexion
  authenticated,  // Connecté et valide
  unauthenticated, // Non connecté
  error,          // Erreur d'authentification
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? error;
  final bool isBiometricEnabled;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.error,
    this.isBiometricEnabled = false,
  });

  // Factory constructors pour créer des états spécifiques
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  factory AuthState.authenticated({
    required User user,
    required String token,
    bool isBiometricEnabled = false,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
      isBiometricEnabled: isBiometricEnabled,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String error) {
    return AuthState(
      status: AuthStatus.error,
      error: error,
    );
  }

  // Getters utiles pour vérifier l'état
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
  bool get isInitial => status == AuthStatus.initial;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  // Méthode copyWith pour créer une nouvelle instance avec des modifications
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? error,
    bool? isBiometricEnabled,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  // Méthode toString pour le debugging
  @override
  String toString() {
    return 'AuthState('
        'status: $status, '
        'user: ${user?.email ?? 'null'}, '
        'hasToken: ${token != null}, '
        'error: $error, '
        'isBiometricEnabled: $isBiometricEnabled'
        ')';
  }

  // Opérateur == pour comparer les états
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.token == token &&
        other.error == error &&
        other.isBiometricEnabled == isBiometricEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      user,
      token,
      error,
      isBiometricEnabled,
    );
  }
}