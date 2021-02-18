#if os(iOS) || os(tvOS)
import UIKit

public final class GradientView: UIView {
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}

// MARK: - CAGradientLayer Mapping

extension GradientView {
    public var type: CAGradientLayerType {
        get { return gradientLayer.type }
        set { gradientLayer.type = newValue }
    }

    public var colors: [Any]? {
        get { return gradientLayer.colors }
        set { gradientLayer.colors = newValue }
    }

    public var locations: [NSNumber]? {
        get { return gradientLayer.locations }
        set { gradientLayer.locations = newValue }
    }

    public var startPoint: CGPoint {
        get { return gradientLayer.startPoint }
        set { gradientLayer.startPoint = newValue }
    }

    public var endPoint: CGPoint {
        get { return gradientLayer.endPoint }
        set { gradientLayer.endPoint = newValue }
    }
}
#endif
