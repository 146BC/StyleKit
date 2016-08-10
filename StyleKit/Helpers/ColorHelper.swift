import Foundation

public struct ColorHelper {
    
    public static func parseColor(color: String) -> UIColor? {
        
        do {
            let colorRegex = try NSRegularExpression(pattern: "^#[0-9a-f]{6}|#[0-9a-f]{3}$", options: .CaseInsensitive)
            let validColor = colorRegex.firstMatchInString(color, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, color.characters.count)) != nil
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