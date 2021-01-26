import UIKit

struct AppRouter {
    func createTabBar() -> UIViewController {
        let viewControllers: [UIViewController] = [
            mainTable().embeddedInNavigation()
        ]

        return TabBarController().then {
            $0.setViewControllers(viewControllers, animated: false)
        }
    }

    func mainTable() -> UIViewController {
        return MainViewController(appRouter: self).then {
            $0.tabBarItem.title = "Main"
            $0.tabBarItem.image = UIImage(systemName: "house.fill")
        }
    }
    
    func componentGallery(_ view: UIView, layoutSize: ComponentViewController.LayoutSize = .natural) -> UIViewController {
        return ComponentViewController(component: view, layoutSize: layoutSize)
    }
}
