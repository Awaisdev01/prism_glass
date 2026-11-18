// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass/liquid_glass.dart';

void main() {
  test('GlassController serializes arguments', () {
    final controller = GlassController(
      style: GlassStyle.clear,
      interactive: true,
      tintColor: const Color(0x80FF0000),
      cornerRadius: 12,
    );
    final args = controller.toArguments();
    expect(args['style'], 1);
    expect(args['interactive'], isTrue);
    expect(args['cornerRadius'], 12);
    expect(args['tintRed'], isNonZero);
  });

  testWidgets('LiquidGlassSurface renders the fallback on non-iOS hosts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const LiquidGlassSurface(
        cornerRadius: 16,
        child: SizedBox(width: 100, height: 50),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LiquidGlassSurface), findsOneWidget);
  });
}
