import Foundation

public protocol StyleParsable {
    
    func getStyle(forName name: String, value: String) -> AnyObject?
    
}