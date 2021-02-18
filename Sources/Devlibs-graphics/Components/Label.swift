#if os(iOS) || os(tvOS)
import UIKit

/// A `UILabel` subclass that displays a text label with margins on each side.
open class Label: UILabel {
    @IBInspectable
    public final var insetTop: CGFloat {
        get { return textInsets.top }
        set { textInsets.top = newValue }
    }

    @IBInspectable
    public final var insetLeft: CGFloat {
        get { return textInsets.left }
        set { textInsets.left = newValue }
    }

    @IBInspectable
    public final var insetRight: CGFloat {
        get { return textInsets.right }
        set { textInsets.right = newValue }
    }

    @IBInspectable
    public final var insetBottom: CGFloat {
        get { return textInsets.bottom }
        set { textInsets.bottom = newValue }
    }

    /// The insets of the text from the boundaries. Defaults to zero point on each side.
    public var textInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - Overrides

extension Label {
    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override open func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= textInsets.left
        rect.origin.y -= textInsets.top
        rect.size.width += textInsets.width
        rect.size.height += textInsets.height
        return rect
    }
}

// MARK: Internal Extensions

private extension UIEdgeInsets {
    var width: CGFloat {
        return left + right
    }

    var height: CGFloat {
        return top + bottom
    }
}
#endif
