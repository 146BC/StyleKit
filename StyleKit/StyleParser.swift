import Foundation

class StyleParser: StyleParsable {
    
    func getStyle(forName name: String, value: AnyObject) -> AnyObject {
        
        if let value = value as? String {
            if let font = FontHelper.parseFont(value) {
                return font
            } else if let color = ColorHelper.parseColor(value) {
                return color
            } 
        } else if let value = value as? [String: Any] {
            if let paragraphStyle = ParagraphStyleHelper.parseParagraphStyle(name, value: value) {
                return paragraphStyle
            }
        }
        return value
        
    }
}
