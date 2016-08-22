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

// MARK: - XCGLogDestinationProtocol
// - Protocol for output classes to conform to
public protocol XCGLogDestinationProtocol: CustomDebugStringConvertible {
    var owner: XCGLogger {get set}
    var identifier: String {get set}
    var outputLogLevel: LogLevel {get set}

    func processLogDetails(logDetails: XCGLogDetails)
    func processInternalLogDetails(logDetails: XCGLogDetails) // Same as processLogDetails but should omit function/file/line info
    func isEnabledForLogLevel(logLevel: LogLevel) -> Bool
}

// MARK: - XCGBaseLogDestination
// - A base class log destination that doesn't actually output the log anywhere and is intented to be subclassed
public class XCGBaseLogDestination: XCGLogDestinationProtocol, CustomDebugStringConvertible {
    // MARK: - Properties
    public var owner: XCGLogger
    public var identifier: String
    public var outputLogLevel: LogLevel = .Debug

    public var showLogIdentifier: Bool = false
    public var showFunctionName: Bool = true
    public var showThreadName: Bool = false
    public var showFileName: Bool = true
    public var showLineNumber: Bool = true
    public var showLogLevel: Bool = true
    public var showDate: Bool = true

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        get {
            return "\(extractClassName(self)): \(identifier) - LogLevel: \(outputLogLevel) showLogIdentifier: \(showLogIdentifier) showFunctionName: \(showFunctionName) showThreadName: \(showThreadName) showLogLevel: \(showLogLevel) showFileName: \(showFileName) showLineNumber: \(showLineNumber) showDate: \(showDate)"
        }
    }

    // MARK: - Life Cycle
    public init(owner: XCGLogger, identifier: String = "") {
        self.owner = owner
        self.identifier = identifier
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

        if showLogIdentifier {
            // extendedDetails += "[\(owner.identifier)] " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += "[" + owner.identifier + "] "
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

        if showLogIdentifier {
            // extendedDetails += "[\(owner.identifier)] " // Note: Leaks in Swift versions prior to Swift 3
            extendedDetails += "[" + owner.identifier + "] "
        }

        // output(logDetails, text: "\(extendedDetails)> \(logDetails.logMessage)") // Note: Leaks in Swift versions prior to Swift 3
        output(logDetails, text: extendedDetails + "> " + logDetails.logMessage)
    }

    // MARK: - Misc methods
    public func isEnabledForLogLevel (logLevel: LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    // MARK: - Methods that must be overriden in subclasses
    public func output(logDetails: XCGLogDetails, text: String) {
        // Do something with the text in an overridden version of this method
        precondition(false, "Must override this")
    }
}

// MARK: - XCGConsoleLogDestination
// - A standard log destination that outputs log details to the console
public class XCGConsoleLogDestination: XCGBaseLogDestination {
    // MARK: - Properties
    public var logQueue: dispatch_queue_t? = nil

    // MARK: - Misc Methods
    public override func output(logDetails: XCGLogDetails, text: String) {

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
        public static let defaultInstanceIdentifier = "com.cerebralgardens.xcglogger.defaultInstance"
        public static let baseConsoleLogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.console"
        public static let nslogDestinationIdentifier = "com.cerebralgardens.xcglogger.logdestination.console.nslog"
        public static let logQueueIdentifier = "com.cerebralgardens.xcglogger.queue"
        public static let nsdataFormatterCacheIdentifier = "com.cerebralgardens.xcglogger.nsdataFormatterCache"
        public static let versionString = "3.4"
    }
    public typealias constants = Constants // Preserve backwards compatibility: Constants should be capitalized since it's a type

    // MARK: - Properties (Options)
    public var identifier: String = ""
    public var outputLogLevel: LogLevel = .Debug {
        didSet {
            for index in 0 ..< logDestinations.count {
                logDestinations[index].outputLogLevel = outputLogLevel
            }
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

    public var logDestinations: [XCGLogDestinationProtocol] = []

    // MARK: - Life Cycle
    public init(identifier: String = "", includeDefaultDestinations: Bool = true) {
        self.identifier = identifier

        if includeDefaultDestinations {
            // Setup a standard console log destination
            addLogDestination(XCGConsoleLogDestination(owner: self, identifier: XCGLogger.Constants.baseConsoleLogDestinationIdentifier))
        }
    }

    // MARK: - Default instance
    public class func defaultInstance() -> XCGLogger {
        struct Statics {
            static let instance: XCGLogger = XCGLogger(identifier: XCGLogger.Constants.defaultInstanceIdentifier)
        }

        return Statics.instance
    }

    // MARK: - Setup methods
    public class func setup(logLevel: LogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        defaultInstance().setup(logLevel, showLogIdentifier: showLogIdentifier, showFunctionName: showFunctionName, showThreadName: showThreadName, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, showDate: showDate)
    }

    public func setup(logLevel: LogLevel = .Debug, showLogIdentifier: Bool = false, showFunctionName: Bool = true, showThreadName: Bool = false, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showDate: Bool = true) {
        outputLogLevel = logLevel;

        if let standardConsoleLogDestination = logDestination(XCGLogger.Constants.baseConsoleLogDestinationIdentifier) as? XCGConsoleLogDestination {
            standardConsoleLogDestination.showLogIdentifier = showLogIdentifier
            standardConsoleLogDestination.showFunctionName = showFunctionName
            standardConsoleLogDestination.showThreadName = showThreadName
            standardConsoleLogDestination.showLogLevel = showLogLevel
            standardConsoleLogDestination.showFileName = showFileNames
            standardConsoleLogDestination.showLineNumber = showLineNumbers
            standardConsoleLogDestination.showDate = showDate
            standardConsoleLogDestination.outputLogLevel = logLevel
        }

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
        for logDestination in self.logDestinations {
            guard logDestination.isEnabledForLogLevel(logLevel) else {
                continue
            }

            if logDetails == nil {
                guard let logMessage = closure() else {
                    break
                }

                logDetails = XCGLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
            }

            logDestination.processLogDetails(logDetails)
        }
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

    public class func verbose(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func verbose(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func verbose(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.logln(.Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Debug
    public class func debug(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public class func debug(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func debug(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func debug(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.logln(.Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Info
    public class func info(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public class func info(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func info(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func info(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.logln(.Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Warning
    public class func warning(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public class func warning(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func warning(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func warning(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.logln(.Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Error
    public class func error(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public class func error(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func error(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func error(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.logln(.Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: * Severe
    public class func severe(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.defaultInstance().logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public class func severe(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.defaultInstance().logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func severe(@autoclosure(escaping) closure: () -> String?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        self.logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    public func severe(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, closure: () -> String?) {
        self.logln(.Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: closure)
    }

    // MARK: - Exec Methods
    // MARK: * Verbose
    public class func verboseExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Verbose, closure: closure)
    }

    public func verboseExec(closure: () -> () = {}) {
        self.exec(LogLevel.Verbose, closure: closure)
    }

    // MARK: * Debug
    public class func debugExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Debug, closure: closure)
    }

    public func debugExec(closure: () -> () = {}) {
        self.exec(LogLevel.Debug, closure: closure)
    }

    // MARK: * Info
    public class func infoExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Info, closure: closure)
    }

    public func infoExec(closure: () -> () = {}) {
        self.exec(LogLevel.Info, closure: closure)
    }

    // MARK: * Warning
    public class func warningExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Warning, closure: closure)
    }

    public func warningExec(closure: () -> () = {}) {
        self.exec(LogLevel.Warning, closure: closure)
    }

    // MARK: * Error
    public class func errorExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Error, closure: closure)
    }

    public func errorExec(closure: () -> () = {}) {
        self.exec(LogLevel.Error, closure: closure)
    }

    // MARK: * Severe
    public class func severeExec(closure: () -> () = {}) {
        self.defaultInstance().exec(LogLevel.Severe, closure: closure)
    }

    public func severeExec(closure: () -> () = {}) {
        self.exec(LogLevel.Severe, closure: closure)
    }

    // MARK: - Misc methods
    public func isEnabledForLogLevel (logLevel: LogLevel) -> Bool {
        return logLevel >= self.outputLogLevel
    }

    public func logDestination(identifier: String) -> XCGLogDestinationProtocol? {
        for logDestination in logDestinations {
            if logDestination.identifier == identifier {
                return logDestination
            }
        }

        return nil
    }

    public func addLogDestination(logDestination: XCGLogDestinationProtocol) -> Bool {
        let existingLogDestination: XCGLogDestinationProtocol? = self.logDestination(logDestination.identifier)
        if existingLogDestination != nil {
            return false
        }

        logDestinations.append(logDestination)
        return true
    }

    public func removeLogDestination(logDestination: XCGLogDestinationProtocol) {
        removeLogDestination(logDestination.identifier)
    }

    public func removeLogDestination(identifier: String) {
        logDestinations = logDestinations.filter({$0.identifier != identifier})
    }

    // MARK: - Private methods
    private func _logln(logMessage: String, logLevel: LogLevel = .Debug) {

        var logDetails: XCGLogDetails? = nil
        for logDestination in self.logDestinations {
            if (logDestination.isEnabledForLogLevel(logLevel)) {
                if logDetails == nil {
                    logDetails = XCGLogDetails(logLevel: logLevel, date: NSDate(), logMessage: logMessage, functionName: "", fileName: "", lineNumber: 0)
                }
                
                logDestination.processInternalLogDetails(logDetails!)
            }
        }
    }
    
    // MARK: - DebugPrintable
    public var debugDescription: String {
        get {
            var description: String = "\(extractClassName(self)): \(identifier) - logDestinations: \r"
            for logDestination in logDestinations {
                description += "\t \(logDestination.debugDescription)\r"
            }
            
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
