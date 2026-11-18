// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass/liquid_glass.dart';

void main() {
  test('probes host glass capability without crashing', () async {
    final supported = await LiquidGlassHost.instance.probe();
    expect(supported, isA<bool>());
  });
}
