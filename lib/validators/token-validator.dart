import 'dart:async';

import 'package:cda_final_project_frontend/providers/auth-provider.dart';

class TokenValidator {
  static Timer? _timer;

  static void startPeriodicValidation(AuthProvider authProvider) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (authProvider.isAuthenticated) {
        authProvider.checkTokenValidity();
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}