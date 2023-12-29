//
//  RequestFactory+createEmptyRequest.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation

public extension RequestFactory {
    
    static func createEmptyRequest(
        _ httpMethod: URLRequest.HTTPMethod,
        with url: URL
    ) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

public extension URLRequest {
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
    }
}
