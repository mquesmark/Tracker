import UIKit

final class HabitCategoriesTableViewCell: UITableViewCell {
    static let reuseIdentifier = "HabitCategoriesTableViewCell"
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.textColor = .blackDay
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let checkmarkImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .medium)
        let image = UIImage(systemName: "checkmark", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.backgroundColor = .backgroundDay
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
        checkmarkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    
    required init?(coder: NSCoder) { nil }
    
    
}
