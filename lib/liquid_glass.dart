// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Glass — Apple's Liquid Glass material for Flutter.
///
/// On iOS 26+ this package renders the *real* system material
/// (`UIGlassEffect` / `UIGlassContainerEffect`) via a platform view.
/// Everywhere else it renders a fragment-shader approximation, so one
/// widget works on every platform.
library;

export 'src/controller.dart';
export 'src/glass_style.dart';
export 'src/host_api.dart';
export 'src/liquid_glass_surface.dart';
export 'src/shader_glass.dart';
