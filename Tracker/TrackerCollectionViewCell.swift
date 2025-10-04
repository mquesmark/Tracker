import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.borderWidth = 1
        view.layer.borderColor = CGColor(red: 174.0/255.0, green: 175.0/255.0, blue: 180.0/255.0, alpha: 0.3)
        return view
    }()
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emojiPlatform: UIView = {
        let platform = UIView()
        platform.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        platform.layer.cornerRadius = 15
        platform.clipsToBounds = true
        platform.translatesAutoresizingMaskIntoConstraints = false
        return platform
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .whiteDay
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let streakLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1

        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .whiteDay
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
    return button
    }()
    
    var onPlusTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withTracker tracker: Tracker, isCompleted: Bool, daysCompleted: Int) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        streakLabel.text = daysWordDeclension(daysCompleted)
        cardView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color

        plusButton.addAction(UIAction { [weak self] _ in
            self?.onPlusTap?()
        }, for: .touchUpInside)
        configPlusButton(isCompleted: isCompleted)
    }
    
    func configPlusButton(isCompleted: Bool) {
        
        if isCompleted {
            let plusIconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .medium)
            plusButton.setPreferredSymbolConfiguration(plusIconConfig, forImageIn: .normal)
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.alpha = 0.3
            
        } else {
            let plusIconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold, scale: .small)
            plusButton.setPreferredSymbolConfiguration(plusIconConfig, forImageIn: .normal)
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.alpha = 1
        }
        
    }

    private func daysWordDeclension(_ days: Int) -> String {
        let lastTwo = days % 100
        let lastOne = days % 10
        
        if lastTwo >= 11 && lastTwo <= 14 {
            return "\(days) дней"
        }
        
        switch lastOne {
        case 1:
            return "\(days) день"
        case 2, 3, 4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }

    private func setupViews() {
        contentView.addSubview(cardView)
        contentView.addSubview(emojiPlatform)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(streakLabel)
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiPlatform.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiPlatform.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiPlatform.widthAnchor.constraint(equalToConstant: 30),
            emojiPlatform.heightAnchor.constraint(equalToConstant: 30),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiPlatform.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiPlatform.centerYAnchor),
            
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            streakLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            streakLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            plusButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: streakLabel.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
