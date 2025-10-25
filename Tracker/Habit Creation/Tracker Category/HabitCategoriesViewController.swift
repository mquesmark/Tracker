import UIKit

final class HabitCategoriesViewController: UIViewController {
    
    var onCategoryPicked: ((TrackerCategory) -> Void)?
    
    private let viewModel = HabitCategoriesViewModel()
    private let tableView: UITableView = {
        let v = UITableView()
        v.rowHeight = 75
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - UI Elements
    
    private let topLabel: UILabel = {
        let l = UILabel()
        l.text = "Категория"
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = .blackDay
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .star))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let starText: UILabel = {
        let l = UILabel()
        l.text = "Привычки и события можно\nобъединить по смыслу"
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let starStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isHidden = true
        return sv
    }()
    
    private let button: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        b.backgroundColor = .blackDay
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.setTitle("Добавить категорию", for: .normal)
        b.setTitleColor(.whiteDay, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupStarStackView()
        bindViewModel()
        viewModel.viewDidLoad()

    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()

            self.starStackView.isHidden = self.viewModel.countOfCategories > 0
        }
        
        viewModel.onCategoryPicked = { [weak self] category in
            self?.onCategoryPicked?(category)
            self?.dismiss(animated: true)
        }
    }
    // MARK: - User Action Handlers
    
    private func addCategoryTapped() {
        let vc = NewCategoryViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.onCategorySaved = { [weak self] in
            self?.viewModel.reloadCategories()
        }
        present(vc, animated: true)
    }
    
    // MARK: - UI Setup
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HabitCategoriesTableViewCell.self, forCellReuseIdentifier: HabitCategoriesTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .whiteDay
        view.addSubview(topLabel)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        
        ])
        
        button.addAction(UIAction{ [weak self] _ in
            self?.addCategoryTapped()
        }, for: .touchUpInside)
    }
    
    private func setupStarStackView() {
        view.addSubview(starStackView)
        starStackView.addArrangedSubview(starImageView)
        starStackView.addArrangedSubview(starText)
        
        NSLayoutConstraint.activate([
            starStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            starStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            starStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

extension HabitCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.countOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitCategoriesTableViewCell.reuseIdentifier, for: indexPath) as? HabitCategoriesTableViewCell ?? HabitCategoriesTableViewCell()
        let name = viewModel.categoryName(at: indexPath.row)
        let isSelected = viewModel.isSelectedCategory(at: indexPath.row)
        cell.configure(title: name, isSelected: isSelected)
        
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if totalRows == 1 {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else if indexPath.row == 0 {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == totalRows - 1 {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        }
        return cell
    }
}

extension HabitCategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.userSelectedCategory(at: indexPath.row)
    }
}
