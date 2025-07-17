import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scribble/scribble.dart';
import 'package:scribble/src/view/painting/sketch_line_path_mixin.dart';

/// A painter for drawing a scribble sketch.
class ScribblePainter extends CustomPainter with SketchLinePathMixin {
  /// Creates a new [ScribblePainter] instance.
  ScribblePainter({
    required this.sketch,
    required this.scaleFactor,
    required this.simulatePressure,
  });

  /// The [Sketch] to draw.
  final Sketch sketch;

  /// {@macro view.state.scribble_state.scale_factor}
  final double scaleFactor;

  @override
  final bool simulatePressure;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final start = DateTime.now().toUtc().millisecondsSinceEpoch;
    for (var i = 0; i < sketch.lines.length; ++i) {
      final path = getPathForLine(
        sketch.lines[i],
        scaleFactor: scaleFactor,
      );
      if (path == null) {
        continue;
      }
      paint.color = Color(sketch.lines[i].color);
      canvas.drawPath(path, paint);
    }
    final end = DateTime.now().toUtc().millisecondsSinceEpoch;
    print("redraw cost: ${end - start}ms");
  }

  @override
  bool shouldRepaint(ScribblePainter oldDelegate) {
    return oldDelegate.sketch != sketch ||
        oldDelegate.simulatePressure != simulatePressure ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
