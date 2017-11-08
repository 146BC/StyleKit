import UIKit
import StyleKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let styleFile = Bundle.main.url(forResource: "style", withExtension: "json") {
            
            // Uses style parser within demo app
            //StyleKit(fileUrl: styleFile, styleParser: StyleParser())?.apply()
            
            // Uses default style parser
            StyleKit(fileUrl: styleFile, moduleName: "StyleKitDemo", logLevel: .debug)?.apply()
            
        }
        return true
    }

}

