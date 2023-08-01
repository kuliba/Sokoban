//
//  LoggingURLSessionDelegate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

final class LoggingURLSessionDelegate: NSObject, URLSessionTaskDelegate {
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    private let log: Log
    
    init(log: @escaping Log) {
        
        self.log = log
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
        log(.error, .network, "URL Session did become invalid with error: \(error?.localizedDescription ?? "no error")", #file, #line)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        log(.error, .network, "URLSessionTask: \(String(describing: task.originalRequest?.url)) did complete with error: \(error?.localizedDescription ?? "no error")", #file, #line)
    }
}
