import Foundation

public struct FontHelper {
    
    public static func parseFont(_ font: String) -> UIFont? {
        
        let fontString = font.components(separatedBy: ":")
        if let size = NumberFormatter().number(from: fontString.last!) as? CGFloat {
            if fontString.count == 2 {
                if let font = UIFont(name: fontString.first!, size: size) {
                    return font
                } else {
                    SKLogger.error("Font \(font) not found, using system font.")
                    return UIFont.systemFont(ofSize: size)
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
    
}
