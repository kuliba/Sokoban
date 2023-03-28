//
//  LoggerAgentProtocol.swift
//  ForaBank
//
//  Created by Дмитрий on 16.08.2022.
//

import Foundation
import OSLog

protocol LoggerAgentProtocol {
    
    func log(level: LoggerAgentLevel, category: LoggerAgentCategory, message: String, file: StaticString, line: UInt)
}

enum LoggerAgentLevel {
    
    case debug
    case info
    case `default`
    case error
    case fault
}

enum LoggerAgentCategory: String, CaseIterable {
    
    case model
    case ui
    case network
    case cache
    case session
    case payments
}
