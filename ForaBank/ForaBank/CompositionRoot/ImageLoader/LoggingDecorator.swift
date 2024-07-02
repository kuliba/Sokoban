//
//  LoggingDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.07.2024.
//

import ForaTools

/// A decorator that logs the load operations of a `Loader`.
/// This class wraps around another `Loader` and logs the load requests and results.
final class LoggingDecorator<Payload, Response> {
    
    private let decoratee: any Decoratee
    private let log: Log
    
    /// Initialises a new `LoggingDecorator`.
    ///
    /// - Parameters:
    ///   - decoratee: The `Loader` instance to be decorated with logging.
    ///   - log: The logging function to be used for logging the load operations.
    init(
        decoratee: any Decoratee,
        log: @escaping Log
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingDecorator {
    
    /// The type of the decoratee `Loader`.
    typealias Decoratee = ForaTools.Loader<Payload, Response>
    
    /// The type of the log function.
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The log message.
    ///   - file: The file name where the log is being recorded.
    ///   - line: The line number where the log is being recorded.
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> Void
}

extension LoggingDecorator: ForaTools.Loader {
    
    /// Loads the given payload and logs the request and result.
    ///
    /// - Parameters:
    ///   - payload: The payload to be loaded.
    ///   - completion: The completion handler to be called with the response.
    func load(
        _ payload: Payload,
        _ completion: @escaping (Response) -> Void
    ) {
        log(.info, "Load request: \(payload).", #file, #line)
        
        decoratee.load(payload) { [log] response in
            
            log(.info, "Load result: \(response).", #file, #line)
            completion(response)
        }
    }
}
