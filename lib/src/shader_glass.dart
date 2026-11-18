// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show FragmentProgram;

import 'package:flutter/widgets.dart';
import 'glass_style.dart';

/// Renders the glass fragment shader over an already-blurred backdrop.
///
/// This is the universal fallback for Android, web, desktop and iOS < 26.
class ShaderLiquidGlass extends StatefulWidget {
  const ShaderLiquidGlass({
    super.key,
    required this.style,
    required this.tint,
    required this.cornerRadius,
    required this.time,
  });

  final GlassStyle style;
  final Color tint;
  final double cornerRadius;
  final Animation<double> time;

  @override
  State<ShaderLiquidGlass> createState() => _ShaderLiquidGlassState();
}

class _ShaderLiquidGlassState extends State<ShaderLiquidGlass> {
  FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Package assets are namespaced when consumed from an app; the plain
    // path works in unit tests and when the loader already resolved the
    // prefix. Try both.
    FragmentProgram? program;
    for (final asset in const [
      'packages/prism_glass/shaders/glass.iplr',
      'shaders/glass.iplr',
    ]) {
      try {
        program = await FragmentProgram.fromAsset(asset);
        break;
      } on Exception {
        // Try the next candidate.
      }
    }
    if (mounted && program != null) {
      setState(() => _program = program);
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = _program;
    if (program == null) {
      // Program still loading: plain translucent surface.
      return ColoredBox(color: widget.tint.withValues(alpha: 0.2));
    }

    return AnimatedBuilder(
      animation: widget.time,
      builder: (context, _) {
        return CustomPaint(
          painter: _GlassPainter(
            program: program,
            style: widget.style,
            tint: widget.tint,
            radius: widget.cornerRadius,
            time: widget.time.value * 60,
          ),
        );
      },
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.program,
    required this.style,
    required this.tint,
    required this.radius,
    required this.time,
  });

  final FragmentProgram program;
  final GlassStyle style;
  final Color tint;
  final double radius;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, 18.0); // sigma
    shader.setFloat(3, (tint.r * 255.0) / 255);
    shader.setFloat(4, (tint.g * 255.0) / 255);
    shader.setFloat(5, (tint.b * 255.0) / 255);
    shader.setFloat(6, tint.a);
    shader.setFloat(7, style == GlassStyle.clear ? 1 : 0);
    shader.setFloat(8, radius);
    shader.setFloat(9, time % 1000.0);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_GlassPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.tint != tint ||
      oldDelegate.radius != radius ||
      (oldDelegate.time - time).abs() > 0.01;
}
