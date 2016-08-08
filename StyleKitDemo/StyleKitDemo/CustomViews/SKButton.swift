import Foundation
import UIKit

class SKButton: UIButton {
    
    internal var styleType = Type.Standard
    
    enum Type:String {
        case Standard = "standard"
        case Primary = "primary"
        case Secondary = "secondary"
    }
    
    private var backgroundColors: [UInt: UIColor] = [:]
    
    func setNormalBackgroundColor(color: UIColor) {
        backgroundColors[UIControlState.Normal.rawValue] = color
        stateDidChange(UIControlState.Normal)
    }
    
    func setHighlightedBackgroundColor(color: UIColor) {
        backgroundColors[UIControlState.Highlighted.rawValue] = color
    }
    
    func setStyle(type:String) {
        self.styleType = Type.init(rawValue: type)!
    }
    
    override var selected: Bool {
        didSet {
            stateDidChange(state)
        }
    }
    
    override var highlighted: Bool {
        didSet {
            stateDidChange(state)
        }
    }
    
    private func stateDidChange(state: UIControlState) {
        self.setTitle(styleType.rawValue, forState: state)
        updateBackgroundColorForState(state)
    }
    
    private func updateBackgroundColorForState(state: UIControlState) {
        backgroundColor = backgroundColors[state.rawValue]
    }
}