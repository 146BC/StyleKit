import Foundation

public struct FontHelper {
    
    public init() {}
    
    public func parseFont(font: String) -> UIFont? {
        
        let fontString = font.componentsSeparatedByString(":")
        if let size = NSNumberFormatter().numberFromString(fontString.last!) as? CGFloat {
            if fontString.count == 2 {
                if let font = UIFont(name: fontString.first!, size: size) {
                    return font
                } else {
                    loggingPrint("Font not found, using system font.")
                    return UIFont.systemFontOfSize(size)
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
    
}