import Foundation

public class StyleKit {
    
    let stylist: Stylist
    
    public init?(fileUrl: URL, styleParser: StyleParsable? = nil, moduleName: String? = nil, logLevel: SKLogLevel = .error) {
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
            self.stylist = Stylist.init(data: data, styleParser: styleParser, moduleName: moduleName)
        } else {
            return nil
        }
    }
    
    public func apply() {
        self.stylist.apply()
    }
    
}
