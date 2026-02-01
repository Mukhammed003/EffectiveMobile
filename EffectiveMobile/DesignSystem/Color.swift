import UIKit

extension UIColor {
    // Creates color from a hex string
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
    
    static let whiteForText = UIColor(hexString: "#F4F4F4") 
    static let forViewBackground = UIColor(hexString: "#040404")
    static let forSearchFieldBackground = UIColor(hexString: "#272729")
    static let semiLightWhiteForText = whiteForText.withAlphaComponent(0.5)
    static let yellowForButtons = UIColor(hexString: "#FED702")
    static let grayForUnselectedButtons = UIColor(hexString: "#4D555E")
    static let redForCancelButton = UIColor(hexString: "#F56B6C")
    static let grayForCreateButton = UIColor(hexString: "#AEAFB4")
}

