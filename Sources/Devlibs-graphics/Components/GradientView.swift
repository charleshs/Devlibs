#if os(iOS) || os(tvOS)
import UIKit

open class GradientView: UIView {
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}

extension GradientView {
    // MARK: - CAGradientLayer Mapping

    public var type: CAGradientLayerType {
        get { gradientLayer.type }
        set { gradientLayer.type = newValue }
    }

    public var colors: [Any]? {
        get { gradientLayer.colors }
        set { gradientLayer.colors = newValue }
    }

    public var locations: [NSNumber]? {
        get { gradientLayer.locations }
        set { gradientLayer.locations = newValue }
    }

    public var startPoint: CGPoint {
        get { gradientLayer.startPoint }
        set { gradientLayer.startPoint = newValue }
    }

    public var endPoint: CGPoint {
        get { gradientLayer.endPoint }
        set { gradientLayer.endPoint = newValue }
    }
}
#endif
