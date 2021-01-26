#if os(iOS) || os(tvOS)
import UIKit

extension UIImage {
    /// Creates an image filled with a specified color. The size of the image is 1 pixel on both sides.
    /// - Parameter color: The color to fill the created image.
    public convenience init?(withColor color: UIColor) {
        let aPixel = 1 / UIScreen.main.scale
        let rect = CGRect(origin: .zero, size: CGSize(width: aPixel, height: aPixel))

        UIGraphicsBeginImageContextWithOptions(rect.size, color.cgColor.alpha == 1, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }

        self.init(cgImage: cgImage)
    }
}
#endif
