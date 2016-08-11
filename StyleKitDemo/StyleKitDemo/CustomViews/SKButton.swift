import Foundation
import UIKit

class SKButton: UIButton {
    
    private var backgroundColors: [UInt: UIColor] = [:]
    
    override var selected: Bool {
        didSet {
            updateBackgroundColorForState(state)
        }
    }
    
    override var highlighted: Bool {
        didSet {
            updateBackgroundColorForState(state)
        }
    }
    
    func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        backgroundColors[state.rawValue] = color
        
        if state == UIControlState.Normal {
            updateBackgroundColorForState(state)
        }
    }
    
    private func updateBackgroundColorForState(state: UIControlState) {
        backgroundColor = backgroundColors[state.rawValue]
    }
}