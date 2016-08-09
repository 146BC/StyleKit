import XCTest
@testable import StyleKit

class HelperTests: XCTestCase {
    
    func testColorHelper() {
        
        guard let blackColor = ColorHelper().parseColor("#000000") else {
            XCTFail("ColorHelper should return UIColor")
            return
        }
        
        XCTAssert(blackColor.isEqual(UIColor(hexString:"#000000")),
                  "Color returned from ColorHelper should be black")
        
        // Testing color helper with bad color parameter
        
        XCTAssertNil(ColorHelper().parseColor("000000"),
                     "Color helper should return nil")
        
    }
    
    func testControlStateHelper() {
        
        XCTAssertEqual(ControlStateHelper().parseControlState("normal"),
                       UIControlState.Normal.rawValue)
        
        XCTAssertEqual(ControlStateHelper().parseControlState("disabled"),
                       UIControlState.Disabled.rawValue)
        
        XCTAssertEqual(ControlStateHelper().parseControlState("application"),
                       UIControlState.Application.rawValue)
        
        XCTAssertEqual(ControlStateHelper().parseControlState("focused"),
                       UIControlState.Focused.rawValue)
        
        XCTAssertEqual(ControlStateHelper().parseControlState("highlighted"),
                       UIControlState.Highlighted.rawValue)
        
        XCTAssertEqual(ControlStateHelper().parseControlState("reserved"),
                       UIControlState.Reserved.rawValue)
        
        XCTAssertEqual(ControlStateHelper().parseControlState("testfallback"),
                       UIControlState.Normal.rawValue)
        
    }
    
    func testFontHelper() {
        
        guard let helveticaBoldBig = FontHelper().parseFont("Helvetica-Bold:30") else {
            XCTFail("FontHelper should return UIFont")
            return
        }
        
        let helveticaFont = UIFont(name: "Helvetica-Bold", size: 30)
        
        XCTAssert(helveticaBoldBig.isEqual(helveticaFont),
                  "Font returned should be Helvetica Bold size 30")

        // Testing font fallback with bad font parameter
        
        XCTAssertEqual(FontHelper().parseFont("unknown:30"),
                       UIFont.systemFontOfSize(30),
                       "Font helper should return system font with size 30")
        
        // Testing font helper with bad font:size parameter
        
        XCTAssertNil(FontHelper().parseFont("font!size"),
                     "Font helper should return nil")
        
    }
    
}
