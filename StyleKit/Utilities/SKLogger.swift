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
    case debug
    case error
    case severe
    case none

    public var description: String {
        switch self {
        case .debug:
            return "Debug"
        case .error:
            return "Error"
        case .severe:
            return "Severe"
        case .none:
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
    var date: Date
    var logMessage: String
    var functionName: String
    var fileName: String
    var lineNumber: Int

    init(logLevel: SKLogLevel, date: Date, logMessage: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        self.logLevel = logLevel
        self.date = date
        self.logMessage = logMessage
        self.functionName = String(describing: functionName)
        self.fileName = String(describing: fileName)
        self.lineNumber = lineNumber
    }
}

// MARK: - SKConsoleLogDestination
// - A standard log destination that outputs log details to the console
internal class SKConsoleLogDestination: CustomDebugStringConvertible {
    // MARK: - Properties
    var owner: SKLogger
    var outputSKLogLevel: SKLogLevel = .debug

    var showFunctionName: Bool = true
    var showThreadName: Bool = false
    var showFileName: Bool = true
    var showLineNumber: Bool = true
    var showSKLogLevel: Bool = true
    var showDate: Bool = true

    var logQueue: DispatchQueue? = nil

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
    func processLogDetails(_ logDetails: SKLogDetails) {
        var extendedDetails: String = ""

        if showDate {
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
                formattedDate = dateFormatter.string(from: logDetails.date)
            }

            // extendedDetails += "\(formattedDate) " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += formattedDate + " "
        }

        if showSKLogLevel {
            extendedDetails += "[\(logDetails.logLevel)] "
        }

        if showThreadName {
            if Thread.isMainThread {
                extendedDetails += "[main] "
            }
            else {
                
                if let threadName = Thread.current.name , !threadName.isEmpty {
                    extendedDetails += "[" + threadName + "] "
                }
                else if let label = logQueue?.label, let queueName = String(validatingUTF8: label) , !queueName.isEmpty {
                    extendedDetails += "[" + queueName + "] "
                }
                else {
                    extendedDetails += "[" + String(format: "%p", Thread.current) + "] "
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

    func processInternalLogDetails(_ logDetails: SKLogDetails) {
        var extendedDetails: String = ""

        if showDate {
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
                formattedDate = dateFormatter.string(from: logDetails.date)
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
    func isEnabledForSKLogLevel (_ logLevel: SKLogLevel) -> Bool {
        return logLevel >= self.outputSKLogLevel
    }

    // MARK: - Output
    func output(_ logDetails: SKLogDetails, text: String) {
        let outputClosure = {
            print(text)
        }

        if let logQueue = logQueue {
            logQueue.async(execute: outputClosure)
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
    var outputSKLogLevel: SKLogLevel = .debug {
        didSet {
            logDestination.outputSKLogLevel = outputSKLogLevel
        }
    }

    // MARK: - Properties
    class var logQueue: DispatchQueue {
        struct Statics {
            static var logQueue = DispatchQueue(label: SKLogger.Constants.logQueueIdentifier, attributes: [])
        }

        return Statics.logQueue
    }

    fileprivate var _dateFormatter: DateFormatter? = nil
    var dateFormatter: DateFormatter? {
        get {
            if _dateFormatter != nil {
                return _dateFormatter
            }

            let defaultDateFormatter = DateFormatter()
            defaultDateFormatter.locale = Locale.current
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
    class func setup(_ logLevel: SKLogLevel = .debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showSKLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        defaultInstance().setup(logLevel, showLogIdentifier: showLogIdentifier, showFunctionName: showFunctionName, showThreadName: showThreadName, showSKLogLevel: showSKLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, showDate: showDate)
    }

    func setup(_ logLevel: SKLogLevel = .debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showSKLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
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
    class func logln( _ closure: @autoclosure @escaping () -> String?, logLevel: SKLogLevel = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    class func logln(_ logLevel: SKLogLevel = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    func logln( _ closure: @autoclosure @escaping () -> String?, logLevel: SKLogLevel = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    func logln(_ logLevel: SKLogLevel = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        var logDetails: SKLogDetails!

        guard logDestination.isEnabledForSKLogLevel(logLevel) else {
            return
        }

        if logDetails == nil {
            guard let logMessage = closure() else {
                return
            }

            logDetails = SKLogDetails(logLevel: logLevel, date: Date(), logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
        }

        logDestination.processLogDetails(logDetails)

    }

    class func exec(_ logLevel: SKLogLevel = .debug, closure: () -> () = {}) {
        self.defaultInstance().exec(logLevel, closure: closure)
    }

    func exec(_ logLevel: SKLogLevel = .debug, closure: () -> () = {}) {
        guard isEnabledForSKLogLevel(logLevel) else {
            return
        }
        closure()
    }

    // MARK: * Debug
    class func debug( _ closure: @autoclosure @escaping () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }


    // MARK: * Error
    class func error( _ closure: @autoclosure @escaping () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Severe
    class func severe( _ closure: @autoclosure @escaping () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Debug
    class func debugExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(SKLogLevel.debug, closure: closure)
    }

    // MARK: * Error
    class func errorExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(SKLogLevel.error, closure: closure)
    }

    // MARK: * Severe
    class func severeExec(_ closure: () -> () = {}) {
        self.defaultInstance().exec(SKLogLevel.severe, closure: closure)
    }

    // MARK: - Misc methods
    func isEnabledForSKLogLevel (_ logLevel: SKLogLevel) -> Bool {
        return logLevel >= self.outputSKLogLevel
    }

    // MARK: - Private methods
    fileprivate func _logln(_ logMessage: String, logLevel: SKLogLevel = .debug) {

        var logDetails: SKLogDetails? = nil
        if (logDestination.isEnabledForSKLogLevel(logLevel)) {
            if logDetails == nil {
                logDetails = SKLogDetails(logLevel: logLevel, date: Date(), logMessage: logMessage, functionName: "", fileName: "", lineNumber: 0)
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

func extractClassName(_ someObject: Any) -> String {
    return (someObject is Any.Type) ? "\(someObject)" : "\(type(of: (someObject) as AnyObject))"
}
