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
    
    private let modelLogger = OSLog(subsystem: "ru.forabank.sense", category: LoggerAgentCategory.model.rawValue)
    private let uiLogger = OSLog(subsystem: "ru.forabank.sense", category: LoggerAgentCategory.ui.rawValue)
    private let networkLogger = OSLog(subsystem: "ru.forabank.sense", category: LoggerAgentCategory.network.rawValue)
    private let cacheLogger = OSLog(subsystem: "ru.forabank.sense", category: LoggerAgentCategory.cache.rawValue)
    private let paymentsLogger = OSLog(subsystem: "ru.forabank.sense", category: LoggerAgentCategory.payments.rawValue)
    
    func log(level: LoggerAgentLevel = .default, category: LoggerAgentCategory, file: String = #file, line: Int = #line, message: String) {
        
        let logMessage = "\(message)\n[FILE]: \(extractFileName(from: file)) [LINE]: \(line)"
        
        switch category {
        case .model:
            os_log("%@", log: modelLogger, type: level.osLogType, logMessage)
            
        case .ui:
            os_log("%@", log: uiLogger, type: level.osLogType, logMessage)
            
        case .network:
            os_log("%@", log: networkLogger, type: level.osLogType, logMessage)
            
        case .cache:
            os_log("%@", log: cacheLogger, type: level.osLogType, logMessage)
            
        case .payments:
            os_log("%@", log: paymentsLogger, type: level.osLogType, logMessage)
        }
    }
    
    private func extractFileName(from path: String) -> String {
        path.components(separatedBy: "/").last ?? ""
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

