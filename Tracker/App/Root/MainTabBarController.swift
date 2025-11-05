import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        view.backgroundColor = .whiteDay
        let trackersVC = TrackersListViewController()
        let trackersNavVC = UINavigationController(rootViewController: trackersVC)
        trackersNavVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: "Trackers tab bar item title"),
            image: UIImage(resource: .trackers),
            tag: 0
        )

        let statisticsVC = StatisticsViewController()
        let statisticsNavVC = UINavigationController(rootViewController: statisticsVC)
        statisticsNavVC.navigationBar.prefersLargeTitles = true
        statisticsNavVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("stats", comment: "Statistics tab bar item title"),
            image: UIImage(resource: .statistics),
            tag: 1
        )

        viewControllers = [trackersNavVC, statisticsNavVC]
        tabBar.unselectedItemTintColor = .ypGray
    }
}
