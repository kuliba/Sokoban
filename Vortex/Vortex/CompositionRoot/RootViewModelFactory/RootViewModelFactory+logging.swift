//
//  RootViewModelFactory+logging.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.10.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func log(
        level: LoggerAgentLevel,
        category: LoggerAgentCategory,
        message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        
        logger.log(level: level, category: category, message: message, file: file, line: line)
    }
    
    @inlinable
    func infoNetworkLog(
        message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        
        logger.log(level: .info, category: .network, message: message, file: file, line: line)
    }
    
    @inlinable
    func errorLog(
        category: LoggerAgentCategory,
        message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        
        logger.log(level: .error, category: category, message: message, file: file, line: line)
    }
}

