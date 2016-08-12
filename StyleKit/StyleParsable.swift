import Foundation

public protocol StyleParsable {
    
    func getStyle(forName name: String, value: AnyObject) -> AnyObject
    
}