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
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [navigationController, statisticsViewController]
    }

    // MARK: - Private Methods
    private func setUpTabBar() {
        let borderColor: UIColor = .ypGray
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = borderColor.cgColor

        self.tabBar.tintColor = .ypBlue
        self.tabBar.unselectedItemTintColor = .ypGray
        self.tabBar.backgroundColor = .ypWhite
        self.tabBar.barTintColor = .ypWhite
        self.tabBar.isTranslucent = false
    }
}
