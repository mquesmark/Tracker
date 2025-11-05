import UIKit

// MARK: - Statistics Screen
final class StatisticsViewController: UIViewController {

    // MARK: UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        return cv
    }()

    // MARK: Data
    private struct StatItem {
        let value: Int
        let subtitle: String
    }

    private let recordStore = TrackerRecordStore.shared
    
    private var items: [StatItem] = [
        .init(value: 0, subtitle: NSLocalizedString("completed_trackers", comment: "Трекеров завершено")),
    ]

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("stats", comment: "Статистика")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .whiteDay
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 16, right: 0)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StatCell.self, forCellWithReuseIdentifier: StatCell.reuseID)
        getValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getValues()
    }
    
    private func getValues() {
        items[0] = .init(value: recordStore.countAllRecords(), subtitle: items[0].subtitle)
        collectionView.reloadData()
    }
}

extension StatisticsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCell.reuseID, for: indexPath) as! StatCell
        let item = items[indexPath.row]
        cell.configure(value: item.value, subtitle: item.subtitle)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 90)
    }
}
