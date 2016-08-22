import Foundation

struct ControlStateHelper {
    
    static func parseControlState(state: String) -> UInt {
        
        switch state {
        case "normal": return UIControlState.Normal.rawValue
        case "highlighted": return UIControlState.Highlighted.rawValue
        case "disabled": return UIControlState.Disabled.rawValue
        case "selected": return UIControlState.Selected.rawValue
        case "focused":
            if #available(iOS 9.0, *) { return UIControlState.Focused.rawValue }
            else { return UIControlState.Highlighted.rawValue }
        case "application": return UIControlState.Application.rawValue
        case "reserved": return UIControlState.Reserved.rawValue
        default: return UIControlState.Normal.rawValue
        }
        
    }
    
}