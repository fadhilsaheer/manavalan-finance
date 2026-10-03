import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Localized pink/violet light, fading into a neutral surface as in the reference.
class BalanceGlow extends StatelessWidget {
  final Widget child;
  final bool immersive;
  const BalanceGlow({super.key, required this.child, this.immersive = false});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: CustomPaint(painter: _GlowPainter(immersive), child: child),
  );
}

class _GlowPainter extends CustomPainter {
  final bool immersive;
  _GlowPainter(this.immersive);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    void glow(double x, double y, double radius, Color color) {
      final scaleY = immersive ? 1.0 : size.height / size.width * 1.8;
      canvas.save();
      canvas.scale(1, scaleY);
      final center = Offset(size.width * x, size.height * y / scaleY);
      final r = size.width * radius;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            r,
            [color, color.withValues(alpha: 0)],
            [0, 1],
          ),
      );
      canvas.restore();
    }

    if (immersive) {
      glow(.80, .18, 1.4, const Color(0xffff63d5));
      glow(-.12, .38, 1.05, const Color(0xff8f4bc9));
      glow(-.04, -.01, .67, const Color(0xff87c9ed));
      var y = 0.0;
      for (var row = 0; row < 18; row++) {
        final t = row / 17;
        final step = 40 - 25 * t;
        final side = 29 - 23 * t;
        for (
          var x = -step + (row.isOdd ? step / 2 : 0);
          x < size.width + step;
          x += step
        ) {
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(.7854);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: side, height: side),
              Radius.circular(side * .2),
            ),
            Paint()..color = Colors.white.withValues(alpha: .20 * (1 - t)),
          );
          if (row < 5) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: Offset.zero,
                  width: side * 1.65,
                  height: side * 1.65,
                ),
                const Radius.circular(5),
              ),
              Paint()
                ..color = const Color(0xff8856b5).withValues(alpha: .07)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3,
            );
          }
          canvas.restore();
        }
        y += step;
      }
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, size.height * .4),
            Offset(0, size.height * .8),
            [Colors.white.withValues(alpha: 0), Colors.white],
          ),
      );
    } else {
      glow(.32, -.20, .52, const Color(0xfff49ccd));
      glow(.69, -.19, .49, const Color(0xffa183ea));
    }
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.immersive != immersive;
}
