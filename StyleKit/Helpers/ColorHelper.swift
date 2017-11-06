import Foundation

public struct ColorHelper {
    
    public static func parseColor(_ color: String) -> UIColor? {
        
        do {
            let colorRegex = try NSRegularExpression(pattern: "^#[0-9a-f]{8}|#[0-9a-f]{6}|#[0-9a-f]{3}$", options: .caseInsensitive)
            let validColor = colorRegex.firstMatch(in: color, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, color.count)) != nil
            if validColor {
                return UIColor(hexString: color)
            } else {
                return nil
            }
        } catch {
            return nil
        }
        
    }
    
}
