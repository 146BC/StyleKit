import Foundation

class FileLoader {
    
    private let jsonFile: URL
    
    init(fileUrl: URL) {
        self.jsonFile = fileUrl
    }
    
    func load() -> [String:AnyObject]? {
        if let data = try? Data(contentsOf: jsonFile) {
            do {
                let contents = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = contents as? [String: AnyObject] {
                    return dictionary
                }
            } catch {
                SKLogger.severe("Issue parsing StyleKit JSON file: \(self.jsonFile)" )
            }
        }
        return nil
    }
    
}
