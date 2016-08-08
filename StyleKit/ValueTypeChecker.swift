import Foundation

class ValueTypeChecker {
    
    typealias SKFontString = (name: String?, size: CGFloat?)
    
    func getStyleFromValue(value: String) -> AnyObject? {
        
        if let fontValues = parseFont(value) {
            let font = SKFont()
            font.name = fontValues.name
            font.size = fontValues.size
            return font.getFont()
        } else if let color = parseColor(value) {
            return color
        } else {
            return value
        }
        
    }
    
    private func parseFont(font: String) -> SKFontString? {
        
        let fontString = font.componentsSeparatedByString(":")
        if let number = NSNumberFormatter().numberFromString(fontString.last!) {
            if fontString.count == 2 {
                return (fontString.first, CGFloat(number))
            } else {
                return (nil, CGFloat(number))
            }
        } else {
            return nil
        }
        
    }
    
    private func parseColor(color: String) -> UIColor? {
        
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
    
    func parseControlState(state: String) -> UInt {
        
        switch state {
            case "normal": return UIControlState.Normal.rawValue
            case "focused": return UIControlState.Focused.rawValue
            case "highlighted": return UIControlState.Highlighted.rawValue
            case "disabled": return UIControlState.Disabled.rawValue
            case "application": return UIControlState.Application.rawValue
            case "reserved": return UIControlState.Reserved.rawValue
            default: return UIControlState.Normal.rawValue
        }
        
    }
    
}