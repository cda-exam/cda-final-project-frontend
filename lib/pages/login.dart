import 'package:cda_final_project_frontend/pages/sign-up.dart';
import 'package:cda_final_project_frontend/providers/auth-provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      HapticFeedback.lightImpact();

      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Redirection immédiate vers la page d'accueil
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Connexion réussie !'),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final keyboardVisible = MediaQuery
        .of(context)
        .viewInsets
        .bottom > 0;

    return Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Scaffold(
            backgroundColor: AppColors.lightGray,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - MediaQuery
                        .of(context)
                        .padding
                        .top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Header avec logo - Plus petit quand clavier visible
                        SizedBox(height: keyboardVisible ? 20 : 60),

                        if (!keyboardVisible) ...[
                          // Logo principal
                          SizedBox(
                            width: 100,
                            height: 20,
                          ),
                        ],

                        // Titre
                        Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: keyboardVisible ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                            fontFamily: 'Jost',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (!keyboardVisible)
                          Text(
                            'Connectez-vous à votre compte',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.mediumGray,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                        SizedBox(height: keyboardVisible ? 20 : 40),

                        // Formulaire dans un container avec coins arrondis
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Champ Email avec design mobile-first
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: 17,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Adresse email',
                                    labelStyle: TextStyle(
                                      color: AppColors.mediumGray,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(14),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen
                                            .withOpacity(
                                            0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: AppColors.primaryGreen,
                                        size: 22,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.lightGray.withOpacity(
                                        0.5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 24,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryGreen,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir votre email';
                                    }
                                    if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Format d\'email invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Champ Mot de passe
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: 17,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    labelStyle: TextStyle(
                                      color: AppColors.mediumGray,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(14),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen
                                            .withOpacity(
                                            0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outlined,
                                        color: AppColors.primaryGreen,
                                        size: 22,
                                      ),
                                    ),
                                    suffixIcon: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(25),
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _obscurePassword =
                                            !_obscurePassword;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppColors.mediumGray,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.lightGray.withOpacity(
                                        0.5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 24,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryGreen,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir votre mot de passe';
                                    }
                                    if (value.length < 6) {
                                      return 'Minimum 6 caractères requis';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mot de passe oublié - Zone tactile plus grande
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                // Action pour mot de passe oublié
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: AppColors.accentBrown,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Bouton de connexion - Optimisé pour mobile
                        SizedBox(
                          width: double.infinity,
                          height: 56, // Hauteur recommandée pour mobile
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor: AppColors.primaryGreen.withOpacity(
                                  0.3),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                        ),

                        if (!keyboardVisible) ...[
                          const SizedBox(height: 30),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.mediumGray.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Text(
                                  'OU',
                                  style: TextStyle(
                                    color: AppColors.mediumGray,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.mediumGray.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Bouton d'inscription
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupPage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accentBrown,
                                side: BorderSide(
                                    color: AppColors.accentBrown, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Créer un compte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Jost',
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}