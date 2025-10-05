import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        guard let window else { return }
        window.overrideUserInterfaceStyle = .light // Временно, пока не добавим светлую тему
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
    }
}

