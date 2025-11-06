import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DaysValueTransformer.register()
        if let configuration = AppMetricaConfiguration(apiKey: "9f81a850-e15b-4de6-88e5-cb195f5e2345") {
            AppMetrica.activate(with: configuration)
        } else {
            print("WARNING: AppMetrica configuration is not valid")
        }
        
        return true
    }
}
