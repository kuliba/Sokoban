//
//  LoggerAgentProtocol.swift
//  ForaBank
//
//  Created by Дмитрий on 16.08.2022.
//

import Foundation
import OSLog

protocol LoggerAgentProtocol {
    
    func log(level: LoggerAgentLevel, category: LoggerAgentCategory, file: String, line: Int, message: String)
}

enum LoggerAgentLevel {
    
    case debug
    case info
    case `default`
    case error
    case fault
}

enum LoggerAgentCategory: String {
    
    case model
    case ui
    case network
    case cache
    case payments
}
