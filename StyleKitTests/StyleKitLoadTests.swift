import XCTest
@testable import StyleKit

class StyleKitTests: XCTestCase {
    
    func testSuccessLoad() {
        
        guard let styleFile = NSBundle(forClass: self.dynamicType).URLForResource("success-style", withExtension: "json") else {
                XCTFail("Unable to find success-style.json file")
                return
        }
        
        XCTAssertNotNil(StyleKit(fileUrl: styleFile), "success-style.json failed")
        
    }
    
    func testFailLoad() {
        
        guard let styleFile = NSBundle(forClass: self.dynamicType).URLForResource("fail-style", withExtension: "json") else {
            XCTFail("Unable to find fail-style.json file")
            return
        }
        
        XCTAssertNil(StyleKit(fileUrl: styleFile), "fail-style.json succeeded")
        
    }
    
}
