import UIKit

final class TrackerCategoryHeader: UICollectionReusableView {
    static let reuseIdentifier = "TrackerCategoryHeader"
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .blackDay
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(nameLabel)
        
    NSLayoutConstraint.activate([
        nameLabel.topAnchor.constraint(equalTo: topAnchor),
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
        nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
