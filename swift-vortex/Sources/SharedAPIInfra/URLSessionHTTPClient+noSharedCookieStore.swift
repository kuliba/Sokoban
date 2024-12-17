//
//  URLSessionHTTPClient+noSharedCookieStore.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

extension URLSessionHTTPClient {
    
    public static func noSharedCookieStore(
        delegate: URLSessionDelegate?
    ) -> Self {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        return .init(session: session)
    }
}
