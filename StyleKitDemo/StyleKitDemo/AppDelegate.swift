import UIKit
import StyleKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let styleFile = NSBundle.mainBundle().URLForResource("style", withExtension: "json")!
        StyleKit(fileUrl: styleFile)?.apply()
        
        return true
    }

}

