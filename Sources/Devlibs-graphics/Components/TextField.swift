#if os(iOS) || os(tvOS)
import UIKit

/// A `UITextField` subclass that displays a text field with its text-editing area padded.
open class TextField: UITextField {
    @IBInspectable
    public final var insetTop: CGFloat {
        get {
            return textInsets.top
        }
        set(insetTop) {
            textInsets.top = insetTop
        }
    }

    @IBInspectable
    public final var insetLeft: CGFloat {
        get {
            return textInsets.left
        }
        set(insetLeft) {
            textInsets.left = insetLeft
        }
    }

    @IBInspectable
    public final var insetRight: CGFloat {
        get {
            return textInsets.right
        }
        set(insetRight) {
            textInsets.right = insetRight
        }
    }

    @IBInspectable
    public final var insetBottom: CGFloat {
        get {
            return textInsets.bottom
        }
        set(insetBottom) {
            textInsets.bottom = insetBottom
        }
    }

    /// The insets of the text-editing area from the boundaries. Defaults to zero point on each side.
    public var textInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

extension TextField {
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: textInsets)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
#endif
