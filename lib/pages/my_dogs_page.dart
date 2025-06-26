import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/dog.dart';
import '../services/dog-service.dart';
import '../services/dog-image-service.dart';

class MyDogsPage extends StatefulWidget {
  final String userId;

  const MyDogsPage({
    super.key,
    required this.userId,
  });

  @override
  State<MyDogsPage> createState() => _MyDogsPageState();
}

class _MyDogsPageState extends State<MyDogsPage> {
  bool _isLoading = true;
  List<Dog> _dogs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDogs();
  }

  /// Charge les chiens de l'utilisateur
  Future<void> _loadDogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dogs = await DogService.getUserDogs(widget.userId);
      setState(() {
        _dogs = dogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des chiens: $e';
        _isLoading = false;
      });
    }
  }

  /// Formate la date de naissance en format lisible
  String _formatBirthday(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Calcule l'âge approximatif du chien en années et mois
  String _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int years = now.year - birthday.year;
    int months = now.month - birthday.month;
    
    if (now.day < birthday.day) {
      months--;
    }
    
    if (months < 0) {
      years--;
      months += 12;
    }
    
    String result = '';
    if (years > 0) {
      result += '$years an${years > 1 ? 's' : ''}';
    }
    if (months > 0 || years == 0) {
      if (years > 0) result += ' et ';
      result += '$months mois';
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes chiens',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDogs,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Retourner à la page d'accueil pour ajouter un chien
          Navigator.pop(context);
          // Afficher un message pour guider l'utilisateur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisez le bouton + sur la page d\'accueil pour ajouter un chien'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 3),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDogs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_dogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              color: AppColors.accentBrown,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous n\'avez pas encore ajouté de chien',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre premier compagnon en utilisant le bouton +',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un chien'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dogs.length,
      itemBuilder: (context, index) {
        final dog = _dogs[index];
        return _buildDogCard(dog);
      },
    );
  }

  Widget _buildDogCard(Dog dog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du chien avec un placeholder si pas d'image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: dog.photo.isNotEmpty
                  ? DogImageService.buildDogImage(
                      dog.photo,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: AppColors.lightGray,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen),
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        color: AppColors.lightGray,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.lightGray,
                      child: const Center(
                        child: Icon(
                          Icons.pets,
                          size: 40,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom et race
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dog.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dog.breed,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Informations sur l'âge et le sexe
                Row(
                  children: [
                    const Icon(
                      Icons.cake,
                      size: 16,
                      color: AppColors.accentBrown,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatBirthday(dog.birthday)} (${_calculateAge(dog.birthday)})',
                      style: const TextStyle(
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      dog.sex.toLowerCase() == 'male'
                          ? Icons.male
                          : Icons.female,
                      size: 16,
                      color: dog.sex.toLowerCase() == 'male'
                          ? Colors.blue
                          : Colors.pink,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dog.sex.toLowerCase() == 'male' ? 'Mâle' : 'Femelle',
                      style: TextStyle(
                        color: dog.sex.toLowerCase() == 'male'
                            ? Colors.blue
                            : Colors.pink,
                      ),
                    ),
                  ],
                ),
                // Description
                if (dog.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    dog.description,
                    style: const TextStyle(
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
