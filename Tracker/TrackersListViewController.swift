import UIKit

final class TrackersListViewController: UIViewController {
    private let calendar = Calendar(identifier: .iso8601)
    
    private var currentDate: Date = Date()
    
    private var completedToday: Set<UUID> = []
    
    private var categories: [TrackerCategory] = []
    
    private var completedTrackers: [TrackerRecord] = []
    
    private let categoriesMock: [TrackerCategory] = [
        TrackerCategory(name: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Протереть пыль", emoji: "💨", color: .colorSelection14, schedule: [.monday, .wednesday, .friday, .saturday]),
            Tracker(id: UUID(), name: "Купить чай", emoji: "🍃", color: .colorSelection9, schedule: [.tuesday, .thursday, .saturday])
        ]),
        TrackerCategory(name: "Здоровье", trackers: [
            Tracker(id: UUID(), name: "Утренняя зарядка", emoji: "🏃‍♂️", color: .colorSelection2, schedule: [.monday, .thursday, .saturday]),
            Tracker(id: UUID(), name: "Медитация", emoji: "🧘‍♀️", color: .colorSelection3, schedule: [.wednesday, .friday, .saturday])
        ]),
        TrackerCategory(name: "Развитие", trackers: [
            Tracker(id: UUID(), name: "Чтение книги", emoji: "📚", color: .colorSelection5, schedule: [.monday, .thursday]),
            Tracker(id: UUID(), name: "Изучение языка", emoji: "🗣", color: .colorSelection6, schedule: [.wednesday, .friday])
        ]),
        TrackerCategory(name: "Работа", trackers: [
            Tracker(id: UUID(), name: "Работа над проектом", emoji: "💻", color: .colorSelection10, schedule: [.monday, .wednesday, .thursday, .friday]),
            Tracker(id: UUID(), name: "Планирование дня", emoji: "📝", color: .colorSelection8, schedule: [.monday, .thursday])
        ]),
        TrackerCategory(name: "Отдых", trackers: [
            Tracker(id: UUID(), name: "Прогулка", emoji: "🚶‍♂️", color: .colorSelection1, schedule: [.thursday, .saturday]),
            Tracker(id: UUID(), name: "Вечерний отдых", emoji: "🛀", color: .colorSelection4, schedule: [.friday, .saturday])
        ]),
        TrackerCategory(name: "Социальное", trackers: [
            Tracker(id: UUID(), name: "Звонок другу", emoji: "📞", color: .colorSelection11, schedule: [.monday, .wednesday, .friday]),
            Tracker(id: UUID(), name: "Поход с друзьями", emoji: "🍻", color: .colorSelection12, schedule: [.saturday])
        ])
    ]
    
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .whiteDay
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .blackDay
        label.text = "Трекеры"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchField: UISearchTextField = {
        let tf = UISearchTextField()
        tf.placeholder = "Поиск"
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.background = nil
        tf.backgroundColor = .clear
        tf.backgroundColor = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 0.12)
        tf.layer.cornerRadius = 10
        
        tf.layer.cornerCurve = .continuous
        tf.clipsToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .star)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let starTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blackDay
        label.text = "Что будем отслеживать?"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starStackView = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
      //  categories = categoriesMock
        setupCollection()
        setupHideKeyboard()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        if let tabBar = self.tabBarController?.tabBar {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .whiteDay
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        let addButton = UIBarButtonItem(
            title: nil,
            image: UIImage(resource: .addTracker),
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        addButton.tintColor = .blackDay
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
        view.backgroundColor = .whiteDay
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(searchField)
        
        datePicker.addAction(UIAction{ [weak self] _ in
            guard let self else { return }
            self.currentDate = datePicker.date
            rebuildCompletedTodaySet()
            starStackVisibilityCheck()
            self.collectionView.reloadData()
        }, for: .valueChanged)
        
        starStackView.axis = .vertical
        starStackView.spacing = 8
        starStackView.alignment = .center
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        
        starStackView.addArrangedSubview(starImageView)
        starStackView.addArrangedSubview(starTextLabel)
        
        view.addSubview(starStackView)
        
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 1
            ),
            
            searchField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            searchField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            searchField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 7
            ),
            
            starStackView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            starStackView.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            
            collectionView.topAnchor.constraint(
                equalTo: searchField.bottomAnchor, constant: 24
            ),
            
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrackerCategoryHeader")
        starStackVisibilityCheck()
        
        
    }
    
    private func starStackVisibilityCheck() {
        if isTrackersForChosenDateEmpty() {
            starStackView.isHidden = false
            collectionView.isHidden = true
        } else {
            starStackView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    // MARK: - User Actions Handlers
    
    private func setupHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addRecord(for tracker: Tracker) {
        let record = TrackerRecord(trackerId: tracker.id, dateLogged: datePicker.date)
        guard !completedToday.contains(record.trackerId) else { return }
        
        guard calendar.startOfDay(for: record.dateLogged) <= calendar.startOfDay(for: Date()) else {
            AlertService.shared.showAlert(title: "Ошибка", message: "Нельзя отметить трекер за день, который ещё не наступил", viewController: self, actions: [
                UIAlertAction(title: "Жаль", style: .default)
            ])
            return
        }
        completedTrackers += [record]
        completedToday.insert(record.trackerId)
    }
    
    private func removeRecord(for tracker: Tracker) {
        
        let record = TrackerRecord(trackerId: tracker.id, dateLogged: datePicker.date)
        
        guard completedToday.contains(record.trackerId) else { return }
        
        completedTrackers = completedTrackers.filter {
            !($0.trackerId == record.trackerId &&
              calendar.isDate($0.dateLogged, inSameDayAs: record.dateLogged)
            )
        }
        completedToday.remove(record.trackerId)
    }
    
    @objc private func addTrackerButtonTapped() {
        let vc = CreateHabitViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // MARK: - Helper Methods
    private func isTrackersForChosenDateEmpty() -> Bool {
        categories.allSatisfy { filteredTrackers(for: $0).isEmpty }
    }
    
    private func filteredTrackers(for category: TrackerCategory) -> [Tracker] {
        guard let weekDay = weekdayForCurrentDate(currentDate) else { return [] }
        return category.trackers.filter { $0.schedule.contains(weekDay) }
    }

    private func weekdayForCurrentDate(_ date: Date) -> WeekDay? {
        let weekday = calendar.component(.weekday, from: date)
        let adjusted = (weekday == 1) ? 7 : weekday - 1
        return WeekDay(rawValue: adjusted)
    }
    
    
    private func rebuildCompletedTodaySet() {
       let completedTodayTrackersList = completedTrackers.filter { calendar.isDate($0.dateLogged, inSameDayAs: currentDate) }
        let completedTodayNewSet = Set(completedTodayTrackersList.map(\.trackerId))
        completedToday = completedTodayNewSet
    }
}
// MARK: - UICollectionViewDataSource Private Methods
extension TrackersListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers(for: categories[section]).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell ?? TrackerCollectionViewCell()
        
        let category = categories[indexPath.section]
        let tracker = filteredTrackers(for: category)[indexPath.row]
        let isCompleted = completedToday.contains(tracker.id)
        let timesCompleted = completedTrackers.count{
            $0.trackerId == tracker.id
        }
        
        cell.configure(withTracker: tracker, isCompleted: isCompleted, daysCompleted: timesCompleted)
        
        cell.onPlusTap = { [weak self] in
            guard let self,
                  let indexPath = self.collectionView.indexPath(for: cell)
            else { return }
            let tracker = filteredTrackers(for: category)[indexPath.row]
            
            if self.completedToday.contains(tracker.id)
            {
                self.removeRecord(for: tracker)
            } else {
                self.addRecord(for: tracker)
            }
            self.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }
    
    
}
// MARK: - UICollectionViewDelegate Private Methods
extension TrackersListViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout Private Methods
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 32 - 10) / 2,
                      height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier, for: indexPath) as? TrackerCategoryHeader
        header?.nameLabel.text = categories[indexPath.section].name
        return header ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let trackers = filteredTrackers(for: categories[section])
        return trackers.isEmpty ? .zero : CGSize(width: collectionView.bounds.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}


extension TrackersListViewController: CreateHabitViewControllerDelegate {
    func createTracker(name: String, categoryName: String, schedule: [WeekDay]) {
        let tracker = Tracker(id: UUID(), name: name, emoji: "✍🏻", color: .colorSelection9, schedule: schedule)
        
        if let sectionIndex = categories.firstIndex(where: { $0.name == categoryName }) {
            var category = categories[sectionIndex]
            category = TrackerCategory(name: category.name, trackers: category.trackers + [tracker])
            categories[sectionIndex] = category
            
            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet(integer: sectionIndex))
            }
        } else {
            let newCategory = TrackerCategory(name: categoryName, trackers: [tracker])
            let newSectionIndex = categories.count
            categories.append(newCategory)
            
            collectionView.performBatchUpdates{
                collectionView.insertSections(IndexSet(integer: newSectionIndex))
            }
        }
        
        starStackVisibilityCheck()
    }
    
}
