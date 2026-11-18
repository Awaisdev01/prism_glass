// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'glass_style.dart';

/// Controls a glass surface's live properties (tint, style, interaction).
///
/// Changes are pushed to the native view without rebuilding the subtree.
class GlassController extends ChangeNotifier {
  GlassController({
    this.style = GlassStyle.regular,
    this.interactive = false,
    this.tintColor,
    this.cornerRadius = 0,
  });

  GlassStyle style;
  bool interactive;
  Color? tintColor;
  double cornerRadius;

  /// Serializes the current state for the native `update` channel.
  Map<String, Object?> toArguments() => <String, Object?>{
    'style': style == GlassStyle.clear ? 1 : 0,
    'interactive': interactive,
    'cornerRadius': cornerRadius,
    if (tintColor != null) ...<String, Object?>{
      'tintRed': tintColor!.r,
      'tintGreen': tintColor!.g,
      'tintBlue': tintColor!.b,
      'tintAlpha': tintColor!.a,
    },
    'mergeSpacing': 0.0,
  };
}
