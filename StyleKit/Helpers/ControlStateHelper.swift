import Foundation

struct ControlStateHelper {
    
    static func parseControlState(state: String) -> UInt {
        
        switch state {
        case "normal": return UIControlState.Normal.rawValue
        case "focused": return UIControlState.Focused.rawValue
        case "highlighted": return UIControlState.Highlighted.rawValue
        case "disabled": return UIControlState.Disabled.rawValue
        case "application": return UIControlState.Application.rawValue
        case "reserved": return UIControlState.Reserved.rawValue
        default: return UIControlState.Normal.rawValue
        }
        
    }
    
}