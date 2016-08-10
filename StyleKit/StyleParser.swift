import Foundation

class StyleParser: StyleParsable {
    
    func getStyle(forName name: String, value: String) -> AnyObject? {
        
        if let font = FontHelper.parseFont(value) {
            return font
        } else if let color = ColorHelper.parseColor(value) {
            return color
        } else {
            return value
        }
        
    }
    
}