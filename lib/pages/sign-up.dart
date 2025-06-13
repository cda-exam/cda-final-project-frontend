import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sign-up-service.dart';
import '../services/api-service.dart';
import 'email-verification.dart';
import '../constants/colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _pseudoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _handleSignup() async {
    if (!_validateForm()) {
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SignUpService.signup(
        nickname: _pseudoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
      );

      setState(() {
        _isLoading = false;
      });

      // Inscription réussie - redirection vers vérification email
      _showSuccessMessage(response['message'] ?? 'Code de vérification envoyé !');

      // Navigation vers la page de vérification
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(
              email: _emailController.text.trim(),
              nickname: _pseudoController.text.trim(),
            ),
          ),
        );
      }

    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Gestion spécifique des erreurs d'authentification
      if (e.isValidationError && e.errors != null) {
        _showValidationErrors(e.errors!);
      } else {
        _showErrorMessage(SignUpService.getErrorMessage(e));
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showErrorMessage('Une erreur inattendue s\'est produite');
      debugPrint('Erreur inscription: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showValidationErrors(Map<String, dynamic> errors) {
    String errorMessage = '';
    errors.forEach((field, messages) {
      if (messages is List) {
        errorMessage += '${messages.join(', ')}\n';
      } else {
        errorMessage += '$messages\n';
      }
    });
    _showErrorMessage(errorMessage.trim());
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    bool showToggle = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.mediumGray.withOpacity(0.7)),
            prefixIcon: Icon(icon, color: AppColors.mediumGray),
            suffixIcon: showToggle
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: AppColors.mediumGray,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
            filled: true,
            fillColor: AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez notre communauté dès maintenant',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 40),

                // Formulaire
                Column(
                  children: [
                    // Pseudo
                    _buildTextField(
                      controller: _pseudoController,
                      label: 'Pseudo',
                      hint: 'Votre nom d\'utilisateur',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le pseudo est requis';
                        }
                        if (value.trim().length < 3) {
                          return 'Le pseudo doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'votre@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'email est requis';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Veuillez saisir un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mot de passe
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      hint: 'Votre mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      showToggle: true,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le mot de passe est requis';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirmation mot de passe
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmer le mot de passe',
                      hint: 'Confirmer votre mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      showToggle: true,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La confirmation est requise';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ville (optionnel)
                    _buildTextField(
                      controller: _cityController,
                      label: 'Ville (optionnel)',
                      hint: 'Votre ville',
                      icon: Icons.location_on_outlined,
                      validator: (value) => null, // Optionnel
                    ),
                    const SizedBox(height: 30),

                    // Bouton de création de compte
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Créer mon compte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lien de connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            color: AppColors.mediumGray,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}