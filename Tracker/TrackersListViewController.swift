import UIKit

final class TrackersListViewController: UIViewController {
    
    private var isPlaceholderVisible: Bool = true
    

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
        tf.backgroundColor = .systemGray6
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()

    }

    @objc private func addTrackerButtonTapped() {

    }

    private func setupUI() {

        let addButton = UIBarButtonItem(
            title: nil,
            image: UIImage(resource: .addTracker),
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        addButton.tintColor = .blackDay
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        view.backgroundColor = .whiteDay
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(searchField)

        starStackView.axis = .vertical
        starStackView.spacing = 8
        starStackView.alignment = .center
        starStackView.translatesAutoresizingMaskIntoConstraints = false

        starStackView.addArrangedSubview(starImageView)
        starStackView.addArrangedSubview(starTextLabel)

        view.addSubview(starStackView)

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
        ])
    }

    private func showOrHidePlaceholder(isHidden: Bool) {
        if isHidden {
            starStackView.isHidden = true
        } else {
            starStackView.isHidden = false
        }
    }
}
