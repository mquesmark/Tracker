import UIKit

final class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let pages: [UIViewController] = [
        OnboardingViewController(page: 1),
        OnboardingViewController(page: 2)
    ]
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = 2
        pc.currentPageIndicatorTintColor = .blackDay
        pc.backgroundColor = .clear
        pc.isUserInteractionEnabled = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let button: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = .blackDay
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.titleLabel?.textColor = .whiteDay
        b.setTitle("Вот это технологии!", for: .normal)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
     }
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        setupUI()
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTapped()
        }, for: .touchUpInside)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = pages.firstIndex(of: viewController) else { return nil }
        var otherIndex: Int
        if vcIndex == 0 {
            otherIndex = 1
        } else {
            otherIndex = 0
        }
        return pages[otherIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = pages.firstIndex(of: viewController) else { return nil }
        var otherIndex: Int
        if vcIndex == 0 {
            otherIndex = 1
        } else {
            otherIndex = 0
        }
        return pages[otherIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = currentIndex
        }
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(button)
        view.addSubview(pageControl)
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func buttonTapped() {
        UserDefaults.standard.set(true, forKey: "onboardingSeen")
        dismiss(animated: true)
    }

}
