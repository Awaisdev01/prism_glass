// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'messages.g.dart';

/// Dart-side access to the host's glass capability.
class LiquidGlassHost {
  LiquidGlassHost._();

  static final LiquidGlassHost instance = LiquidGlassHost._();

  LiquidGlassApi? _api;
  bool? _cached;

  /// Returns true when the host can render Apple's real Liquid Glass
  /// (iOS 26+). Cached after the first call.
  Future<bool> probe() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }
    _api ??= LiquidGlassApi();
    final info = await _api!.getHostInfo();
    _cached = info.supportsNativeGlass;
    return _cached!;
  }
}
