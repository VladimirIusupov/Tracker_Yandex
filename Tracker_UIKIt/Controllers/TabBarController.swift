import UIKit

final class TabBarController: UITabBarController {

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()

        let trackersListViewController = TrackersListViewController()
        let navigationController = UINavigationController(rootViewController: trackersListViewController)
        let statisticsViewController = StatisticsViewController()

        trackersListViewController.tabBarItem = UITabBarItem(
            title: L10n.Tabbar.trackers,
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: L10n.Tabbar.statistics,
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )

        self.viewControllers = [navigationController, statisticsViewController]
    }

    // MARK: - Override Methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tabBar.layer.borderColor = UIColor.ypTabbarBorder.cgColor
        }
    }

    // MARK: - Private Methods
    private func setUpTabBar() {
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.ypTabbarBorder.cgColor
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .ypWhite
        tabBar.barTintColor = .ypWhite
        tabBar.isTranslucent = false
    }
}
