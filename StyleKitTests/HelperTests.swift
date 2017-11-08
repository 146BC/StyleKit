import XCTest
@testable import StyleKit

class HelperTests: XCTestCase {
    
    func testColorHelper() {
        
        guard let blackColor = ColorHelper.parseColor("#000000") else {
            XCTFail("ColorHelper should return UIColor")
            return
        }
        
        XCTAssert(blackColor.isEqual(UIColor(hexString:"#000000")),
                  "Color returned from ColorHelper should be black")
        
        // Testing color helper with bad color parameter
        
        XCTAssertNil(ColorHelper.parseColor("000000"),
                     "Color helper should return nil")
        
    }
    
    func testControlStateHelper() {
        
        XCTAssertEqual(ControlStateHelper.parseControlState("normal"),
                       UIControlState.normal.rawValue)
        
        XCTAssertEqual(ControlStateHelper.parseControlState("disabled"),
                       UIControlState.disabled.rawValue)
        
        XCTAssertEqual(ControlStateHelper.parseControlState("application"),
                       UIControlState.application.rawValue)
        
        XCTAssertEqual(ControlStateHelper.parseControlState("focused"),
                       UIControlState.focused.rawValue)
        
        XCTAssertEqual(ControlStateHelper.parseControlState("highlighted"),
                       UIControlState.highlighted.rawValue)
        
        XCTAssertEqual(ControlStateHelper.parseControlState("reserved"),
                       UIControlState.reserved.rawValue)
        
        XCTAssertEqual(ControlStateHelper.parseControlState("testfallback"),
                       UIControlState.normal.rawValue)
        
    }
    
    func testFontHelper() {
        
        guard let helveticaBoldBig = FontHelper.parseFont("Helvetica-Bold:30") else {
            XCTFail("FontHelper should return UIFont")
            return
        }
        
        let helveticaFont = UIFont(name: "Helvetica-Bold", size: 30)
        
        XCTAssert(helveticaBoldBig.isEqual(helveticaFont),
                  "Font returned should be Helvetica Bold size 30")

        // Testing font fallback with bad font parameter
        
        XCTAssertEqual(FontHelper.parseFont("unknown:30"),
                       UIFont.systemFont(ofSize: 30),
                       "Font helper should return system font with size 30")
        
        // Testing font helper with bad font:size parameter
        
        XCTAssertNil(FontHelper.parseFont("font!size"),
                     "Font helper should return nil")
        
    }

    func testParagraphStyleHelper() {
        let expected = NSMutableParagraphStyle()
        expected.alignment = .center
        expected.firstLineHeadIndent = 2
        expected.headIndent = 3
        expected.tailIndent = 4
        expected.lineBreakMode = .byClipping
        expected.maximumLineHeight = 10
        expected.minimumLineHeight = 12
        expected.lineSpacing = 8
        expected.paragraphSpacing = 9
        expected.paragraphSpacingBefore = 13
        expected.baseWritingDirection = .rightToLeft
        expected.lineHeightMultiple = 44

        let jsonString: String = """
        {
            "alignment": "center",
            "firstLineHeadIndent": 2,
            "headIndent": 3,
            "tailIndent": 4,
            "lineBreakMode": "byClipping",
            "maximumLineHeight": 10,
            "minimumLineHeight": 12,
            "lineSpacing": 8,
            "paragraphSpacing": 9,
            "paragraphSpacingBefore": 13,
            "baseWritingDirection": "rightToLeft",
            "lineHeightMultiple": 44
        }
        """

        let json = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as! [String: Any]


        let actual = ParagraphStyleHelper.parseParagraphStyle(NSStringFromClass(NSParagraphStyle.self), value: json)

        XCTAssertEqual(expected, actual)
    }
    
}
