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
  }
}
