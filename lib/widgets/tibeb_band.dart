import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A woven geometric border, after the *tibeb* bands on a habesha kemis.
///
/// This is the app's one structural signature. It replaces the decorative
/// gradients and glow orbs that used to carry visual interest: it is pure
/// geometry, so it costs nothing to draw, scales to any density, and belongs
/// to this product in a way a gradient never can.
///
/// Use it to terminate a section, weight a header, or mark progress. Do not
/// scatter it — one band per screen is the rule; two competes with itself.
class TibebBand extends StatelessWidget {
  const TibebBand({
    super.key,
    this.height = 14,
    this.colors,
    this.background = Colors.transparent,
    this.progress = 1.0,
  });

  /// Band thickness. Below ~10 the diamonds stop reading.
  final double height;

  /// Thread colours, drawn in order. Defaults to the app's semantic trio.
  final List<Color>? colors;

  final Color background;

  /// 0–1. Draws only the left portion, so the band doubles as a progress
  /// indicator without introducing a second visual language for progress.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TibebPainter(
          colors:
              colors ??
              const [
                FluentianColors.error,
                FluentianColors.warning,
                FluentianColors.success,
              ],
          background: background,
          progress: progress.clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

class _TibebPainter extends CustomPainter {
  _TibebPainter({
    required this.colors,
    required this.background,
    required this.progress,
  });

  final List<Color> colors;
  final Color background;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (background.a > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = background,
      );
    }

    final drawWidth = size.width * progress;
    if (drawWidth <= 0) return;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, drawWidth, size.height));

    final h = size.height;
    // One motif is as wide as the band is tall, so the weave stays square
    // whatever thickness the caller asks for.
    final unit = h;
    final rows = colors.length;
    final rowH = h / rows;

    for (var row = 0; row < rows; row++) {
      final paint = Paint()
        ..color = colors[row]
        ..style = PaintingStyle.stroke
        ..strokeWidth = rowH * 0.42
        ..strokeCap = StrokeCap.square;

      final top = row * rowH;
      final mid = top + rowH / 2;
      final path = Path();

      if (row.isEven) {
        // Chevron run.
        path.moveTo(0, mid + rowH * 0.22);
        var x = 0.0;
        var up = true;
        while (x < size.width + unit) {
          x += unit / 2;
          path.lineTo(x, up ? mid - rowH * 0.22 : mid + rowH * 0.22);
          up = !up;
        }
        canvas.drawPath(path, paint);
      } else {
        // Stepped diamonds, offset half a unit from the chevrons above.
        final fill = Paint()
          ..color = colors[row]
          ..style = PaintingStyle.fill;
        final r = rowH * 0.30;
        for (var x = unit / 2; x < size.width + unit; x += unit) {
          final d = Path()
            ..moveTo(x, mid - r)
            ..lineTo(x + r, mid)
            ..lineTo(x, mid + r)
            ..lineTo(x - r, mid)
            ..close();
          canvas.drawPath(d, fill);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TibebPainter old) =>
      old.progress != progress ||
      old.background != background ||
      !identical(old.colors, colors);
}
