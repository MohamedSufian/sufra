import 'package:material_ui/material_ui.dart';

/// Colors for one illustrated dish. Stands in for real food photos until we have them.
@immutable
class PlatePalette {
  const PlatePalette({
    required this.food,
    required this.piece,
    required this.garnish,
    required this.backdropLight,
    required this.backdropDark,
  });

  final Color food;
  final Color piece;
  final Color garnish;
  final Color backdropLight;
  final Color backdropDark;

  static const all = [
    // grill
    PlatePalette(food: Color(0xFFC9692E), piece: Color(0xFF7A3415), garnish: Color(0xFF3F8F4E), backdropLight: Color(0xFFFFE7DE), backdropDark: Color(0xFF2A1A16)),
    // knafeh
    PlatePalette(food: Color(0xFFE2B04A), piece: Color(0xFF9C4A1C), garnish: Color(0xFF7DAF5A), backdropLight: Color(0xFFFFF1D6), backdropDark: Color(0xFF2A2416)),
    // falafel
    PlatePalette(food: Color(0xFF8A5A2B), piece: Color(0xFF5B3A1A), garnish: Color(0xFF4FB063), backdropLight: Color(0xFFE8F3E6), backdropDark: Color(0xFF172419)),
    // seafood
    PlatePalette(food: Color(0xFFE07A5F), piece: Color(0xFFF2CC8F), garnish: Color(0xFF3F8F4E), backdropLight: Color(0xFFE3F1F5), backdropDark: Color(0xFF15212A)),
    // pizza
    PlatePalette(food: Color(0xFFE9A23B), piece: Color(0xFFC0392B), garnish: Color(0xFF3F8F4E), backdropLight: Color(0xFFFFEBD9), backdropDark: Color(0xFF2A1F16)),
    // shawarma
    PlatePalette(food: Color(0xFFD9A05B), piece: Color(0xFF9C5A2A), garnish: Color(0xFF3F8F4E), backdropLight: Color(0xFFFFF0E3), backdropDark: Color(0xFF261C17)),
  ];

  static PlatePalette of(int index) => all[index % all.length];
}

/// A plate seen from above: white rim, food, a few pieces and garnish.
class PlateArt extends StatelessWidget {
  const PlateArt({super.key, required this.palette, this.size = 120});

  final PlatePalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final food = size * 0.74;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFFF5F2EE) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.45) : palette.piece.withValues(alpha: 0.18),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.11),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: food,
        height: food,
        decoration: BoxDecoration(shape: BoxShape.circle, color: palette.food),
        child: Stack(
          children: [
            _blob(left: 0.22, top: 0.2, w: 0.3, h: 0.14, color: palette.piece, food: food),
            _blob(left: 0.42, top: 0.48, w: 0.34, h: 0.14, color: palette.piece, food: food),
            _blob(left: 0.62, top: 0.2, w: 0.16, h: 0.16, color: palette.garnish, food: food),
            _blob(left: 0.3, top: 0.7, w: 0.14, h: 0.14, color: palette.garnish, food: food),
          ],
        ),
      ),
    );
  }

  Widget _blob({
    required double left,
    required double top,
    required double w,
    required double h,
    required Color color,
    required double food,
  }) {
    return Positioned(
      left: food * left,
      top: food * top,
      child: Container(
        width: food * w,
        height: food * h,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(food)),
      ),
    );
  }
}
