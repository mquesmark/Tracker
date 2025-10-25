import UIKit
import CoreData

@MainActor
final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trashButton = UIButton(type: .system)
        let trashImage = UIImage(
            systemName: "trash.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        )
        trashButton.setImage(trashImage, for: .normal)
        trashButton.imageView?.contentMode = .scaleAspectFit
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        trashButton.tintColor = .systemRed
        view.addSubview(trashButton)
        
        NSLayoutConstraint.activate([
            trashButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trashButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            trashButton.widthAnchor.constraint(equalToConstant: 80),
            trashButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func trashButtonTapped() {
        resetAppData()
    }
    
    private func resetAppData() {
        // 1. Delete all Core Data
        let persistentStoreCoordinator = DataBaseStore.shared.persistentContainer.persistentStoreCoordinator
        let stores = persistentStoreCoordinator.persistentStores
        
        Task.detached {
            for store in stores {
                do {
                    try persistentStoreCoordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
                    try persistentStoreCoordinator.addPersistentStore(ofType: store.type, configurationName: nil, at: store.url, options: nil)
                } catch {
                    print("Failed to reset Core Data store: \(error)")
                }
            }
            
            // 2. Clear UserDefaults
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                UserDefaults.standard.synchronize()
            }
            
            // 3. Clear cache
            URLCache.shared.removeAllCachedResponses()
            
            let fileManager = FileManager.default
            if let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                do {
                    let contents = try fileManager.contentsOfDirectory(at: cachesURL, includingPropertiesForKeys: nil, options: [])
                    for file in contents {
                        try fileManager.removeItem(at: file)
                    }
                } catch {
                    print("Failed to clear caches directory: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                exit(0)
            }
        }
    }
}
