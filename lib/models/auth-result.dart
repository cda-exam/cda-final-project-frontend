import 'package:cda_final_project_frontend/models/user.dart';

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.token,
    this.error,
  });

  factory AuthResult.success({
    required User user,
    required String token,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}