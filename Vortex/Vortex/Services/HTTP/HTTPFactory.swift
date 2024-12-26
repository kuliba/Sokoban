//
//  HTTPFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation
import SharedAPIInfra

/// A namespace.
enum HTTPFactory {}

// TODO: Move to the Composition Root
extension HTTPFactory {
    
    static func loggingNoSharedCookieStoreURLSessionHTTPClient(
    ) -> HTTPClient {
        
        let delegate = LoggingURLSessionDelegate(log: LoggerAgent.shared.log)
        
        return URLSessionHTTPClient.noSharedCookieStore(delegate: delegate)
    }
}

extension URLSessionHTTPClient: HTTPClient {
    
    public func performRequest(
        _ request: URLRequest,
        completion: @escaping (Swift.Result<(Data, HTTPURLResponse), Swift.Error>) -> Void
    ) {
        
        perform(request) { result in
            
            completion(.init { try result.get() })
        }
    }
}

extension HTTPFactory {
    
    static func cachelessLoggingNoSharedCookiesURLSessionHTTPClient(
    ) -> HTTPClient {
        
        let delegate = LoggingURLSessionDelegate(log: LoggerAgent.shared.log)
        
        return URLSessionHTTPClient.noSharedCookieStoreNoUrlCache(delegate: delegate)
    }
}
