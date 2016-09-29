import Foundation

struct ControlStateHelper {
    
    static func parseControlState(_ state: String) -> UInt {
        
        switch state {
        case "normal": return UIControlState().rawValue
        case "highlighted": return UIControlState.highlighted.rawValue
        case "disabled": return UIControlState.disabled.rawValue
        case "selected": return UIControlState.selected.rawValue
        case "focused":
            if #available(iOS 9.0, *) { return UIControlState.focused.rawValue }
            else { return UIControlState.highlighted.rawValue }
        case "application": return UIControlState.application.rawValue
        case "reserved": return UIControlState.reserved.rawValue
        default: return UIControlState().rawValue
        }
        
    }
    
}
