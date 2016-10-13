import Foundation
import UIKit

class SKLabel: UILabel {
 
    var padding: [CGFloat] = [0,0,0,0]
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: padding[0], left: padding[1], bottom: padding[2], right: padding[3])
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
}
