//
//  RootViewModelFactory+logging.swift
//  Vortex
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
        infra.logger.log(level: level, category: category, message: message, file: file, line: line)
    }
    
    @inlinable
    func infoNetworkLog(
        message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        log(level: .info, category: .network, message: message, file: file, line: line)
    }
    
    @inlinable
    func errorLog(
        category: LoggerAgentCategory,
        message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        log(level: .error, category: category, message: message, file: file, line: line)
    }
    
    /// Logs a message at the debug level with the specified category.
    ///
    /// - Parameters:
    ///   - category: The log category.
    ///   - message: The message to log.
    ///   - file: The file from which this method is called.
    ///   - line: The line number from which this method is called.
    @inlinable
    func debugLog(
        category: LoggerAgentCategory,
        message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        log(level: .debug, category: category, message: message, file: file, line: line)
    }
    
    @inlinable
    func debugLog(pageCount: Int, of total: Int) {
        
        debugLog(category: .cache, message: "Page with \(pageCount) item(s) of \(total) total.")
    }
}
