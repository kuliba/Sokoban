//
//  RequestFactory+createEmptyRequest.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation

public extension RequestFactory {
    
    static func createEmptyRequest(
        _ httpMethod: URLRequest.HTTPMethod,
        with url: URL,
        cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    ) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = cachePolicy
        return request
    }
}

public extension URLRequest {
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
    }
}
