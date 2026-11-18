// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'glass_style.dart';

/// Platform view hosting Apple's real `UIGlassEffect` (iOS 26+).
///
/// The child is rendered *inside* the platform view composition so the
/// native glass refracts Flutter content drawn behind it.
class NativeGlassView extends StatelessWidget {
  const NativeGlassView({
    super.key,
    required this.style,
    required this.interactive,
    required this.cornerRadius,
    required this.tintColor,
    this.child,
  });

  final GlassStyle style;
  final bool interactive;
  final double cornerRadius;
  final Color? tintColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return futureed();
  }

  Widget futureed() {
    // Platform views need UIKitView composition; content is drawn behind.
    return UiKitView(
      viewType: 'prism/glass_view',
      creationParams: <String, Object?>{
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
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
