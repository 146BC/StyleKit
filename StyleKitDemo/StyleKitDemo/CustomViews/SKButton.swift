import Foundation
import UIKit

class SKButton: UIButton {
    
    private var backgroundColors: [UInt: UIColor] = [:]
    
    override var isSelected: Bool {
        didSet {
            updateBackgroundColorForState(state)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColorForState(state)
        }
    }
    
    func setTransparency(_ alpha: NSNumber) {
        self.alpha = CGFloat(alpha.floatValue) / 100.0
    }
    
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        backgroundColors[state.rawValue] = color
        
        if state == UIControlState() {
            updateBackgroundColorForState(state)
        }
    }
    
    private func updateBackgroundColorForState(_ state: UIControlState) {
        backgroundColor = backgroundColors[state.rawValue]
    }
}
