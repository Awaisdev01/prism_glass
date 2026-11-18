// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'glass_style.dart';
import 'host_api.dart';
import 'native_view.dart';
import 'shader_glass.dart';

/// A surface that renders Apple's Liquid Glass material.
///
/// On iOS 26+ this hosts the *real* system material (`UIGlassEffect`) in a
/// platform view, including interactive behavior and merged containers.
/// On every other platform it renders a fragment-shader approximation of
/// the same material so a single widget works everywhere.
///
/// ```dart
/// LiquidGlassSurface(
///   style: GlassStyle.regular,
///   cornerRadius: 24,
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Glassy'),
///   ),
/// )
/// ```
class LiquidGlassSurface extends StatefulWidget {
  const LiquidGlassSurface({
    super.key,
    this.style = GlassStyle.regular,
    this.interactive = false,
    this.cornerRadius = 0,
    this.tintColor,
    this.blurSigma = 18,
    this.child,
  });

  /// The glass material style.
  final GlassStyle style;

  /// Whether the native glass responds to touches (iOS 26+ only).
  final bool interactive;

  /// Corner radius of the glass surface in logical pixels.
  final double cornerRadius;

  /// Optional tint applied over the glass.
  final Color? tintColor;

  /// Backdrop blur strength used by the shader fallback.
  final double blurSigma;

  final Widget? child;

  @override
  State<LiquidGlassSurface> createState() => _LiquidGlassSurfaceState();
}

class _LiquidGlassSurfaceState extends State<LiquidGlassSurface> {
  bool? _nativeSupported;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      LiquidGlassHost.instance.probe().then((supported) {
        if (mounted) {
          setState(() => _nativeSupported = supported);
        }
      });
    } else {
      _nativeSupported = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final supported = _nativeSupported;
    if (supported == null) {
      return const SizedBox.shrink();
    }
    return supported
        ? _NativeGlass(key: widget.key, widget: widget)
        : _ShaderGlass(widget: widget);
  }
}

/// iOS 26+: native UIGlassEffect in a platform view.
class _NativeGlass extends StatelessWidget {
  const _NativeGlass({super.key, required this.widget});

  final LiquidGlassSurface widget;

  @override
  Widget build(BuildContext context) {
    return NativeGlassView(
      style: widget.style,
      interactive: widget.interactive,
      cornerRadius: widget.cornerRadius,
      tintColor: widget.tintColor,
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}

/// Everything else: blurred backdrop + fragment-shader glass character.
class _ShaderGlass extends StatefulWidget {
  const _ShaderGlass({required this.widget});

  final LiquidGlassSurface widget;

  @override
  State<_ShaderGlass> createState() => _ShaderGlassState();
}

class _ShaderGlassState extends State<_ShaderGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
    vsync: this,
    duration: const Duration(days: 365),
  )..forward();

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.widget;
    final radius = BorderRadius.circular(w.cornerRadius);
    final tint = w.tintColor ?? const Color(0xFFFFFFFF);

    return Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Frosted backdrop behind the glass shader.
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: w.blurSigma,
                sigmaY: w.blurSigma,
                tileMode: TileMode.mirror,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderLiquidGlass(
                style: w.style,
                tint: tint,
                cornerRadius: w.cornerRadius,
                time: _time,
              ),
            ),
          ),
          if (w.child != null) w.child!,
        ],
      ),
      ),
    );
  }
}
