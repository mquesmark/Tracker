import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func scheduleCell(_ cell: ScheduleTableViewCell, didChangeSwitchValueTo isTrue: Bool)
}

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCell"

    weak var delegate: ScheduleCellDelegate?
    
    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor(
            red: 55.0/255.0,
            green: 114.0/255.0,
            blue: 231.0/255.0,
            alpha: 1.0
        )
        switchView.tintColor = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 1.0) // #E6E8EB
            } else {
                return .clear
            }
        }
        switchView.backgroundColor = switchView.tintColor
        switchView.layer.cornerRadius = switchView.bounds.height / 2
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupViews()
        switchView.addAction(UIAction{ [weak self] _ in
            guard let self else { return }
            self.delegate?.scheduleCell(self, didChangeSwitchValueTo: switchView.isOn)
        }, for: .valueChanged)
    }

    required init?(coder: NSCoder) { nil }
    
    func setWeekDay(to weekDay: WeekDay) {
        dayOfWeekLabel.text = weekDay.title
    }
    
    func setSwitch(to value: Bool) {
        switchView.isOn = value
    }
    private func setupViews() {
        contentView.backgroundColor = .backgroundDay
        contentView.addSubview(dayOfWeekLabel)
        contentView.addSubview(switchView)
        
        NSLayoutConstraint.activate([
            dayOfWeekLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayOfWeekLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
