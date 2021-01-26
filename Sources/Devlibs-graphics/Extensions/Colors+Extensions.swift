import CoreGraphics

#if canImport(UIKit)
import UIKit
public typealias Color = UIColor
#elseif canImport(Cocoa)
import Cocoa
public typealias Color = NSColor
#endif

extension Color {
    /// 1.0 white, 0.0 alpha
    public static var whiteClear: Color {
        return Color(white: 1.0, alpha: 0.0)
    }

    /// Returns a random color.
    public static var random: Color {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return Color(red: red, green: green, blue: blue)!
    }

    /// Creates a color object using RGB component integer values ranging from 0 to 255 and the specified opacity.
    public convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard (0...255) ~= red,
              (0...255) ~= green,
              (0...255) ~= blue
        else { return nil }

        let alpha = min(max(transparency, 0), 1)
        self.init(red: red.cgFloat / 255, green: green.cgFloat / 255, blue: blue.cgFloat / 255, alpha: alpha)
    }

    /// Creates a color object using a hex representation and the specified opacity.
    public convenience init?(hexString: String, transparency: CGFloat = 1) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string = hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }

        if string.count == 3 {
            // convert hex to 6 digit format if in short format
            string = string.reduce(into: "") { str, char in
                str.append(String(repeating: char, count: 2))
            }
        }

        guard let hexValue = Int(string, radix: 16) else { return nil }

        let alpha = min(max(transparency, 0), 1)
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF

        self.init(red: red, green: green, blue: blue, transparency: alpha)
    }

    /// Returns a color darker than the current one by a certain amount of percentage.
    /// - Parameter percentage: A value (from 0 to 1) representing the darkening scale.
    public func darkened(by percentage: CGFloat = 0.2) -> Color {
        let components = rgbaComponents()

        return Color(
            red: max(components.red - percentage, 1),
            green: max(components.green - percentage, 1),
            blue: max(components.blue - percentage, 1),
            alpha: components.alpha
        )
    }

    /// Returns a color lighter than the current one by a certain amount of percentage.
    /// - Parameter percentage: A value (from 0 to 1) representing the lightening scale.
    public func lightened(by percentage: CGFloat = 0.2) -> Color {
        let components = rgbaComponents()

        return Color(
            red: max(components.red + percentage, 1),
            green: max(components.green + percentage, 1),
            blue: max(components.blue + percentage, 1),
            alpha: components.alpha
        )
    }

    private func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red = CGFloat.zero
        var green = CGFloat.zero
        var blue = CGFloat.zero
        var alpha = CGFloat.zero

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
