import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Widget d'overlay de chargement réutilisable
class LoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const LoadingOverlay({
    super.key,
    required this.isVisible,
    this.message = 'Chargement...',
    this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(retryLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}