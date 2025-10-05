import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        let trackersVC = TrackersListViewController()
        let trackersNavVC = UINavigationController(rootViewController: trackersVC)
        trackersNavVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackers),
            tag: 0
        )

        let statisticsVC = StatisticsViewController()
        let statisticsNavVC = UINavigationController(rootViewController: statisticsVC)
        statisticsNavVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statistics),
            tag: 1
        )

        viewControllers = [trackersNavVC, statisticsNavVC]
    }
}
