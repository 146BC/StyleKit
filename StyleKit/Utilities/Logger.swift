//
//  XCGLogger.swift
//  XCGLogger: https://github.com/DaveWoodCom/XCGLogger
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

public enum LogLevel: Int, Comparable, CustomStringConvertible {
    case Verbose
    case Debug
    case Info
    case Warning
    case Error
    case Severe
    case None

    public var description: String {
        switch self {
        case .Verbose:
            return "Verbose"
        case .Debug:
            return "Debug"
        case .Info:
            return "Info"
        case .Warning:
            return "Warning"
        case .Error:
            return "Error"
        case .Severe:
            return "Severe"
        case .None:
            return "None"
        }
    }
}


// MARK: - XCGLogDetails
// - Data structure to hold all info about a log message, passed to log destination classes
public struct XCGLogDetails {
    public var logLevel: LogLevel
    public var date: NSDate
    public var logMessage: String
    public var functionName: String
    public var fileName: String
    public var lineNumber: Int

    public init(logLevel: LogLevel, date: NSDate, logMessage: String, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        self.logLevel = logLevel
        self.date = date
        self.logMessage = logMessage
        self.functionName = String(functionName)
        self.fileName = String(fileName)
        self.lineNumber = lineNumber
    }
}

// MARK: - XCGConsoleLogDestination
// - A standard log destination that outputs log details to the console
public class XCGConsoleLogDestination: CustomDebugStringConvertible {
    // MARK: - Properties
    public var owner: XCGLogger
    public var outputLogLevel: LogLevel = .Debug

    public var showFunctionName: Bool = true
    public var showThreadName: Bool = false
    public var showFileName: Bool = true
    public var showLineNumber: Bool = true
    public var showLogLevel: Bool = true
    public var showDate: Bool = true

    public var logQueue: dispatch_queue_t? = nil

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        get {
            return "\(extractClassName(self)): - LogLevel: \(outputLogLevel) showFunctionName: \(showFunctionName) showThreadName: \(showThreadName) showLogLevel: \(showLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber) showDate: \(showDate)"
        }
    }

    // MARK: - Life Cycle
    public init(owner: XCGLogger) {
        self.owner = owner
    }

    // MARK: - Methods to Process Log Details
    public func processLogDetails(logDetails: XCGLogDetails) {
        var extendedDetails: String = ""

        if showDate {
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
                formattedDate = dateFormatter.stringFromDate(logDetails.date)
            }

            // extendedDetails += "\(formattedDate) " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += formattedDate + " "
        }

        if showLogLevel {
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

    public func processInternalLogDetails(logDetails: XCGLogDetails) {
        var extendedDetails: String = ""

        if showDate {
            var formattedDate: String = logDetails.date.description
            if let dateFormatter = owner.dateFormatter {
                formattedDate = dateFormatter.stringFromDate(logDetails.date)
            }

            // extendedDetails += "\(formattedDate) " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += formattedDate + " "
        }

        if showLogLevel {
            extendedDetails += "[\(logDetails.logLevel)] "
        }

        // output(logDetails, text: "\(extendedDetails)> \(logDetails.logMessage)") // Note: Leaks in Swift versions prior to Swift 3
        output(logDetails, text: extendedDetails + "> " + logDetails.logMessage)
    }

    // MARK: - Misc methods
    public func isEnabledForLogLevel (logLevel: LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    // MARK: - Output
    public func output(logDetails: XCGLogDetails, text: String) {
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

// MARK: - XCGLogger
// - The main logging class
public class XCGLogger: CustomDebugStringConvertible {
    // MARK: - Constants
    public struct Constants {
        public static let baseConsoleLogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.console"
        public static let logQueueIdentifier = "OneFourSixBC.StyleKit.xcglogger.queue"
    }
    public typealias constants = Constants // Preserve backwards compatibility: Constants should be capitalized since it's a type

    // MARK: - Properties (Options)
    public var outputLogLevel: LogLevel = .Debug {
        didSet {
            logDestination.outputLogLevel = outputLogLevel
        }
    }

    // MARK: - Properties
    public class var logQueue: dispatch_queue_t {
        struct Statics {
            static var logQueue = dispatch_queue_create(XCGLogger.Constants.logQueueIdentifier, nil)
        }

        return Statics.logQueue
    }

    private var _dateFormatter: NSDateFormatter? = nil
    public var dateFormatter: NSDateFormatter? {
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

    public lazy var logDestination: XCGConsoleLogDestination =
        XCGConsoleLogDestination(owner: self)

    // MARK: - Default instance
    public class func defaultInstance() -> XCGLogger {
        struct Statics {
            static let instance: XCGLogger = XCGLogger()
        }

        return Statics.instance
    }

    // MARK: - Setup methods
    public class func setup(logLevel: LogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        defaultInstance().setup(logLevel, showLogIdentifier: showLogIdentifier, showFunctionName: showFunctionName, showThreadName: showThreadName, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, showDate: showDate)
    }

    public func setup(logLevel: LogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        outputLogLevel = logLevel;

        logDestination.showFunctionName = showFunctionName
        logDestination.showThreadName = showThreadName
        logDestination.showLogLevel = showLogLevel
        logDestination.showFileName = showFileNames
        logDestination.showLineNumber = showLineNumbers
        logDestination.showDate = showDate
        logDestination.outputLogLevel = logLevel
    }

    // MARK: - Logging methods
    public class func logln(@autoclosure(escaping) closure: () -> String?, logLevel: LogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public class func logln(logLevel: LogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func logln(@autoclosure(escaping) closure: () -> String?, logLevel: LogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func logln(logLevel: LogLevel = .Debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, @noescape closure: () -> String?) {
        var logDetails: XCGLogDetails!

        guard logDestination.isEnabledForLogLevel(logLevel) else {
         return
        }

        if logDetails == nil {
            guard let logMessage = closure() else {
                return
            }

            logDetails = XCGLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
        }

        logDestination.processLogDetails(logDetails)

    }

    public class func exec(logLevel: LogLevel = .Debug, closure: () -> () = {}) {
        self.defaultInstance().exec(logLevel, closure: closure)
    }

    public func exec(logLevel: LogLevel = .Debug, closure: () -> () = {}) {
        guard isEnabledForLogLevel(logLevel) else {
            return
        }
        closure()
    }


    // MARK: - Convenience logging methods
    // MARK: * Verbose
    public class func verbose(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Debug
    public class func debug(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Info
    public class func info(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Warning
    public class func warning(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Error
    public class func error(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Severe
    public class func severe(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: - Exec Methods
    // MARK: * Verbose
    public class func verboseExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Verbose, closure: closure)
    }

    // MARK: * Debug
    public class func debugExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Debug, closure: closure)
    }

    // MARK: * Info
    public class func infoExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Info, closure: closure)
    }

    // MARK: * Warning
    public class func warningExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Warning, closure: closure)
    }

    // MARK: * Error
    public class func errorExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Error, closure: closure)
    }

    // MARK: * Severe
    public class func severeExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Severe, closure: closure)
    }

    // MARK: - Misc methods
    public func isEnabledForLogLevel (logLevel: LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    // MARK: - Private methods
    private func _logln(logMessage: String, logLevel: LogLevel = .Debug) {

        var logDetails: XCGLogDetails? = nil
        if (logDestination.isEnabledForLogLevel(logLevel)) {
            if logDetails == nil {
                logDetails = XCGLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: "", fileName: "", lineNumber: 0)
            }
            
            logDestination.processInternalLogDetails(logDetails!)
        }
    }


    // MARK: - DebugPrintable
    public var debugDescription: String {
        get {
            var description: String = "\(extractClassName(self)): - logDestination: \r"
            description += "\t \(logDestination.debugDescription)\r"
            return description
        }
    }
}

// Implement Comparable for LogLevel
public func < (lhs:LogLevel, rhs:LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

func extractClassName(someObject: Any) -> String {
    return (someObject is Any.Type) ? "\(someObject)" : "\(someObject.dynamicType)"
}
