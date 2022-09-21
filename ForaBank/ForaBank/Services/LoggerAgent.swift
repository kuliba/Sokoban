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
    
    private let modelLogger = OSLog(subsystem: subsystem, category: LoggerAgentCategory.model.rawValue)
    private let uiLogger = OSLog(subsystem: subsystem, category: LoggerAgentCategory.ui.rawValue)
    private let networkLogger = OSLog(subsystem: subsystem, category: LoggerAgentCategory.network.rawValue)
    private let cacheLogger = OSLog(subsystem: subsystem, category: LoggerAgentCategory.cache.rawValue)
    private let sessionLogger = OSLog(subsystem: subsystem, category: LoggerAgentCategory.session.rawValue)
    
    func log(level: LoggerAgentLevel = .default, category: LoggerAgentCategory, message: String, file: String = #file, line: Int = #line) {
        
        let logMessage = "\(extractFileName(from: file)): \(message), #:\(line)"
        
        switch category {
        case .model:
            os_log("%@", log: modelLogger, type: level.osLogType, logMessage)
            
        case .ui:
            os_log("%@", log: uiLogger, type: level.osLogType, logMessage)
            
        case .network:
            os_log("%@", log: networkLogger, type: level.osLogType, logMessage)
            
        case .cache:
            os_log("%@", log: cacheLogger, type: level.osLogType, logMessage)
            
        case .session:
            os_log("%@", log: sessionLogger, type: level.osLogType, logMessage)
        }
    }
    
    private func extractFileName(from path: String) -> String {
        path.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
    }
}

extension LoggerAgentLevel {
    
    var osLogType: OSLogType {
        
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .default: return .default
        case .error: return .error
        case .fault: return .fault
        }
    }
}

