//
//  URLSessionHTTPClient+noSharedCookieStoreNoUrlCache.swift
//  
//
//  Created by Andryusina Nataly on 03.10.2023.
//

import Foundation

extension URLSessionHTTPClient {
    
    public static func noSharedCookieStoreNoUrlCache(
        delegate: URLSessionDelegate?
    ) -> Self {
        
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForResource = 120
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        return .init(session: session)
    }
}
