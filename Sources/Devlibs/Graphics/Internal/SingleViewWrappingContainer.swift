#if os(iOS) || os(tvOS)
import UIKit

internal protocol SingleViewWrappingContainer: UIView {
    /// Top constraint of the single view relative to the container.
    var wrappedViewTopConstraint: NSLayoutConstraint! { get set }
    /// Left constraint of the single view relative to the container.
    var wrappedViewLeftConstraint: NSLayoutConstraint! { get set }
    /// Right constraint of the single view relative to the container.
    var wrappedViewRightConstraint: NSLayoutConstraint! { get set }
    /// Bottom constraint of the single view relative to the container.
    var wrappedViewBottomConstraint: NSLayoutConstraint! { get set }
}

extension SingleViewWrappingContainer {
    /// Adds the child view to the parent view and activates four-side constraints relative to the parent.
    /// - Parameters:
    ///   - child: The child view to be added.
    ///   - parent: The parent view the child is added to.
    internal func paste(child: UIView, toParent parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)

        wrappedViewTopConstraint = child.topAnchor.constraint(equalTo: parent.topAnchor)
        wrappedViewLeftConstraint = child.leftAnchor.constraint(equalTo: parent.leftAnchor)
        wrappedViewRightConstraint = parent.rightAnchor.constraint(equalTo: child.rightAnchor)
        wrappedViewBottomConstraint = parent.bottomAnchor.constraint(equalTo: child.bottomAnchor)

        NSLayoutConstraint.activate([
            wrappedViewTopConstraint,
            wrappedViewLeftConstraint,
            wrappedViewRightConstraint,
            wrappedViewBottomConstraint,
        ])
    }

    /// Adjusts the insets equally on four sides of the managed content view.
    /// - Parameter padding: The amount to be set as insets.
    internal func adjust(padding: CGFloat) {
        adjust(insets: UIEdgeInsets(amount: padding))
    }

    /// Adjusts the insets of the managed content view.
    /// - Parameter insets: The insets value of type `UIEdgeInsets`.
    internal func adjust(insets: UIEdgeInsets) {
        wrappedViewTopConstraint.constant = insets.top
        wrappedViewLeftConstraint.constant = insets.left
        wrappedViewRightConstraint.constant = insets.right
        wrappedViewBottomConstraint.constant = insets.bottom
    }
}

private extension UIEdgeInsets {
    init(amount: CGFloat) {
        self.init(top: amount, left: amount, bottom: amount, right: amount)
    }
}
#endif
