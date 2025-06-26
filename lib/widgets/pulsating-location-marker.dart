import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Widget de marqueur de position avec effet de pulsation
class PulsatingLocationMarker extends StatefulWidget {
  final double size;
  final Color color;

  const PulsatingLocationMarker({
    super.key,
    this.size = 50.0,
    this.color = AppColors.primaryGreen,
  });

  @override
  State<PulsatingLocationMarker> createState() => _PulsatingLocationMarkerState();
}

class _PulsatingLocationMarkerState extends State<PulsatingLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Démarrer l'animation immédiatement et la répéter indéfiniment
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercle extérieur pulsant
            Container(
              width: widget.size * (0.7 + _animation.value * 0.3),
              height: widget.size * (0.7 + _animation.value * 0.3),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2 * (1 - _animation.value)),
                shape: BoxShape.circle,
              ),
            ),
            
            // Cercle intermédiaire
            Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            
            // Point central
            Container(
              width: widget.size * 0.35,
              height: widget.size * 0.35,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
