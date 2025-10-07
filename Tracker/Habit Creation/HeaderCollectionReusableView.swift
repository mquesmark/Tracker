import UIKit

final class HeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderCollectionReusableView"
    
    func configure(title: String) {
        label.text = title
    }
    
    private let label: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.textAlignment = .left
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = .blackDay
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    required init?(coder: NSCoder) { nil }
    
}
