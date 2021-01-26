#if os(iOS) || os(tvOS)
import UIKit
import Devlibs_core

extension UIViewController {
    /// The view controller that is capable of presenting another view controller.
    public var presentableViewController: UIViewController {
        return Array(sequence(first: self, next: \.presentedViewController)).last ?? self
    }

    /// Returns a `UINavigationController` with the receiver view controller to be`rootViewController`.
    /// - Parameter configuration: A configuration closure the navigation controller is passed to as argument.
    /// - Returns: The navigation controller casted as `UIViewController`.
    public func embeddedInNavigation(_ configuration: (UINavigationController) -> Void = { _ in }) -> UIViewController {
        let navController = UINavigationController(rootViewController: self)
        configuration(navController)
        return navController
    }

    public func showAlert(forError error: Swift.Error, title: String = "Error", completion: @escaping () -> Void = {}) {
        showAlert(title: title, message: error.localizedDescription, completion: completion)
    }

    public func showAlert(title: String? = nil, message: String, completion: @escaping () -> Void = {}) {
        CallbackQueue.mainOtherwiseAsync.execute {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.presentableViewController.present(alert, animated: true, completion: completion)
        }
    }
}
#endif
