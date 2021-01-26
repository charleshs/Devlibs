#if os(iOS) || os(tvOS)
import UIKit

extension UIView {
    /// Gets the view's parent view controller (if exists).
    public var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            guard let viewController = parentResponder as? UIViewController else {
                parentResponder = responder.next
                continue
            }
            return viewController
        }
        return nil
    }

    public func anchorEdges(to reference: UIView, margins: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: reference.topAnchor, constant: margins.top),
            leadingAnchor.constraint(equalTo: reference.leadingAnchor, constant: margins.left),
            reference.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margins.right),
            reference.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margins.bottom),
        ])
    }

    public func anchorEdges(to reference: UILayoutGuide, margins: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: reference.topAnchor, constant: margins.top),
            leadingAnchor.constraint(equalTo: reference.leadingAnchor, constant: margins.left),
            reference.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margins.right),
            reference.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margins.bottom),
        ])
    }
}

// MARK: - Transform & Animation

extension UIView {
    public static let kAnimationDuration: TimeInterval = 1.0

    /// A property that determines if the view is opaque or fully transparent.
    ///
    /// If `true`, the property `isOpaque` is (set to) false and `alpha` is (set to) 1.0.
    ///
    /// If `false`, the property `isOpaque` is (set to) true and `alpha` is (set to) 0.0.
    public var isTransparent: Bool {
        get {
            return !isOpaque && alpha == .zero
        }
        set(isTransparent) {
            isOpaque = !isTransparent
            alpha = isTransparent ? .zero : 1.0
        }
    }

    public enum Animation {
        case none
        case linear(_ duration: TimeInterval = kAnimationDuration)
        case easeInOut(_ duration: TimeInterval = kAnimationDuration)

        public var duration: TimeInterval {
            switch self {
            case .none: return 0
            case .linear(let duration), .easeInOut(let duration): return duration
            }
        }

        public var options: AnimationOptions {
            switch self {
            case .none: return []
            case .linear: return .curveLinear
            case .easeInOut: return .curveEaseInOut
            }
        }
    }

    public enum Angle {
        case degrees(CGFloat)
        case radians(CGFloat)

        public var degrees: CGFloat {
            switch self {
            case .degrees(let value): return value
            case .radians(let value): return value * 180.0 / .pi
            }
        }

        public var radians: CGFloat {
            switch self {
            case .degrees(let value): return value * .pi / 180.0
            case .radians(let value): return value
            }
        }
    }

    public enum Axis {
        case horizontal
        case vertical
    }

    public func fadeIn(duration: TimeInterval = kAnimationDuration, completion: ((Bool) -> Void)? = nil) {
        isTransparent = true
        UIView.animate(
            withDuration: duration,
            animations: {
                self.isTransparent = false
            },
            completion: completion
        )
    }

    public func fadeOut(duration: TimeInterval = kAnimationDuration, completion: ((Bool) -> Void)? = nil) {
        isTransparent = false
        UIView.animate(
            withDuration: duration,
            animations: {
                self.isTransparent = true
            },
            completion: completion
        )
    }

    public func rotate(by angle: Angle, animation: Animation = .none, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animation.duration,
            delay: .zero,
            options: animation.options,
            animations: {
                self.transform = self.transform.rotated(by: angle.radians)
            },
            completion: completion
        )
    }

    public func translate(by vector: CGPoint, animation: Animation = .none, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animation.duration,
            delay: .zero,
            options: animation.options,
            animations: {
                self.transform = self.transform.concatenating(CGAffineTransform(translationX: vector.x, y: vector.y))
            },
            completion: completion
        )
    }

    public func reset(animation: Animation = .none, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animation.duration,
            delay: .zero,
            options: animation.options,
            animations: {
                self.transform = .identity
            },
            completion: completion
        )
    }

    public func flip(axis: Axis, animation: Animation = .none, completion: ((Bool) -> Void)? = nil) {
        let transform = axis == .horizontal
            ? self.transform.scaledBy(x: -1, y: 1)
            : self.transform.scaledBy(x: 1, y: -1)

        UIView.animate(
            withDuration: animation.duration,
            delay: .zero,
            options: animation.options,
            animations: {
                self.transform = transform
            },
            completion: completion
        )
    }
}
#endif
