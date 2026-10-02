import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../utils/context_x.dart';

class RestaurantMarker extends StatelessWidget {
  const RestaurantMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.sufra.contrastButton,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Icon(Icons.storefront_rounded, size: 20, color: context.sufra.onContrastButton),
    );
  }
}

class HomeMarker extends StatelessWidget {
  const HomeMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.saffron,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: const Icon(Icons.home_rounded, size: 20, color: AppColors.ink),
    );
  }
}

/// The rider, with a soft pulse so the eye finds it.
class RiderMarker extends StatelessWidget {
  const RiderMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(color: AppColors.coral.withValues(alpha: 0.25), shape: BoxShape.circle),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.15, 1.15), duration: 1400.ms)
            .fadeOut(begin: 0.9, duration: 1400.ms),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.ember,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.surface, width: 3),
          ),
          child: const Icon(Icons.delivery_dining_rounded, size: 22, color: Colors.white),
        ),
      ],
    );
  }
}
