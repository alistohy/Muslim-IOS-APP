import 'dart:math' as math;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// CircuitBackground
// ---------------------------------------------------------------------------

/// Wraps [child] in a [Stack] with a circuit-board pattern painted behind it.
///
/// Pass [isDark] to switch between the dark-palette (cyan @15 % opacity) and
/// the light-palette (teal @8 % opacity) colour variants.
class CircuitBackground extends StatelessWidget {
  const CircuitBackground({
    super.key,
    required this.child,
    this.isDark = true,
  });

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _CircuitPainter(isDark: isDark),
          ),
        ),
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _CircuitPainter
// ---------------------------------------------------------------------------

class _CircuitPainter extends CustomPainter {
  _CircuitPainter({required this.isDark});

  final bool isDark;

  // Spacing between grid nodes
  static const double _gridStep = 56.0;
  // Radius of the junction dots
  static const double _dotRadius = 2.2;
  // Half-width of the tracks
  static const double _trackWidth = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor = isDark
        ? const Color(0xFF00E5FF).withOpacity(0.15)
        : const Color(0xFF0097A7).withOpacity(0.08);
    final dotColor = isDark
        ? const Color(0xFF00E5FF).withOpacity(0.22)
        : const Color(0xFF0097A7).withOpacity(0.12);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = _trackWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final rng = math.Random(42); // fixed seed → deterministic pattern

    final cols = (size.width  / _gridStep).ceil() + 1;
    final rows = (size.height / _gridStep).ceil() + 1;

    // ── Grid nodes ─────────────────────────────────────────────────────────
    // Store which nodes are "active" (used as junction points)
    final Set<int> activeNodes = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Activate ~45 % of grid nodes so the pattern is sparse
        if (rng.nextDouble() < 0.45) {
          activeNodes.add(r * cols + c);
        }
      }
    }

    // ── Horizontal segments ────────────────────────────────────────────────
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 1; c++) {
        if (activeNodes.contains(r * cols + c) &&
            activeNodes.contains(r * cols + c + 1)) {
          final x1 = c * _gridStep;
          final x2 = (c + 1) * _gridStep;
          final y  = r * _gridStep;
          canvas.drawLine(Offset(x1, y), Offset(x2, y), linePaint);
        }
      }
    }

    // ── Vertical segments ──────────────────────────────────────────────────
    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols; c++) {
        if (activeNodes.contains(r * cols + c) &&
            activeNodes.contains((r + 1) * cols + c)) {
          final x  = c * _gridStep;
          final y1 = r * _gridStep;
          final y2 = (r + 1) * _gridStep;
          canvas.drawLine(Offset(x, y1), Offset(x, y2), linePaint);
        }
      }
    }

    // ── Diagonal segments (sparse, one direction per cell by chance) ───────
    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols - 1; c++) {
        if (rng.nextDouble() < 0.10) {
          // pick NW→SE or NE→SW at random
          if (rng.nextBool()) {
            canvas.drawLine(
              Offset(c * _gridStep, r * _gridStep),
              Offset((c + 1) * _gridStep, (r + 1) * _gridStep),
              linePaint,
            );
          } else {
            canvas.drawLine(
              Offset((c + 1) * _gridStep, r * _gridStep),
              Offset(c * _gridStep, (r + 1) * _gridStep),
              linePaint,
            );
          }
        }
      }
    }

    // ── Junction dots ──────────────────────────────────────────────────────
    for (final id in activeNodes) {
      final r = id ~/ cols;
      final c = id % cols;
      canvas.drawCircle(
        Offset(c * _gridStep, r * _gridStep),
        _dotRadius,
        dotPaint,
      );
    }

    // ── SMD pad accent circles (larger, very sparse) ───────────────────────
    final accentPaint = Paint()
      ..color = dotColor.withOpacity(dotColor.opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final rng2 = math.Random(13);
    for (int i = 0; i < (cols * rows * 0.04).round(); i++) {
      final cx = rng2.nextDouble() * size.width;
      final cy = rng2.nextDouble() * size.height;
      canvas.drawCircle(Offset(cx, cy), 5.5, accentPaint);
    }
  }

  @override
  bool shouldRepaint(_CircuitPainter old) => old.isDark != isDark;
}
