import UIKit

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: return NSLocalizedString("all_trackers", comment: "All trackers filter name")
        case .today: return NSLocalizedString("today_trackers", comment: "Trackers for today filter name")
        case .completed: return NSLocalizedString("completed_trackers", comment: "Completed trackers filter name")
        case .notCompleted: return NSLocalizedString("not_completed_trackers", comment: "Not completed trackers filter name")
        }
    }
}


final class FiltersViewController: UIViewController {
    
    private let availableFilters = [TrackerFilter.all, .today, .completed, .notCompleted]
    var selectedIndex: Int?
    
    var onFilterPicked: ((TrackerFilter) -> Void)?
    
    private let tableView: UITableView = {
        let v = UITableView()
        v.rowHeight = 75
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    init(selectedFilter: TrackerFilter? = .all, onFilterPicked: ((TrackerFilter) -> Void)? = nil) {
        self.onFilterPicked = onFilterPicked
        if let selectedFilter, let idx = availableFilters.firstIndex(of: selectedFilter) {
            self.selectedIndex = idx
        } else {
            self.selectedIndex = availableFilters.firstIndex(of: .all)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - UI Elements
    
    private let topLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("filters", comment: "Filters page title")
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = .blackDay
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .whiteDay
        view.addSubview(topLabel)
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ParametersTableViewCell.self, forCellReuseIdentifier: ParametersTableViewCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let selectedIndex, selectedIndex == indexPath.row {
            self.selectedIndex = nil
            tableView.reloadData()
            onFilterPicked?(.all)
            dismiss(animated: true)
            return
        }

        selectedIndex = indexPath.row
        tableView.reloadData()
        onFilterPicked?(availableFilters[indexPath.row])
        dismiss(animated: true)
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { availableFilters.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParametersTableViewCell.reuseIdentifier, for: indexPath) as? ParametersTableViewCell ?? ParametersTableViewCell()
        
        let name = availableFilters[indexPath.row].title
        
        var isSelected = false
        if let selectedIndex, selectedIndex == indexPath.row {
            isSelected = true
        }
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
