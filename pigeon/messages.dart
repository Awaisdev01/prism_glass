import 'package:pigeon/pigeon.dart';

// This file is where you define the interface between Dart code and host
// platform code. After editing this file, run
//   dart run pigeon --input pigeon/messages.dart
// to re-generate all of the output files.

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'prism_glass',
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/prism/glass_view/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'dev.prism.prism_glass'),
    swiftOut: [
      'ios/prism_glass/Sources/prism_glass/Messages.g.swift',
    ],
  ),
)

/// Configuration for a single glass surface.
class GlassConfig {
  /// 0 = regular, 1 = clear.
  final int style;
  final bool interactive;
  final double? tintRed;
  final double? tintGreen;
  final double? tintBlue;
  final double? tintAlpha;
  /// Corner radius applied by the host view (all platforms).
  final double cornerRadius;
  /// Whether this surface participates in a merged glass container group.
  final String? groupId;
  /// Spacing at which sibling glass elements begin to merge
  /// (UIGlassContainerEffect.spacing on iOS 26+).
  final double mergeSpacing;

  const GlassConfig({
    required this.style,
    required this.interactive,
    required this.cornerRadius,
    required this.mergeSpacing,
    this.tintRed,
    this.tintGreen,
    this.tintBlue,
    this.tintAlpha,
    this.groupId,
  });
}

/// Version information reported by the host platform.
class HostInfo {
  final String osVersion;
  /// True when the host can render Apple's real UIGlassEffect (iOS 26+).
  final bool supportsNativeGlass;
  const HostInfo({required this.osVersion, required this.supportsNativeGlass});
}

@HostApi()
abstract class PrismGlassApi {
  /// Returns OS version and native-glass capability.
  HostInfo getHostInfo();
}

@FlutterApi()
abstract class GlassSurfaceCallbacks {
  /// Reports a tap that reached the native glass layer (interactive mode).
  void onTap(double x, double y);
}
