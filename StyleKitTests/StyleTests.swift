import XCTest
import UIKit
@testable import StyleKit

class StyleTests: XCTestCase {
    
    let viewController = UIViewController()
    let skView = SKView()
    let skButton = SKButton()
    let skLabel = SKLabel()
    let label = UILabel()
    let navigationBar = UINavigationBar()
    let button = UIButton()
    
    let scrollView = UIScrollView()
    let nestedLabel = UILabel()
    let nestedSKView = SKView()
    let nestedSKLabel = SKLabel()
    
    var loaded = false
    
    func loadStyles() {
        if let styleFile = Bundle(for: type(of: self)).url(forResource: "style", withExtension: "json") {
            guard let styleKit = StyleKit(fileUrl: styleFile) else {
                XCTFail("Unable to load style.json file")
                return
            }
            styleKit.apply()
            loaded = true
        } else {
            XCTFail("Unable to find style.json file")
        }
    }
    
    override func setUp() {
        
        if !loaded {
            loadStyles()
            
            viewController.view.addSubview(skView)
            viewController.view.addSubview(skButton)
            viewController.view.addSubview(skLabel)
            viewController.view.addSubview(label)
            viewController.view.addSubview(navigationBar)
            viewController.view.addSubview(button)
            viewController.view.addSubview(scrollView)
            
            nestedSKView.addSubview(nestedSKLabel)
            scrollView.addSubview(nestedSKView)
            scrollView.addSubview(nestedLabel)
            
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
    }
    
    func testBasicComponents() {
        
        // UINavigationBar
        XCTAssertEqual(navigationBar.tintColor, UIColor(hexString: "#000"))
        
        if let navigationBarColor = navigationBar.titleTextAttributes?["NSColor"] as? UIColor {
            XCTAssertEqual(navigationBarColor, UIColor(hexString: "#FF000000"))
        } else {
            XCTFail("Color not found in navigation")
        }
        
        if let navigationBarFont = navigationBar.titleTextAttributes?["NSFont"] as? UIFont {
            XCTAssertEqual(navigationBarFont.fontName, "HelveticaNeue-Light")
            XCTAssertEqual(navigationBarFont.pointSize, 18.0)
        } else {
            XCTFail("Font not found in navigation")
        }
        
        // UILabel
        XCTAssertEqual(label.font.fontName, "HelveticaNeue-Bold")
        XCTAssertEqual(label.font.pointSize, 15.0)
        XCTAssertEqual(label.textColor, UIColor(hexString: "#fff"))
        XCTAssertEqual(label.backgroundColor, UIColor(hexString: "#eee"))
        
        // UIButton
        XCTAssertEqual(button.titleLabel?.font.fontName, "HelveticaNeue-Medium")
        XCTAssertEqual(button.titleLabel?.font.pointSize, 13.0)
        XCTAssertEqual(button.titleColor(for: .normal), UIColor(hexString: "#FAA"))
        XCTAssertEqual(button.titleColor(for: .highlighted), UIColor(hexString: "#fff"))

    }
    
    func testExtendedComponents() {
        // SKButton
        XCTAssertEqual(skButton.titleLabel?.font.fontName, "HelveticaNeue-Light")
        XCTAssertEqual(skButton.titleLabel?.font.pointSize, 13.0)
        XCTAssertEqual(skButton.titleColor(for: .normal), UIColor(hexString: "#FAA"))
        XCTAssertEqual(skButton.titleColor(for: .highlighted), UIColor(hexString: "#000"))
        XCTAssertEqual(skButton.backgroundColor, UIColor(hexString: "#0F0"))
        XCTAssert(fabs(Float(skButton.alpha) - 0.7) < FLT_EPSILON)        
    }
    
}
