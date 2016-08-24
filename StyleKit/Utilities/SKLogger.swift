//  Inspired by XCGLogger: https://github.com/DaveWoodCom/XCGLogger
//
//  Created by Dave Wood on 2014-06-06.
//  Copyright (c) 2014 Dave Wood, Cerebral Gardens.
//  Some rights reserved: https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt
//

import Foundation
#if os(OSX)
    import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif

/// Log Level
public enum SKLogLevel: Int, Comparable, CustomStringConvertible {
    case Debug
    case Error
    case Severe
    case None

    public var description: String {
        switch self {
        case .Debug:
            return "Debug"
        case .Error:
            return "Error"
        case .Severe:
            return "Severe"
        case .None:
            return "None"
        }
    }
}

// Implement Comparable for SKLogLevel
public func < (lhs:SKLogLevel, rhs:SKLogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}


// MARK: - SKLogDetails
// - Data structure to hold all info about a log message, passed to log destination classes
internal struct SKLogDetails {
    var logLevel: SKLogLevel
    var date: NSDate
    var logMessage: String
    var functionName: String
    var fileName: String
    var lineNumber: Int

    init(logLevel: SKLogLevel, date: NSDate, logMessage: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        self.logLevel = logLevel
        self.date = date
        self.logMessage = logMessage
        self.functionName = String(functionName)
        self.fileName = String(fileName)
        self.lineNumber = lineNumber
    }
}

// MARK: - SKConsoleLogDestination
// - A standard log destination that outputs log details to the console
internal class SKConsoleLogDestination: CustomDebugStringConvertible {
    // MARK: - Properties
    var owner: SKLogger
    var outputSKLogLevel: SKLogLevel = .Debug

    var showFunctionName: Bool = true
    var showThreadName: Bool = false
    var showFileName: Bool = true
    var showLineNumber: Bool = true
    var showSKLogLevel: Bool = true
    var showDate: Bool = true

    var logQueue: dispatch_queue_t? = nil

    // MARK: - CustomDebugStringConvertible
    var debugDescription: String {
        get {
            return "\(extractClassName(self)): - SKLogLevel: \(outputSKLogLevel) showFunctionName: \(showFunctionName) showThreadName: \(showThreadName) showSKLogLevel: \(showSKLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber) showDate: \(showDate)"
        }
    }

    // MARK: - Life Cycle
    init(owner: SKLogger) {
        self.owner = owner
    }

    // MARK: - Methods to Process Log Details
    func processLogDetails(logDetails: SKLogDetails) {
        var extendedDetails: String = ""

        if showDate {
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
                formattedDate = dateFormatter.stringFromDate(logDetails.date)
            }

            // extendedDetails += "\(formattedDate) " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += formattedDate + " "
        }

        if showSKLogLevel {
            extendedDetails += "[\(logDetails.logLevel)] "
        }

        if showThreadName {
            if NSThread.isMainThread() {
                extendedDetails += "[main] "
            }
            else {
                if let threadName = NSThread.currentThread().name where !threadName.isEmpty {
                    extendedDetails += "[" + threadName + "] "
                }
                else if let queueName = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
                    extendedDetails += "[" + queueName + "] "
                }
                else {
                    extendedDetails += "[" + String(format: "%p", NSThread.currentThread()) + "] "
                }
            }
        }

        if showFileName {
            extendedDetails += "[" + (logDetails.fileName as NSString).lastPathComponent + (showLineNumber ? ":" + String(logDetails.lineNumber) : "") + "] "
        }
        else if showLineNumber {
            extendedDetails += "[" + String(logDetails.lineNumber) + "] "
        }

        if showFunctionName {
            // extendedDetails += "\(logDetails.functionName) " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += logDetails.functionName + " "
        }

        // output(logDetails, text: "\(extendedDetails)> \(logDetails.logMessage)") // Note: Leaks in Swift versions prior to Swift 3
        output(logDetails, text: extendedDetails + "> " + logDetails.logMessage)
    }

    func processInternalLogDetails(logDetails: SKLogDetails) {
        var extendedDetails: String = ""

        if showDate {
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
                formattedDate = dateFormatter.stringFromDate(logDetails.date)
            }

            // extendedDetails += "\(formattedDate) " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += formattedDate + " "
        }

        if showSKLogLevel {
            extendedDetails += "[\(logDetails.logLevel)] "
        }

        // output(logDetails, text: "\(extendedDetails)> \(logDetails.logMessage)") // Note: Leaks in Swift versions prior to Swift 3
        output(logDetails, text: extendedDetails + "> " + logDetails.logMessage)
    }

    // MARK: - Misc methods
    func isEnabledForSKLogLevel (logLevel: SKLogLevel) -> Bool {
        return logLevel >= self.outputSKLogLevel
    }

    // MARK: - Output
    func output(logDetails: SKLogDetails, text: String) {
        let outputClosure = {
            print(text)
        }

        if let logQueue = logQueue {
            dispatch_async(logQueue, outputClosure)
        }
        else {
            outputClosure()
        }
    }
}

// MARK: - SKLogger
// - The main logging class
internal class SKLogger: CustomDebugStringConvertible {
    // MARK: - Constants
    struct Constants {
        static let logQueueIdentifier = "OneFourSixBC.StyleKit.xcglogger.queue"
    }

    // MARK: - Properties (Options)
    var outputSKLogLevel: SKLogLevel = .Debug {
        didSet {
            logDestination.outputSKLogLevel = outputSKLogLevel
        }
    }

    // MARK: - Properties
    class var logQueue: dispatch_queue_t {
        struct Statics {
            static var logQueue = dispatch_queue_create(SKLogger.Constants.logQueueIdentifier, nil)
        }

        return Statics.logQueue
    }

    private var _dateFormatter: NSDateFormatter? = nil
    var dateFormatter: NSDateFormatter? {
        get {
            if _dateFormatter != nil {
                return _dateFormatter
            }

            let defaultDateFormatter = NSDateFormatter()
            defaultDateFormatter.locale = NSLocale.currentLocale()
            defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            _dateFormatter = defaultDateFormatter

            return _dateFormatter
        }
        set {
            _dateFormatter = newValue
        }
    }

    lazy var logDestination: SKConsoleLogDestination = SKConsoleLogDestination(owner: self)

    // MARK: - Default instance
    class func defaultInstance() -> SKLogger {
        struct Statics {
            static let instance: SKLogger = SKLogger()
        }

        return Statics.instance
    }

    // MARK: - Setup methods
    class func setup(logLevel: SKLogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showSKLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        defaultInstance().setup(logLevel, showLogIdentifier: showLogIdentifier, showFunctionName: showFunctionName, showThreadName: showThreadName, showSKLogLevel: showSKLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, showDate: showDate)
    }

    func setup(logLevel: SKLogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showSKLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        outputSKLogLevel = logLevel;

        logDestination.showFunctionName = showFunctionName
        logDestination.showThreadName = showThreadName
        logDestination.showSKLogLevel = showSKLogLevel
        logDestination.showFileName = showFileNames
        logDestination.showLineNumber = showLineNumbers
        logDestination.showDate = showDate
        logDestination.outputSKLogLevel = logLevel
    }

    // MARK: - Logging methods
    class func logln(@autoclosure(escaping) closure: () -> String?, logLevel: SKLogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    class func logln(logLevel: SKLogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    func logln(@autoclosure(escaping) closure: () -> String?, logLevel: SKLogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    func logln(logLevel: SKLogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
        var logDetails: SKLogDetails!

        guard logDestination.isEnabledForSKLogLevel(logLevel) else {
            return
        }

        if logDetails == nil {
            guard let logMessage = closure() else {
                return
            }

            logDetails = SKLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
        }

        logDestination.processLogDetails(logDetails)

    }

    class func exec(logLevel: SKLogLevel = .Debug, closure: () -> () = {}) {
        self.defaultInstance().exec(logLevel, closure: closure)
    }

    func exec(logLevel: SKLogLevel = .Debug, closure: () -> () = {}) {
        guard isEnabledForSKLogLevel(logLevel) else {
            return
        }
        closure()
    }

    // MARK: * Debug
    class func debug(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }


    // MARK: * Error
    class func error(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Severe
    class func severe(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Debug
    class func debugExec(closure: () -> () = {}) {
        self.defaultInstance().exec(SKLogLevel.Debug, closure: closure)
    }

    // MARK: * Error
    class func errorExec(closure: () -> () = {}) {
        self.defaultInstance().exec(SKLogLevel.Error, closure: closure)
    }

    // MARK: * Severe
    class func severeExec(closure: () -> () = {}) {
        self.defaultInstance().exec(SKLogLevel.Severe, closure: closure)
    }

    // MARK: - Misc methods
    func isEnabledForSKLogLevel (logLevel: SKLogLevel) -> Bool {
        return logLevel >= self.outputSKLogLevel
    }

    // MARK: - Private methods
    private func _logln(logMessage: String, logLevel: SKLogLevel = .Debug) {

        var logDetails: SKLogDetails? = nil
        if (logDestination.isEnabledForSKLogLevel(logLevel)) {
            if logDetails == nil {
                logDetails = SKLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: "", fileName: "", lineNumber: 0)
            }

            logDestination.processInternalLogDetails(logDetails!)
        }
    }


    // MARK: - DebugPrintable
    var debugDescription: String {
        get {
            var description: String = "\(extractClassName(self)): - logDestination: \r"
            description += "\t \(logDestination.debugDescription)\r"
            return description
        }
    }
}

func extractClassName(someObject: Any) -> String {
    return (someObject is Any.Type) ? "\(someObject)" : "\(someObject.dynamicType)"
}
