import UIKit

final class TrackersListViewController: UIViewController {
        
    private enum Constants {
        static let leadingPadding = CGFloat(16)
        static let rightPadding = CGFloat(16)
        static let interItemSpacing = CGFloat(10)
    }
    private let calendar = Calendar(identifier: .iso8601)
    
    private lazy var trackerStore: TrackerStore = .shared
    
    private var recordStore: TrackerRecordStore = .shared
    
    private var isSearchOrFilterActive: Bool = false {
        didSet {
            starStackVisibilityCheck()
        }
    }

    private func updateSearchOrFilterFlag() {
        let hasSearch = !(searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let selected = cal.startOfDay(for: datePicker.date)
        let isOtherDate = (selected != today)
        self.isSearchOrFilterActive = hasSearch || isOtherDate || currentFilter == .today || currentFilter == .completed || currentFilter == .notCompleted
    }
    
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter? = nil
    private var lastNonTodayDate: Date?
    
    private let collectionView: UICollectionView = {
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
        label.text = NSLocalizedString("trackers", comment: "trackers list title")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchField: UISearchTextField = {
        let tf = UISearchTextField()
        tf.placeholder = NSLocalizedString("search", comment: "Search placeholder text")
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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("star_text_label", comment: "Star text label")

        return label
    }()
    
    private let starStackView = UIStackView()
    
    private let filtersButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .ypBlue
        b.setTitle(NSLocalizedString("filters", comment: "Filter button title"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        b.titleLabel?.textColor = .whiteDay
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupCollection()
        setupHideKeyboard()
        trackerStore = TrackerStore.shared
        trackerStore.delegate = self
        trackerStore.updateDate(datePicker.date)
        onboardingCheck()
        applyDatePickerInteractivity(for: currentFilter)
        updateSearchOrFilterFlag()
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
            self.trackerStore.updateDate(datePicker.date)
            self.updateSearchOrFilterFlag()
        }, for: .valueChanged)
        
        searchField.addAction(UIAction { [weak self] _ in
            self?.searchChanged()
        }, for: .editingChanged)
        
        filtersButton.addAction(UIAction { [weak self] _ in
            self?.filtersButtonTapped()
        }, for: .touchUpInside)
        
        starStackView.axis = .vertical
        starStackView.spacing = 8
        starStackView.alignment = .center
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        
        starStackView.addArrangedSubview(starImageView)
        starStackView.addArrangedSubview(starTextLabel)
        
        view.addSubview(starStackView)
        
        view.addSubview(collectionView)
        
        view.addSubview(filtersButton)
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrackerCategoryHeader")
    }
    
    private func starStackVisibilityCheck() {
        
        if isSearchOrFilterActive {
            starImageView.image = UIImage(resource: .thinking)
            starTextLabel.text = NSLocalizedString("nothing_found", comment: "Text appears when nothing is found while searching or filtering")
        } else {
            starImageView.image = UIImage(resource: .star)
            starTextLabel.text = NSLocalizedString("star_text_label", comment: "Star text label")
        }
        
        let sections = collectionView.numberOfSections
        guard sections > 0 else {
            starStackView.isHidden = false
            collectionView.isHidden = true
            return
        }

        var totalItems = 0
        for section in 0..<sections {
            totalItems += collectionView.numberOfItems(inSection: section)
        }

        if totalItems == 0 {
            starStackView.isHidden = false
            collectionView.isHidden = true
        } else {
            starStackView.isHidden = true
            collectionView.isHidden = false
        }
        

    }
    
    private func onboardingCheck() {
        let isSeen: Bool = UserDefaults.standard.bool(forKey: "onboardingSeen")
        
        if !isSeen {
            let onboardingPageVC = OnboardingPageViewController()
            onboardingPageVC.modalPresentationStyle = .fullScreen
            present(onboardingPageVC, animated: false)
        }
    }
    
    // MARK: - User Actions Handlers
    
    private func setupHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func applyDatePickerInteractivity(for filter: TrackerFilter?) {
        let enabled = (filter != .today)
        datePicker.isEnabled = enabled
        datePicker.alpha = enabled ? 1.0 : 0.5
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func addTrackerButtonTapped() {
        let vc = CreateHabitViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func searchChanged() {
        trackerStore.updateSearchText(searchField.text)
        updateSearchOrFilterFlag()
    }
    
    private func filtersButtonTapped() {
        let vc = FiltersViewController(selectedFilter: currentFilter)
        vc.modalPresentationStyle = .pageSheet
        
        vc.onFilterPicked = { [weak self] filter in
            guard let self else { return }

            let previousFilter = self.currentFilter
            if filter == .today {

                self.lastNonTodayDate = self.datePicker.date
                let todayDate = Date()
                self.datePicker.date = todayDate
                self.currentDate = todayDate
                self.trackerStore.updateDate(todayDate)
            } else if previousFilter == .today, let restore = self.lastNonTodayDate {

                self.datePicker.date = restore
                self.currentDate = restore
                self.trackerStore.updateDate(restore)
            }

            self.currentFilter = filter
            self.trackerStore.updateFilter(filter)
            self.applyDatePickerInteractivity(for: filter)
            self.updateSearchOrFilterFlag()
        }
        present(vc, animated: true)
        
    }
    
    // MARK: - Helper Methods
    
    private func filteredTrackers(for category: TrackerCategory) -> [Tracker] {
        guard let weekDay = weekdayForCurrentDate(currentDate) else { return [] }
        return category.trackers.filter { $0.schedule.contains(weekDay) }
    }
    
    private func weekdayForCurrentDate(_ date: Date) -> WeekDay? {
        let weekday = calendar.component(.weekday, from: date)
        let adjusted = (weekday == 1) ? 7 : weekday - 1
        return WeekDay(rawValue: adjusted)
    }
}

// MARK: - UICollectionViewDataSource Private Methods
extension TrackersListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { trackerStore.numberOfSections }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { trackerStore.numberOfItems(in: section) }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell ?? TrackerCollectionViewCell()
    
        let trackerCD = trackerStore.tracker(at: indexPath)
        guard let tracker = trackerStore.convertToTracker(trackerCD) else { return cell }
        let isCompleted = recordStore.isCompleted(trackerId: tracker.id, date: datePicker.date)
        let timesCompleted = recordStore.countRecords(for: tracker.id)
        
        cell.configure(withTracker: tracker, isCompleted: isCompleted, daysCompleted: timesCompleted)
        
        cell.onPlusTap = { [weak self] in
            guard let self else { return }
            guard self.datePicker.date <= Date() else {
                AlertService.shared.showAlert(title: NSLocalizedString("error", comment: "Error alert title"), message: NSLocalizedString("cant_do_tracker_in_future", comment: "Error alert message when trying to track in future day"), viewController: self, actions: [UIAlertAction(title: NSLocalizedString("sad_ok", comment: "button that dismisses an alert with sad text"), style: .default)])
                return
            }
            self.trackerStore.toggleRecord(for: tracker, for: self.datePicker.date)
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
        CGSize(width: (collectionView.bounds.width - Constants.leadingPadding - Constants.rightPadding - Constants.interItemSpacing) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier, for: indexPath) as? TrackerCategoryHeader
        header?.nameLabel.text = trackerStore.titleForSection(indexPath.section)
        return header ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 9 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}


extension TrackersListViewController: CreateHabitViewControllerDelegate {
    
    func createTracker(name: String, categoryName: String, schedule: [WeekDay], color: UIColor, emoji: String) {
        
        let tracker = Tracker(id: UUID(), name: name, emoji: emoji, color: color, schedule: schedule)
        trackerStore.addTracker(tracker, toCategoryWithName: categoryName)
    }
    
}

extension TrackersListViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            if !update.deletedSections.isEmpty {
                collectionView.deleteSections(update.deletedSections)
            }
            if !update.insertedSections.isEmpty {
                collectionView.insertSections(update.insertedSections)
            }
            
            if !update.inserted.isEmpty {
                collectionView.insertItems(at: update.inserted)
            }
            if !update.deleted.isEmpty {
                collectionView.deleteItems(at: update.deleted)
            }
            if !update.updated.isEmpty {
                collectionView.reloadItems(at: update.updated)
            }
            for move in update.moved {
                collectionView.moveItem(at: move.from, to: move.to)
            }
        } completion: { _ in
            self.starStackVisibilityCheck()
        }
    }

    func storeDidReloadData(_ store: TrackerStore) {
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
        self.starStackVisibilityCheck()
    }
}
