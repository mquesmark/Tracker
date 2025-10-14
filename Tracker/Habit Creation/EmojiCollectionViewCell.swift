import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionViewCell"
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .ypLightGray : .clear
        }
    }
    var onSelection: (() -> Void)?
    
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
