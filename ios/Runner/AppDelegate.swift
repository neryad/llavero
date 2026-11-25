import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard excludeApplicationSupportFromICloudBackup() else {
      return false
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func excludeApplicationSupportFromICloudBackup() -> Bool {
    guard var applicationSupportURL = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first else {
      return false
    }

    do {
      try FileManager.default.createDirectory(
        at: applicationSupportURL,
        withIntermediateDirectories: true
      )
      var resourceValues = URLResourceValues()
      resourceValues.isExcludedFromBackup = true
      try applicationSupportURL.setResourceValues(resourceValues)
      return true
    } catch {
      return false
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "LlaveroScreenProtection"
    ) else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "llavero/screen_protection",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setEnabled", let enabled = call.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      UserDefaults.standard.set(enabled, forKey: "llavero.screenProtectionEnabled")
      NotificationCenter.default.post(name: .llaveroScreenProtectionChanged, object: nil)
      result(nil)
    }
  }
}

extension Notification.Name {
  static let llaveroScreenProtectionChanged =
    Notification.Name("llavero.screenProtectionChanged")
}
