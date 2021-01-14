#if os(iOS) || os(tvOS)
import UIKit

public protocol Storyboarded {
    /// The storyboard which a view controller is loaded from. Use `Main.storyboard` if not specified.
    static var storyboard: UIStoryboard { get }
}

extension Storyboarded where Self: UIViewController {
    /// Refers to `Main.storyboard`.
    public static var storyboard: UIStoryboard {
        return .main
    }

    /// Loads a view controller from the specified storyboard.
    /// - Parameter identifier: A piece of string identifying the view controller. Use `String(describing: self)` if passing `nil`.
    /// - Returns: A view controller of the Storyboarded-conforming type.
    public static func initFromStoryboard(identifier: String? = nil) -> Self {
        let identifier = identifier ?? String(describing: self)

        if #available(iOS 13.0, tvOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: identifier) as! Self
        } else {
            return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        }
    }
}

private extension UIStoryboard {
    /// Representing `Main.storyboard`.
    static let main: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
}
#endif
