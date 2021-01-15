import UIKit

struct AppRouter {
    func createTabBar() -> UIViewController {
        let viewControllers: [UIViewController] = [
            mainTableController()
        ]

        return TabBarController().then {
            $0.setViewControllers(viewControllers, animated: false)
        }
    }

    func mainTableController() -> UIViewController {
        return MainViewController(appRouter: self).then {
            $0.tabBarItem.title = "Main"
            $0.tabBarItem.image = UIImage(systemName: "house.fill")
        }
    }
}
