import XCTest
@testable import StyleKit

class JSONLoadTests: XCTestCase {
    
    func testSuccessLoad() {
        
        guard let styleFile = Bundle(for: type(of: self)).url(forResource: "success-style", withExtension: "json") else {
            XCTFail("Unable to find success-style.json file")
            return
        }
        
        XCTAssertNotNil(StyleKit(fileUrl: styleFile), "success-style.json failed")
        
    }
    
    func testFailLoad() {
        
        guard let styleFile = Bundle(for: type(of: self)).url(forResource: "fail-style", withExtension: "json") else {
            XCTFail("Unable to find fail-style.json file")
            return
        }
        
        XCTAssertNil(StyleKit(fileUrl: styleFile), "fail-style.json succeeded")
        
    }
    
}
