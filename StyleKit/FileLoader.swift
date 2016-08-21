import Foundation

class FileLoader {
    
    private let jsonFile: NSURL
    
    init(fileUrl: NSURL) {
        self.jsonFile = fileUrl
    }
    
    func load() -> [String:AnyObject]? {
        if let data = NSData(contentsOfURL: jsonFile) {
            do {
                let contents = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                if let dictionary = contents as? [String: AnyObject] {
                    return dictionary
                }
            } catch {
                XCGLogger.defaultInstance().severe("Issue parsing StyleKit JSON file: \(self.jsonFile)" )
            }
        }
        return nil
    }
    
}
