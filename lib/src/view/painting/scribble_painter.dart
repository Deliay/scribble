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
    bool enableCache = false,
  }) : _enableCache = enableCache;

  final bool _enableCache;

  /// The [Sketch] to draw.
  final Sketch sketch;

  /// {@macro view.state.scribble_state.scale_factor}
  final double scaleFactor;

  @override
  final bool simulatePressure;

  final Map<WeakReference<SketchLine>, Path> _pathCache = {};

  Path? _getPath(int index) {
    final line = sketch.lines[index];
    if (!_enableCache) {
      return getPathForLine(
        line,
        scaleFactor: scaleFactor,
      );
    }
    final ref = WeakReference(line);
    if (_pathCache.containsKey(ref)) {
      return _pathCache[ref];
    }

    final path = getPathForLine(
      line,
      scaleFactor: scaleFactor,
    );
    if (path == null) return null;
    path.close();

    _pathCache.putIfAbsent(ref, () => path);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25 * scaleFactor
      ..strokeJoin = StrokeJoin.miter
      ..isAntiAlias = false;

    for (var i = 0; i < sketch.lines.length; ++i) {
      final path = _getPath(i);
      if (path == null) {
        continue;
      }
      paint.color = Color(sketch.lines[i].color);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ScribblePainter oldDelegate) {
    return oldDelegate.sketch != sketch ||
        oldDelegate.simulatePressure != simulatePressure ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
