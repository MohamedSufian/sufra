import 'package:material_ui/material_ui.dart';

/// The Sufra mark: a location pin holding a steaming bowl.
/// Same geometry as `tool/generate_icons.dart` (64×64 design space).
class SufraLogo extends StatelessWidget {
  const SufraLogo({super.key, this.size = 64, required this.color, this.cutColor});

  final double size;
  final Color color;

  /// Color of the bowl and steam. null → see-through.
  final Color? cutColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter(color, cutColor)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.color, this.cutColor);

  final Color color;
  final Color? cutColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.save();
    canvas.scale(s);

    final pin = Path()
      ..moveTo(32, 4)
      ..cubicTo(19.3, 4, 9, 14.1, 9, 26.6)
      ..cubicTo(9, 43, 32, 60, 32, 60)
      ..cubicTo(32, 60, 55, 43, 55, 26.6)
      ..cubicTo(55, 14.1, 44.7, 4, 32, 4)
      ..close();
    final bowl = Path()
      ..moveTo(19, 27)
      ..lineTo(45, 27)
      ..arcToPoint(const Offset(19, 27), radius: const Radius.circular(13))
      ..close();
    Path steam(double x) => Path()
      ..moveTo(x, 12)
      ..cubicTo(x - 2.5, 14.5, x + 2.5, 16.5, x, 20);

    final see = cutColor == null;
    if (see) canvas.saveLayer(Offset.zero & const Size(64, 64), Paint());
    canvas.drawPath(pin, Paint()..color = color);
    final cut = Paint()
      ..color = cutColor ?? Colors.black
      ..blendMode = see ? BlendMode.clear : BlendMode.srcOver;
    canvas.drawPath(bowl, cut);
    final stroke = Paint()
      ..color = cut.color
      ..blendMode = cut.blendMode
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(steam(27), stroke);
    canvas.drawPath(steam(37), stroke);
    if (see) canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.color != color || old.cutColor != cutColor;
}
