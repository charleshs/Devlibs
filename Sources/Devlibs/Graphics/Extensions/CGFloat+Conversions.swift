#if !os(Linux)
import CoreGraphics

extension BinaryInteger {
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension BinaryFloatingPoint {
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

#endif
