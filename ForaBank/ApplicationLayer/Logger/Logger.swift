//
//  Logger.swift
//  Anna
//
//  Created by Igor on 17/10/2017.
//  Copyright © 2017 Anna Financial Service Ltd. All rights reserved.
//

//import UIKit
//import UIKit
//import XCGLogger
//
//class Logger: NSObject, ILogger {
//    @objc static let sharedInstance = Logger()
//    static let logFilePath = "\(NSTemporaryDirectory())/log_file"
//
//    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
//
//    func setup() {
//        setupXCGLogger()
//    }
//
//    @objc func write(string: String?) {
//        #if !PROD
//            log.debug(string)
//        #endif
//    }
//
//    func write(string: String?, file: String?, function: String?, line: Int?) {
//        #if !PROD
//        var result = ""
//        append(string: string, to: &result)
//        append(string: file, to: &result)
//        append(string: function, to: &result)
//        append(string: "\(line ?? 0)", to: &result)
//        write(string: result)
//        #endif
//    }
//
//    func write(string: String?, file: String?, line: Int?) {
//        #if !PROD
//        write(string: string, file: file, function: nil, line: line)
//        #endif
//    }
//
//    func append(string: String?, to other: inout String) {
//        if let string = string {
//            other.append("[\(string)] ")
//        }
//    }
//
//    // MARK: - Pricave
//
//    private func setupXCGLogger() {
//        #if !PROD
//        let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
//        systemDestination.outputLevel = .debug
//        systemDestination.showLogIdentifier = false
//        systemDestination.showFunctionName = false
//        systemDestination.showThreadName = false
//        systemDestination.showLevel = false
//        systemDestination.showFileName = false
//        systemDestination.showLineNumber = false
//        systemDestination.showDate = true
//        log.add(destination: systemDestination)
//
//        let fileDestination = FileDestination(writeToFile: Logger.logFilePath, identifier: "advancedLogger.fileDestination")
//        fileDestination.outputLevel = .debug
//        fileDestination.showLogIdentifier = false
//        fileDestination.showFunctionName = false
//        fileDestination.showThreadName = false
//        fileDestination.showLevel = false
//        fileDestination.showFileName = false
//        fileDestination.showLineNumber = false
//        fileDestination.showDate = true
//        fileDestination.logQueue = XCGLogger.logQueue
//        log.add(destination: fileDestination)
//
//        log.logAppDetails()
//        #endif
//    }
//}
