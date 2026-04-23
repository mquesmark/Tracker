import UIKit

final class StatCell: UICollectionViewCell {
    static let reuseID = "StatCell"

    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = false
        return v
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .blackDay
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .blackDay
        l.numberOfLines = 1
        return l
    }()

    private let gradient = CAGradientLayer()
    private let strokeMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        addSubview(container)
        container.addSubview(valueLabel)
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
        ])

        // Gradient border setup
        gradient.colors = [
            UIColor(red: 253/255, green: 76/255,  blue: 73/255,  alpha: 1).cgColor,
            UIColor(red: 70/255,  green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 0/255,   green: 123/255, blue: 250/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        container.layer.addSublayer(gradient)

        strokeMask.lineWidth = 1
        strokeMask.lineCap = .round
        strokeMask.lineJoin = .round
        strokeMask.fillColor = UIColor.clear.cgColor
        strokeMask.strokeColor = UIColor.black.cgColor // color is taken from gradient via mask
        gradient.mask = strokeMask
        gradient.zPosition = 1
        gradient.needsDisplayOnBoundsChange = true
        strokeMask.needsDisplayOnBoundsChange = true
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = container.bounds
        strokeMask.frame = gradient.bounds
        let inset: CGFloat = 1
        let path = UIBezierPath(roundedRect: container.bounds.insetBy(dx: inset, dy: inset), cornerRadius: 16)
        strokeMask.path = path.cgPath
    }

    func configure(value: Int, subtitle: String) {
        valueLabel.text = String(value)
        subtitleLabel.text = subtitle
    }
}
