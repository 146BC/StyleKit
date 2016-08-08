import Foundation

class SKFont {
    
    var name: String? = nil
    var size: CGFloat? = nil
    
    func getFont() -> UIFont? {
        if name != nil && size != nil {
            if let font = UIFont(name: name!, size: size!) {
                return font
            } else {
                loggingPrint("Font not found, using system font.")
                return UIFont.systemFontOfSize(size!)
            }
        } else if size != nil {
            return UIFont.systemFontOfSize(size!)
        } else {
            return nil
        }
    }
    
    func getNSFontAttribute() -> [String:UIFont]? {
        guard let font = getFont() else {
            return nil
        }
        
        return [NSFontAttributeName:font]
    }
}