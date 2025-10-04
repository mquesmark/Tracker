import UIKit

final class AlertService {
    static let shared = AlertService()
    private init() {}
    
    func showAlert(title: String, message: String?, viewController: UIViewController, actions: [UIAlertAction]? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach() { action in
            alertController.addAction(action)
        }
        if actions == nil {
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
        }
        
        viewController.present(alertController, animated: true)
    }
}
