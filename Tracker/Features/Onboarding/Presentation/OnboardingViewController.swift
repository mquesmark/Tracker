import UIKit

@MainActor
final class OnboardingViewController: UIViewController {
    
    var page: Int = 1
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder: NSCoder) { nil }
    
    init(page: Int = 1) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fillControllerBasedOnPage()
    }
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
    
    private func fillControllerBasedOnPage() {
        switch page {
        case 2:
            backgroundImageView.image = UIImage(resource: ._2)
            titleLabel.text = NSLocalizedString("even_if_this_not", comment: "Text describing what you can track part 2")
        default:
            backgroundImageView.image = UIImage(resource: ._1)
            titleLabel.text = NSLocalizedString("track_what_you_want", comment: "Text describing what you can track")
        }
        
    }
}

