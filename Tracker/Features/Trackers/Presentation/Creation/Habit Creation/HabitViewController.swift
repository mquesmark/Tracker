
import UIKit

protocol HabitViewControllerDelegate: AnyObject {
    func createTracker(name: String, categoryName: String, schedule: [WeekDay], color: UIColor, emoji: String)
    func updateTracker(id: UUID, name: String, categoryName: String, schedule: [WeekDay], color: UIColor, emoji: String)
}

final class HabitViewController: UIViewController {
    
    // MARK: - Nested Types
    init(mode: Mode) {
        switch mode {
        case .create:
            self.mode = .create
        case .edit(let tracker, let days, let categoryName):
            self.mode = .edit(tracker: tracker, daysDone: days, categoryName: categoryName)
            self.prefill = (tracker, categoryName, days)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    enum Mode {
        case create
        case edit(tracker: Tracker, daysDone: Int, categoryName: String)
    }
    
    var prefill: (Tracker, String, Int)?
    
    private enum Constants {
        static let symbolsLimit = 38
    }
    
    // MARK: - Dependencies & State
    
    private var mode: Mode
    
    weak var delegate: HabitViewControllerDelegate?
    private var chosenDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private var category: TrackerCategory?
    
    private var scheduleSubtitleLabel: UILabel?
    private var categorySubtitleLabel: UILabel?
    
    private var showWarningAnimationStarted = false
    private var hideWarningAnimationStarted = false
    
    private let emojis: [String] = MockData.emojis
    private var chosenEmoji: String?
    
    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5,
        .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10,
        .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    private var chosenColor: UIColor?
    
    // MARK: - UI
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        return label
    }()
    
    
    private let streakLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .blackDay
        l.text = "0 дней"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let nameTextField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("habit_name_placeholder", comment: "Placeholder for habit name"),
            attributes: [.foregroundColor: UIColor.ypGray]
        )
        
        field.font = .systemFont(ofSize: 17, weight: .regular)
        field.textColor = .blackDay
        field.borderStyle = .none
        field.backgroundColor = .backgroundDay
        field.layer.cornerRadius = 16
        field.clipsToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()
    
    private let symbolsLimitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = String(format: NSLocalizedString("symbols_limit", comment: "Text field symbols limit"), Constants.symbolsLimit)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryButton = makeParameterButton(title: NSLocalizedString("category", comment: ""))
    private lazy var scheduleButton = makeParameterButton(title: NSLocalizedString("schedule", comment: ""))
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        return collection
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        return collection
    }()
    
    private let parametersView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.setTitle(NSLocalizedString("cancel", comment: "Cancel button label"), for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 0
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let bottomButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        stackViewSetup()
        setupBottomButtonsStackView()
        setPrimaryButtonEnabled(false)
        setupHideKeyboard()
        setupEmojiCollectionView()
        setupColorCollectionView()
        if case .edit = mode {
            configure()
        }
        
        nameTextField.addAction(UIAction { [weak self] _ in
            self?.checkSymbolsLimit()
            self?.updateFormValidity()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self?.checkSymbolsLimit()
            }) // Повторный запуск проверки, если вдруг анимации наложились
        }, for: .editingChanged)
        updateScheduleSubtitle(with: chosenDays)
        

    }
    
    // MARK: - Actions
    private func categoryButtonTapped() {
        let viewModel = HabitCategoriesViewModel()
        let vc = HabitCategoriesViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .pageSheet
        vc.onCategoryPicked = { [weak self] category in
            self?.userPickedCategory(category)
        }
        present(vc, animated: true)
    }
    
    private func userPickedCategory(_ category: TrackerCategory) {
        self.category = category
        updateCategorySubtitle(with: category)
        updateFormValidity()
    }
    
    private func scheduleButtonTapped() {
        let vc = HabitScheduleViewController()
        vc.preselectedDays = Set(chosenDays)
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func primaryButtonTapped() {
        guard let chosenEmoji, let chosenColor, let name = nameTextField.text, let categoryName = category?.name else { return }
        primaryButton.isUserInteractionEnabled = false
        switch mode {
        case .create:
            delegate?.createTracker(name: name, categoryName: categoryName, schedule: chosenDays, color: chosenColor, emoji: chosenEmoji)
        case .edit(let tracker, _, _):
            delegate?.updateTracker(
                id: tracker.id,
                name: name,
                categoryName: categoryName,
                schedule: chosenDays,
                color: chosenColor,
                emoji: chosenEmoji
            )
        }
        dismiss(animated: true)
    }
    
    // MARK: - Keyboard
    private func setupHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let isEditMode: Bool
        switch mode {
        case .edit:
            isEditMode = true
        default:
            isEditMode = false
        }
        
        // Заголовок экрана
        let titleText = isEditMode
        ? NSLocalizedString("edit_habit", comment: "Edit Habit Title")
        : NSLocalizedString("new_habit", comment: "New Habit Title")
        
        titleLabel.text = titleText
        
        // Текст основной кнопки
        let primaryButtonTitle = isEditMode
        ? NSLocalizedString("save", comment: "Save button label")
        : NSLocalizedString("create", comment: "Create button label")
        primaryButton.setTitle(primaryButtonTitle, for: .normal)
        
        view.backgroundColor = .whiteDay
    }
    
    private func setupBottomButtonsStackView() {
        bottomButtonsStackView.addArrangedSubview(cancelButton)
        bottomButtonsStackView.addArrangedSubview(primaryButton)
        bottomButtonsStackView.spacing = 8
        
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        primaryButton.addAction(UIAction { [weak self] _ in
            self?.primaryButtonTapped()
        }, for: .touchUpInside)
    }
    
    private func setupParametersView() {
        parametersView.addSubview(categoryButton)
        parametersView.addSubview(scheduleButton)
        parametersView.addSubview(separator)
        
        parametersView.bringSubviewToFront(separator)
        
        NSLayoutConstraint.activate([
            categoryButton.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor),
            categoryButton.topAnchor.constraint(equalTo: parametersView.topAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: parametersView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: parametersView.trailingAnchor, constant: -16),
            separator.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            
            scheduleButton.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor),
            scheduleButton.bottomAnchor.constraint(equalTo: parametersView.bottomAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        categoryButton.addAction(UIAction { [weak self] _ in
            self?.categoryButtonTapped()
        }, for: .touchUpInside)
        scheduleButton.addAction(UIAction { [weak self] _ in
            self?.scheduleButtonTapped()
        }, for: .touchUpInside)
    }
    
    private func setupEmojiCollectionView() {
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.allowsSelection = true
        emojiCollectionView.allowsMultipleSelection = false
        emojiCollectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier)
    }
    
    private func setupColorCollectionView() {
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.allowsSelection = true
        colorCollectionView.allowsMultipleSelection = false
        colorCollectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier)
    }
    
    private func stackViewSetup() {
        stackView.addArrangedSubview(titleLabel)

        if case .edit = mode {
            stackView.addArrangedSubview(streakLabel)
            stackView.setCustomSpacing(38, after: streakLabel)
        }
            stackView.setCustomSpacing(38, after: titleLabel)

        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(symbolsLimitLabel)

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
        stackView.spacing = 24
        stackView.addArrangedSubview(parametersView)
        stackView.setCustomSpacing(32, after: parametersView)
        stackView.addArrangedSubview(emojiCollectionView)
        stackView.addArrangedSubview(colorCollectionView)
        NSLayoutConstraint.activate([
            parametersView.heightAnchor.constraint(equalToConstant: 151),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 156 + 18 + 24),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 156 + 18 + 24)
        ])
        setupParametersView()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(bottomButtonsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomButtonsStackView.topAnchor, constant: -8),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
        ])
        
    }
    
    private func makeParameterButton(title: String, sublabelText: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 0
        button.tintColor = .ypGray
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let sublabel = UILabel()
        sublabel.text = sublabelText
        sublabel.font = .systemFont(ofSize: 17, weight: .regular)
        sublabel.textColor = .ypGray
        
        if title == NSLocalizedString("schedule", comment: "") {
            scheduleSubtitleLabel = sublabel
        }
        if title == NSLocalizedString("category", comment: "") {
            categorySubtitleLabel = sublabel
        }
        
        let labelsStackView = UIStackView(arrangedSubviews: [label, sublabel])
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.spacing = 2
        labelsStackView.isUserInteractionEnabled = false
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .ypGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        
        let buttonStackView = UIStackView(arrangedSubviews: [labelsStackView, imageView])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .equalSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.isUserInteractionEnabled = false
        
        button.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: button.topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])
        
        return button
    }
    
    private func configure() {
        
        guard let prefill else { return }
        
        let tracker = prefill.0
        let categoryName: String = prefill.1
        
        let daysCompleted = prefill.2
        
        let format = NSLocalizedString("days_count", comment: "Count of days when tracker was completed")
        streakLabel.text = String.localizedStringWithFormat(format, daysCompleted)
        
        // Prefill basic fields
        nameTextField.text = tracker.name
        
        // Schedule
        chosenDays = tracker.schedule
        updateScheduleSubtitle(with: chosenDays)
        
        // Emoji & Color values for validation
        chosenEmoji = tracker.emoji
        chosenColor = tracker.color
        
        // Also set category and update subtitle
        self.category = TrackerCategory(name: categoryName, trackers: [])
        updateCategorySubtitle(with: category)
        
        // Reload collections before selecting items to ensure cells exist
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        // Select emoji item if found
        if let emoji = chosenEmoji, let emojiIndex = emojis.firstIndex(of: emoji) {
            let ip = IndexPath(item: emojiIndex, section: 0)
            emojiCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }
        
        // Select color item if found
        if let color = chosenColor, let colorIndex = colors.firstIndex(of: color) {
            let ip = IndexPath(item: colorIndex, section: 0)
            colorCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }
        
        // Re-evaluate create/save button availability
        updateFormValidity()
    }
    // MARK: - Helpers
    private func updateScheduleSubtitle(with days: [WeekDay]) {
        if days.isEmpty {
            scheduleSubtitleLabel?.text = nil
        } else {
            
            let daysTitles = days.map { $0.titleShort }
            if daysTitles.count == 7 {
                scheduleSubtitleLabel?.text = NSLocalizedString("every_day", comment: "Every Day schedule")
            } else {
                scheduleSubtitleLabel?.text = daysTitles.joined(separator: ", ")
            }
        }
    }
    
    private func updateCategorySubtitle(with category: TrackerCategory?) {
        if category == nil {
            categorySubtitleLabel?.text = nil
        } else {
            categorySubtitleLabel?.text = category?.name ?? ""
        }
    }
    
    private func updateFormValidity() {
        let nameValid = !(nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let categoryValid = (category != nil)
        let scheduleValid = !chosenDays.isEmpty
        
        let emojiValid: Bool = {
            guard let chosenEmoji else { return false }
            return emojis.contains(chosenEmoji)
        }()
        
        let colorValid: Bool = {
            guard let chosenColor else { return false }
            return colors.contains(chosenColor)
        }()
        
        let formValid = nameValid && categoryValid && scheduleValid && emojiValid && colorValid
        setPrimaryButtonEnabled(formValid)
    }
    
    
    func checkSymbolsLimit() {
        let symbolsCount = nameTextField.text?.count ?? 0
        symbolsCount > Constants.symbolsLimit ? showSymbolsLimitLabel() : hideSymbolsLimitLabel()
    }
    
    private func setPrimaryButtonEnabled(_ enabled: Bool) {
        primaryButton.isUserInteractionEnabled = enabled
        primaryButton.backgroundColor = enabled ? .blackDay : .ypGray


        let titleColor = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return enabled ? .whiteDay : .white
            } else {
                return .whiteDay
            }
        }
        primaryButton.setTitleColor(titleColor, for: .normal)
    }
    
    private func showSymbolsLimitLabel() {
        guard !showWarningAnimationStarted && symbolsLimitLabel.isHidden && !hideWarningAnimationStarted else { return }
        showWarningAnimationStarted = true
        symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        symbolsLimitLabel.alpha = 0
        symbolsLimitLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.symbolsLimitLabel.transform = .identity
            self.symbolsLimitLabel.alpha = 1
            self.stackView.setCustomSpacing(32, after: self.symbolsLimitLabel)
            self.stackView.setCustomSpacing(8, after: self.nameTextField)
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.showWarningAnimationStarted = false
        })
    }
    
    private func hideSymbolsLimitLabel() {
        guard !hideWarningAnimationStarted && !symbolsLimitLabel.isHidden && !showWarningAnimationStarted else { return }
        hideWarningAnimationStarted = true
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self else { return }
            self.symbolsLimitLabel.alpha = 0
            self.symbolsLimitLabel.isHidden = true
            self.symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            self.stackView.setCustomSpacing(24, after: self.nameTextField)
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            guard let self else { return }
            self.symbolsLimitLabel.isHidden = true
            self.symbolsLimitLabel.transform = .identity
            self.hideWarningAnimationStarted = false
        }
        
    }
}

// MARK: - HabitScheduleViewControllerDelegate
extension HabitViewController: HabitScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        chosenDays = days
        updateScheduleSubtitle(with: days)
        updateFormValidity()
    }
}

// MARK: - UICollectionViewDataSource
extension HabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count
        : collectionView == colorCollectionView ? colors.count
        : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = emojiCollectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell ?? EmojiCollectionViewCell()
            let indexPathRow = indexPath.row
            let cellEmoji = emojis[indexPathRow]
            cell.configure(emoji: cellEmoji)
            return cell
        } else if collectionView == colorCollectionView {
            let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell ?? ColorCollectionViewCell()
            let color = colors[indexPath.row]
            cell.config(color: color)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojiCollectionView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier, for: indexPath) as? HeaderCollectionReusableView ?? HeaderCollectionReusableView()
            header.configure(title: "Emoji")
            return header
        } else if collectionView == colorCollectionView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier, for: indexPath) as? HeaderCollectionReusableView ?? HeaderCollectionReusableView()
            header.configure(title: NSLocalizedString("color", comment: "Color header"))
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate
extension HabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            chosenEmoji = emojis[indexPath.row]
            updateFormValidity()
        } else if collectionView == colorCollectionView {
            chosenColor = colors[indexPath.row]
            updateFormValidity()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { CGSize(width: collectionView.bounds.width, height: 18) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}
