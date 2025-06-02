import 'package:cda_final_project_frontend/widgets/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF2F5233,
          const <int, Color>{
            50: Color(0xFFE8ECE9),
            100: Color(0xFFC5D0C8),
            200: Color(0xFF9FB1A3),
            300: Color(0xFF79927E),
            400: Color(0xFF5C7A63),
            500: Color(0xFF2F5233), // Votre couleur principale
            600: Color(0xFF2A4A2E),
            700: Color(0xFF244027),
            800: Color(0xFF1E3620),
            900: Color(0xFF152614),
          },
        ),
        // Configuration de la police Jost comme police par défaut
        fontFamily: 'Jost',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Option 1: Définir directement la page de connexion comme home
      home: const LoginPage(),

      // Option 2: Utiliser des routes nommées (recommandé pour des apps plus complexes)
      /*
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(), // Votre page principale après connexion
        // Ajoutez d'autres routes selon vos besoins
      },
      */
    );
  }
}

// Exemple d'une page d'accueil après connexion
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: const Color(0xFF2F5233),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Retour à la page de connexion
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 100,
              color: Color(0xFF2F5233),
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenue sur votre application !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF373737),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Vous êtes maintenant connecté.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF989898),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative : Classe pour gérer l'état de connexion
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLoggedIn = false; // Vous pouvez gérer cela avec SharedPreferences ou un state manager

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Vérifiez si l'utilisateur est déjà connecté
    // Par exemple avec SharedPreferences :
    /*
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      isLoggedIn = loggedIn;
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    // Retourne la page appropriée selon l'état de connexion
    return isLoggedIn ? const HomePage() : const LoginPage();
  }
}