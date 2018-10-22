import Foundation

struct ControlStateHelper {
    
    static func parseControlState(_ state: String) -> UInt {
        
        switch state {
        case "normal": return UIControl.State.normal.rawValue
        case "highlighted": return UIControl.State.highlighted.rawValue
        case "disabled": return UIControl.State.disabled.rawValue
        case "selected": return UIControl.State.selected.rawValue
        case "focused":
            if #available(iOS 9.0, *) { return UIControl.State.focused.rawValue }
            else { return UIControl.State.highlighted.rawValue }
        case "application": return UIControl.State.application.rawValue
        case "reserved": return UIControl.State.reserved.rawValue
        default: return UIControl.State.normal.rawValue
        }
        
    }
    
}
