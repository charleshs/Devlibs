#if os(iOS) || os(tvOS)
import UIKit

/// A view designated as a separator, with an intrinsic size of 1 pixel by 1 pixel.
public final class SeparatorLine: UIView {
    override public var intrinsicContentSize: CGSize {
        guard traitCollection.displayScale != 0 else {
            return CGSize(width: 1, height: 1)
        }
        let pixelSize = 1 / traitCollection.displayScale
        return CGSize(width: pixelSize, height: pixelSize)
    }

    /// The color of separator.
    public var separatorColor: UIColor? {
        get {
            backgroundColor
        }
        set {
            backgroundColor = newValue
        }
    }

    public convenience init(separatorColor: UIColor) {
        self.init(frame: .zero)
        self.separatorColor = separatorColor
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.displayScale != previousTraitCollection?.displayScale else { return }

        invalidateIntrinsicContentSize()
    }
}
#endif
