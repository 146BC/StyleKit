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
	
	@objc
    func setTransparency(_ alpha: NSNumber) {
        self.alpha = CGFloat(alpha.floatValue) / 100.0
    }
	
	@objc
    func setBackgroundColor(_ color: UIColor, forState state: UIControl.State) {
        backgroundColors[state.rawValue] = color
        
        if state == UIControl.State() {
            updateBackgroundColorForState(state)
        }
    }
    
    private func updateBackgroundColorForState(_ state: UIControl.State) {
        backgroundColor = backgroundColors[state.rawValue]
    }
}
