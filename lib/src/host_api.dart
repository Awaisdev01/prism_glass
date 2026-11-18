// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'messages.g.dart';

/// Dart-side access to the host's glass capability.
class PrismGlassHost {
  PrismGlassHost._();

  static final PrismGlassHost instance = PrismGlassHost._();

  PrismGlassApi? _api;
  bool? _cached;

  /// Returns true when the host can render Apple's real Liquid Glass
  /// (iOS 26+). Cached after the first call.
  Future<bool> probe() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }
    _api ??= PrismGlassApi();
    final info = await _api!.getHostInfo();
    _cached = info.supportsNativeGlass;
    return _cached!;
  }
}
