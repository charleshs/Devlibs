#if os(iOS) || os(tvOS)
import UIKit

/// Provides convenient functions that work with xib files.
public protocol NibLoadable {
    static var nibName: String { get }
    static var nib: UINib { get }
    static var bundle: Bundle { get }
}

extension NibLoadable where Self: AnyObject {
    public static var nibName: String {
        return String(describing: self)
    }

    public static var bundle: Bundle {
        return Bundle(for: self)
    }

    public static var nib: UINib {
        return UINib(nibName: nibName, bundle: bundle)
    }
}

extension NibLoadable where Self: UIView {
    public static func initFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expects its root view to be of type \(self)")
        }
        return view
    }
}

extension NibLoadable where Self: UIViewController {
    public static func initFromNib() -> Self {
        return Self.init(nibName: nibName, bundle: bundle)
    }
}
#endif
