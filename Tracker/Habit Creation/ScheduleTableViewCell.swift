import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func scheduleCell(_ cell: ScheduleTableViewCell, didChangeSwitchValueTo isTrue: Bool)
}

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCell"

    weak var delegate: ScheduleCellDelegate?
    
    let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor(
            red: 55.0/255.0,
            green: 114.0/255.0,
            blue: 231.0/255.0,
            alpha: 1.0
        )
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
