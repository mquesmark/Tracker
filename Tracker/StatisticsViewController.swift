import UIKit
import CoreData

final class StatisticsViewController: UIViewController {

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.tintColor = .systemRed
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()

    private let trackerStore = TrackerStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 56),
            clearButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    }

    @objc private func clearTapped() {
        clearAllCoreData()
    }

    private func clearAllCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("AppDelegate not found")
            return
        }

        let container = appDelegate.persistentContainer
        let coordinator = container.persistentStoreCoordinator

        // Drop any in-memory objects and pending changes
        container.viewContext.performAndWait {
            container.viewContext.reset()
        }

        // Destroy every persistent store (e.g., SQLite). This wipes all data like a fresh install.
        for store in coordinator.persistentStores {
            do {
                if let url = store.url {
                    // Must remove a loaded store before destroying it on disk
                    try coordinator.remove(store)
                    try coordinator.destroyPersistentStore(at: url, ofType: store.type, options: nil)
                } else {
                    // Handle in-memory stores defensively
                    try coordinator.destroyPersistentStore(at: URL(fileURLWithPath: "/dev/null"), ofType: store.type, options: nil)
                }
            } catch {
                print("Failed to destroy store \(store): \(error)")
            }
        }

        // Recreate a fresh, empty store so the app keeps working
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to reload persistent stores: \(error)")
            } else {
                print("Core Data wiped: fresh store loaded.")
            }
        }
    }
}
