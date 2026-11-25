import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var privacyCover: UIVisualEffectView?

  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenProtectionPreferenceChanged),
      name: .llaveroScreenProtectionChanged,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)
    if isScreenProtectionEnabled {
      showPrivacyCover()
    }
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    refreshPrivacyCover()
  }

  override func sceneDidDisconnect(_ scene: UIScene) {
    NotificationCenter.default.removeObserver(self)
    privacyCover?.removeFromSuperview()
    privacyCover = nil
    super.sceneDidDisconnect(scene)
  }

  @objc private func screenProtectionPreferenceChanged() {
    refreshPrivacyCover()
  }

  @objc private func screenCaptureChanged() {
    refreshPrivacyCover()
  }

  private var isScreenProtectionEnabled: Bool {
    guard let value = UserDefaults.standard.object(
      forKey: "llavero.screenProtectionEnabled"
    ) as? Bool else {
      return true
    }
    return value
  }

  private func refreshPrivacyCover() {
    let isCapturing = window?.windowScene?.screen.isCaptured ?? false
    if isScreenProtectionEnabled && isCapturing {
      showPrivacyCover()
    } else {
      privacyCover?.removeFromSuperview()
      privacyCover = nil
    }
  }

  private func showPrivacyCover() {
    guard let window else { return }
    if privacyCover == nil {
      let cover = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
      cover.frame = window.bounds
      cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      window.addSubview(cover)
      privacyCover = cover
    }
  }
}
