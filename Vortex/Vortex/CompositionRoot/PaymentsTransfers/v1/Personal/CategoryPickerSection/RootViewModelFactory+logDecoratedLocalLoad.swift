//
//  RootViewModelFactory+logDecoratedLocalLoad.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.12.2024.
//

extension RootViewModelFactory {
    
    /// Loads values of a specified type from the local data source.
    ///
    /// The method attempts to load values using the local agent. If it successfully
    /// retrieves one or more values, it logs the count. Otherwise, it logs that no
    /// values were found.
    ///
    /// - Parameter type: The decodable array type to load. Default is `[T].self`.
    /// - Returns: An array of decoded values, or `nil` if none were found.
    @inlinable
    func logDecoratedLocalLoad<T: Decodable>(
        type: [T].Type = [T].self
    ) -> [T]? {
        
        let values = model.localAgent.load(type: type)
        
        guard let values = values,
              !values.isEmpty
        else {
            debugLog(category: .cache, message: "No values for type \(type).")
            return values
        }
        
        debugLog(category: .cache, message: "Loaded \(values.count) item(s) of type \(type).")
        return values
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
        logger.log(level: .debug, category: category, message: message, file: file, line: line)
    }
    
    @inlinable
    func debugLog(pageCount: Int, of total: Int) {
        
        debugLog(category: .cache, message: "Page with \(pageCount) item(s) of \(total) total.")
    }
}
