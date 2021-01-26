#if os(iOS) || os(tvOS)
import UIKit

/// `ContainerView` holds and displays another view with margins on each side. Consumed only by composition.
public final class ContainerView: UIView, SingleViewWrappingContainer {

    /// The view managed by the `ContainerView`.
    public var contentView: UIView? {
        willSet {
            contentView.map { $0.removeFromSuperview() }
        }
        didSet {
            guard let view = contentView else { return }
            renderContent(view)
        }
    }

    /// The insets of the `contentView` from the container's boundaries. Defaults to zero point on each side.
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            adjust(insets: contentInsets)
            invalidateIntrinsicContentSize()
        }
    }

    var wrappedViewTopConstraint: NSLayoutConstraint!
    var wrappedViewLeftConstraint: NSLayoutConstraint!
    var wrappedViewRightConstraint: NSLayoutConstraint!
    var wrappedViewBottomConstraint: NSLayoutConstraint!

    /// Creates an object of `ContainerView`.
    /// - Parameters:
    ///   - contentView: The view to be displayed in `ContainerView`.
    ///   - contentInsets: The insets of `contentView` from the container's boundaries.
    public convenience init(contentView: UIView, contentInsets: UIEdgeInsets) {
        self.init(frame: .zero)
        self.contentView = contentView
        self.contentInsets = contentInsets
        renderContent(contentView)
    }

    private func renderContent(_ view: UIView) {
        paste(child: view, toParent: self)
        adjust(insets: contentInsets)
    }
}
#endif
