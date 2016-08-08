import XCTest
@testable import StyleKit

class StyleKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let test = JSONHandler.init(filePath: "/Volumes/Stuff/Dropbox/Work/ThePropertyProject/server/app.js")
        debugPrint("-----------")
        test?.load()
        debugPrint("-----------")
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
