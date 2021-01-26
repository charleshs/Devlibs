#if !os(Linux)
import CoreGraphics
#endif

#if canImport(UIKit)
import UIKit.UIGeometry
#endif

public protocol Then {}

extension Then where Self: Any {
    /// Makes it available to execute something with closures.
    ///
    /// A simple example of the usage of `do` function:
    ///
    ///     UserDefaults.standard.do {
    ///         $0.set("foo123", forKey: "username")
    ///         $0.set("foo123@gmail.com", forKey: "email")
    ///         $0.synchronize()
    ///     }
    ///
    /// - Parameter expression: The closure that operates on the receiver
    public func `do`(_ expression: (Self) throws -> Void) rethrows {
        try expression(self)
    }

    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    /// A simple example of the usage of `with` function:
    ///
    ///     let frame = CGRect().with {
    ///         $0.origin.x = 10
    ///         $0.size.width = 100
    ///     }
    ///
    /// - Parameter configuration: The closure that configures the receiver
    /// - Returns: The post-configuration receiver
    public func with(_ configuration: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try configuration(&copy)
        return copy
    }
}

extension Then where Self: AnyObject {
    /// Makes it available to set properties with closures just after initializing.
    ///
    /// A simple example of the usage of `then` function:
    ///
    ///     let label = UILabel().then {
    ///         $0.textAlignment = .center
    ///         $0.textColor = UIColor.black
    ///         $0.text = "Hello, World!"
    ///     }
    ///
    /// - Parameter configure: The closure that configures the receiver
    /// - Returns: The post-configuration receiver
    public func then(_ configuration: (Self) throws -> Void) rethrows -> Self {
        try configuration(self)
        return self
    }
}

extension NSObject: Then {}
extension Array: Then {}
extension Dictionary: Then {}
extension Set: Then {}

#if !os(Linux)
extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
extension CGVector: Then {}
#endif

#if canImport(UIKit)
extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}
#endif
