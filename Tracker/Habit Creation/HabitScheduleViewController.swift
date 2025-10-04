import UIKit
protocol HabitScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

final class HabitScheduleViewController: UIViewController {

    weak var delegate: HabitScheduleViewControllerDelegate?
    
    let days = WeekDay.allCases
    var preselectedDays: Set<WeekDay>? = nil
    var chosenDays: Set<WeekDay> = []
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tableView = UITableView()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.whiteDay, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        
        if let preselectedDays, !preselectedDays.isEmpty {
            chosenDays = preselectedDays
        } else {
            chosenDays = Set(WeekDay.allCases)
        }
        
        doneButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            delegate?.didSelectDays(chosenDays.sorted(by: { $0.rawValue < $1.rawValue}))
            dismiss(animated: true)
        }, for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didSelectDays(chosenDays.sorted(by: {$0.rawValue < $1.rawValue}))
    }
    
    private func setupUI() {
        view.backgroundColor = .whiteDay
        view.addSubview(topLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -39),
            tableView.leadingAnchor .constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension HabitScheduleViewController: UITableViewDelegate {
    
}

extension HabitScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath) as? ScheduleTableViewCell ?? ScheduleTableViewCell()
        cell.setWeekDay(to: days[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        
        if chosenDays.contains(days[indexPath.row]) {
            cell.setSwitch(to: true)
            
        }
        
        switch indexPath.row {
        case 0:
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case 6:
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top:0, left: tableView.bounds.width, bottom: 0, right: 0)
        default:
            break
        }
        return cell
    }
}

// MARK: - ScheduleCellDelegate
extension HabitScheduleViewController: ScheduleCellDelegate {
    func scheduleCell(_ cell: ScheduleTableViewCell, didChangeSwitchValueTo isTrue: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        handleSwitchToggle(for: days[indexPath.row], isOn: isTrue)
    }
    
    private func handleSwitchToggle(for day: WeekDay, isOn: Bool) {
        if isOn {
            chosenDays.insert(day)
        } else {
            chosenDays.remove(day)
        }
        print("ActiveDays: \(chosenDays.sorted { $0.rawValue < $1.rawValue }.map { $0.title })")
    }
}
