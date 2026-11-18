import Flutter
import UIKit

/// Renders Apple's native Liquid Glass material (iOS 26+) in a platform view.
///
/// Hosts a `UIVisualEffectView` configured with `UIGlassEffect`, the real
/// system glass material introduced with iOS 26. On older OS versions the
/// view is not created at all; the Dart layer falls back to a shader.
final class GlassPlatformView: NSObject, FlutterPlatformView {
  private let container: UIView
  private let effectView: UIVisualEffectView
  private let channel: FlutterMethodChannel?
  private var config: GlassConfig

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    container = UIView(frame: frame)
    effectView = UIVisualEffectView(effect: nil)

    config = GlassConfig.fromArgs(args)

    channel = FlutterMethodChannel(
      name: "prism_glass/view_\(viewId)", binaryMessenger: messenger)

    super.init()
    apply(config)
    container.addSubview(effectView)
  }

  func view() -> UIView { container }

  func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "update" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let dict = call.arguments as? [String: Any] else {
      result(nil)
      return
    }
    config = GlassConfig.fromArgs(call.arguments, defaults: config)
    apply(config)
    result(nil)
  }

  private func apply(_ c: GlassConfig) {
    if #available(iOS 26.0, *) {
      let style: UIGlassEffect.Style = c.style == 1 ? .clear : .regular
      let glass = UIGlassEffect(style: style)
      glass.isInteractive = c.interactive
      if let r = c.tintRed, let g = c.tintGreen, let b = c.tintBlue, let a = c.tintAlpha {
        glass.tintColor = UIColor(red: r, green: g, blue: b, alpha: a)
      }
      effectView.effect = glass
    } else {
      // Older iOS: plain translucent blur stand-in (Dart side also has a
      // shader fallback; this keeps the platform view harmless).
      effectView.effect = nil
    }
    container.clipsToBounds = true
    container.layer.cornerRadius = c.cornerRadius
    container.isOpaque = false
    container.backgroundColor = .clear
    effectView.frame = container.bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
}

/// The platform-view factory that owns glass surfaces.
final class GlassViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private var views: [Int64: GlassPlatformView] = [:]

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    let view = GlassPlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    views[viewId] = view
    return view
  }

  /// Routes `update` calls to the right surface.
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method.hasPrefix("prism_glass/view_") else {
      result(FlutterMethodNotImplemented)
      return
    }
    let idString = call.method
      .replacingOccurrences(of: "prism_glass/view_", with: "")
    guard let id = Int64(idString), let view = views[id] else {
      result(FlutterMethodNotImplemented)
      return
    }
    view.onMethodCall(call, result: result)
  }
}

public class PrismGlassPlugin: NSObject, FlutterPlugin, PrismGlassApi {
  private var factory: GlassViewFactory?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = PrismGlassPlugin()
    PrismGlassApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    if #available(iOS 26.0, *) {
      let glassFactory = GlassViewFactory(messenger: registrar.messenger())
      instance.factory = glassFactory
      registrar.register(
        glassFactory,
        withId: "prism/glass_view")
      // Method-channel router for per-view updates.
      let routerChannel = FlutterMethodChannel(
        name: "prism_glass/router", binaryMessenger: registrar.messenger())
      routerChannel.setMethodCallHandler { call, result in
        glassFactory.handle(call, result: result)
      }
    }
  }

  func getHostInfo() throws -> HostInfo {
    let version = UIDevice.current.systemVersion
    let major = Int(version.split(separator: ".").first ?? "0") ?? 0
    return HostInfo(
      osVersion: version,
      supportsNativeGlass: major >= 26)
  }
}

extension GlassConfig {
  /// Builds a config from a Flutter-sent dictionary (platform-view creation args
  /// or `update` call arguments), falling back to `defaults` for absent keys.
  static func fromArgs(_ args: Any?, defaults: GlassConfig? = nil) -> GlassConfig {
    let dict = args as? [String: Any] ?? [:]
    let d = defaults
    func num(_ key: String) -> Double? { (dict[key] as? NSNumber)?.doubleValue }
    return GlassConfig(
      style: Int64(num("style") ?? Double(d?.style ?? 0)),
      interactive: (dict["interactive"] as? NSNumber)?.boolValue ?? d?.interactive ?? false,
      tintRed: num("tintRed") ?? d?.tintRed,
      tintGreen: num("tintGreen") ?? d?.tintGreen,
      tintBlue: num("tintBlue") ?? d?.tintBlue,
      tintAlpha: num("tintAlpha") ?? d?.tintAlpha,
      cornerRadius: num("cornerRadius") ?? d?.cornerRadius ?? 0,
      groupId: dict["groupId"] as? String ?? d?.groupId,
      mergeSpacing: num("mergeSpacing") ?? d?.mergeSpacing ?? 0)
  }
}
