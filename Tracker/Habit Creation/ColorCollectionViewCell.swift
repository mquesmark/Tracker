import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }
    
    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.opacity = 0.3
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupUI() {
        colorView.backgroundColor = .green
        
        contentView.addSubview(colorView)
        contentView.addSubview(selectionView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
    }
    
    func config(color: UIColor) {
        colorView.backgroundColor = color
        selectionView.layer.borderColor = color.cgColor
    }
    
}
