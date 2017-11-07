//
//  ParagraphStyleHelper.swift
//  StyleKit
//
//  Created by Jakub Petrík on 11/7/17.
//  Copyright © 2017 Bernard Gatt. All rights reserved.
//

import Foundation

public enum ParagraphStyleHelper {
    public static func parseParagraphStyle(_ name: String, value: [String: Any]) -> NSParagraphStyle? {
        guard name == "NSParagraphStyle" else { return nil }
        
        let style = NSMutableParagraphStyle()
        if let alignmentValue = value["alignment"] as? String {
            style.alignment = parseTextAlignment(alignmentValue)
        }
        if let indent = value["firstLineHeadIndent"] as? Double {
            style.firstLineHeadIndent = CGFloat(indent)
        }
        if let indent = value["headIndent"] as? Double {
            style.headIndent = CGFloat(indent)
        }
        if let indent = value["tailIndent"] as? Double {
            style.tailIndent = CGFloat(indent)
        }
        if let breakMode = value["lineBreakMode"] as? String {
            style.lineBreakMode = parseLineBreakMode(breakMode)
        }
        if let maxLineHeight = value["maximumLineHeight"] as? Double {
            style.maximumLineHeight = CGFloat(maxLineHeight)
        }
        if let minLineHeight = value["minimumLineHeight"] as? Double {
            style.minimumLineHeight = CGFloat(minLineHeight)
        }
        if let spacing = value["lineSpacing"] as? Double {
            style.lineSpacing = CGFloat(spacing)
        }
        if let spacing = value["paragraphSpacing"] as? Double {
            style.paragraphSpacing = CGFloat(spacing)
        }
        if let spacing = value["paragraphSpacingBefore"] as? Double {
            style.paragraphSpacingBefore = CGFloat(spacing)
        }
        if let writingDirection = value["baseWritingDirection"] as? String {
            style.baseWritingDirection = parseWritingDirection(writingDirection)
        }
        if let height = value["lineHeightMultiple"] as? Double {
            style.lineHeightMultiple = CGFloat(height)
        }

        return style.copy() as? NSParagraphStyle
    }

    private static func parseTextAlignment(_ value: String) -> NSTextAlignment {
        switch value {
        case "left":
            return .left
        case "right":
            return .right
        case "center":
            return .center
        case "justified":
            return .justified
        default:
            return .natural
        }
    }

    private static func parseLineBreakMode(_ value: String) -> NSLineBreakMode {
        switch value {
        case "byCharWrapping":
            return .byCharWrapping
        case "byClipping":
            return .byClipping
        case "byTruncatingHead":
            return .byTruncatingHead
        case "byTruncatingTail":
            return .byTruncatingTail
        case "byTruncatingMiddle":
            return .byTruncatingMiddle
        default:
            return .byWordWrapping
        }
    }

    private static func parseWritingDirection(_ value: String) -> NSWritingDirection {
        switch value {
        case "leftToRight":
            return .leftToRight
        case "rightToLeft":
            return .rightToLeft
        default:
            return .natural
        }
    }
}
