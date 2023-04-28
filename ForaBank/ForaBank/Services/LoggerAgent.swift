//
//  LoggerAgent.swift
//  ForaBank
//
//  Created by Дмитрий on 16.08.2022.
//

import Foundation
import OSLog

class LoggerAgent: LoggerAgentProtocol {
    
    static let shared = LoggerAgent()
    static let subsystem = "ru.forabank.sense"
    
    private let modelLogger = Logger(subsystem: subsystem, category: LoggerAgentCategory.model.rawValue)
    private let uiLogger = Logger(subsystem: subsystem, category: LoggerAgentCategory.ui.rawValue)
    private let networkLogger = Logger(subsystem: subsystem, category: LoggerAgentCategory.network.rawValue)
    private let cacheLogger = Logger(subsystem: subsystem, category: LoggerAgentCategory.cache.rawValue)
    private let sessionLogger = Logger(subsystem: subsystem, category: LoggerAgentCategory.session.rawValue)
    private let paymentsLogger = Logger(subsystem: subsystem, category: LoggerAgentCategory.payments.rawValue)
    
    func log(level: LoggerAgentLevel = .default, category: LoggerAgentCategory, message: String, file: StaticString = #file, line: UInt = #line) {
        
        let logMessage = "\(message) - \(extractFileName(from: file)):\(line)"
        let logger = logger(for: category)
        
        switch level {
        case .debug: logger.debug("\(logMessage, privacy: .public)")
        case .info: logger.info("\(logMessage, privacy: .public)")
        case .default: logger.notice("\(logMessage, privacy: .public)")
        case .error: logger.error("\(logMessage, privacy: .public)")
        case .fault: logger.fault("\(logMessage, privacy: .public)")
        }
    }

    private func logger(for category: LoggerAgentCategory) -> Logger {
        
        switch category {
        case .model: return modelLogger
        case .ui: return uiLogger
        case .network: return networkLogger
        case .cache: return cacheLogger
        case .session: return sessionLogger
        case .payments: return paymentsLogger
        }
    }
    
    private func extractFileName(from path: StaticString) -> String {
        
        String(describing: path)
            .components(separatedBy: "/")
            .last ?? "(file not parsed)"
    }
}

