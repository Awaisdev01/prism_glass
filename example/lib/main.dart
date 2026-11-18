// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:prism_glass/prism_glass.dart';

void main() => runApp(const LiquidGlassExampleApp());

class LiquidGlassExampleApp extends StatelessWidget {
  const LiquidGlassExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF0B0B0F),
      textStyle: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
      builder: (_, _) => const GlassDemo(),
    );
  }
}

class GlassDemo extends StatelessWidget {
  const GlassDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0B0F),
      child: Center(
        child: PrismGlassSurface(
          style: GlassStyle.regular,
          cornerRadius: 24,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Text('Liquid Glass'),
          ),
        ),
      ),
    );
  }
}
