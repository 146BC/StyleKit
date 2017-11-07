import Foundation
import UIKit

class SKLabel: UILabel {
    
    @objc dynamic var padding: [CGFloat] = [0,0,0,0]
    @objc dynamic var attributes: [NSAttributedStringKey: Any]? {
        didSet {
            updateAttributedText()
        }
    }

    override var text: String? {
        didSet {
            updateAttributedText()
        }
    }

    func updateAttributedText() {
        guard let string = attributedText?.string
            , let attributes = attributes else { return }
        attributedText = NSAttributedString(string: string, attributes: attributes)
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: padding[0], left: padding[1], bottom: padding[2], right: padding[3])
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
