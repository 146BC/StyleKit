import Foundation

public class StyleKit {
    
    let stylist: Stylist
    
    public init?(fileUrl: URL, styleParser: StyleParsable? = nil, logLevel: SKLogLevel = .error) {
        let log = SKLogger.defaultInstance()
        log.setup(logLevel,
                  showLogIdentifier: false,
                  showFunctionName: true,
                  showThreadName: true,
                  showSKLogLevel: true,
                  showFileNames: true,
                  showLineNumbers: true,
                  showDate: false)
        
        let fileLoader = FileLoader.init(fileUrl: fileUrl)
        if let data = fileLoader.load() {
            self.stylist = Stylist.init(data: data, styleParser: styleParser)
        } else {
            return nil
        }
    }
    
    public func apply() {
        self.stylist.apply()
    }
    
}
