import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Squircle Logo Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: size * 0.2,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.15),
          child: CustomPaint(
            painter: LogoPainter(),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Text(
            "Traveless",
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: FontWeight.w800, // Thick bold matching typeface
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the shield shape in gradient cyan/blue
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF0EA5E9), // Cyber Cyan
        const Color(0xFF0560E8), // Primary Blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);

    final shieldPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    final shieldPath = Path();
    // Start at top-middle
    shieldPath.moveTo(size.width * 0.5, size.height * 0.15);
    // Top right curve
    shieldPath.quadraticBezierTo(
      size.width * 0.85, size.height * 0.15,
      size.width * 0.9, size.height * 0.35,
    );
    // Right side down to bottom point
    shieldPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.75,
      size.width * 0.5, size.height * 0.95,
    );
    // Left side down to bottom point
    shieldPath.quadraticBezierTo(
      size.width * 0.2, size.height * 0.75,
      size.width * 0.1, size.height * 0.35,
    );
    // Top left curve
    shieldPath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.15,
      size.width * 0.5, size.height * 0.15,
    );
    shieldPath.close();
    canvas.drawPath(shieldPath, shieldPaint);

    // 2. Draw the white border/background cutout for the star
    final starBackPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final starBackPath = Path();
    starBackPath.moveTo(size.width * 0.5, size.height * 0.05); // Top point
    starBackPath.quadraticBezierTo(size.width * 0.52, size.height * 0.32, size.width * 0.82, size.height * 0.35); // Right point
    starBackPath.quadraticBezierTo(size.width * 0.52, size.height * 0.38, size.width * 0.5, size.height * 0.70); // Bottom point
    starBackPath.quadraticBezierTo(size.width * 0.48, size.height * 0.38, size.width * 0.18, size.height * 0.35); // Left point
    starBackPath.quadraticBezierTo(size.width * 0.48, size.height * 0.32, size.width * 0.5, size.height * 0.05);
    starBackPath.close();
    canvas.drawPath(starBackPath, starBackPaint);

    // 3. Draw the inner star in solid vibrant blue gradient
    final starGradient = LinearGradient(
      colors: [
        const Color(0xFF2563EB), // Darker Blue
        const Color(0xFF3B82F6), // Bright Blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);

    final starPaint = Paint()
      ..shader = starGradient
      ..style = PaintingStyle.fill;

    final starPath = Path();
    starPath.moveTo(size.width * 0.5, size.height * 0.08); // Top point
    starPath.quadraticBezierTo(size.width * 0.515, size.height * 0.33, size.width * 0.78, size.height * 0.35); // Right
    starPath.quadraticBezierTo(size.width * 0.515, size.height * 0.37, size.width * 0.5, size.height * 0.66); // Bottom
    starPath.quadraticBezierTo(size.width * 0.485, size.height * 0.37, size.width * 0.22, size.height * 0.35); // Left
    starPath.quadraticBezierTo(size.width * 0.485, size.height * 0.33, size.width * 0.5, size.height * 0.08);
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
