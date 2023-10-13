//
//  RequestFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import Foundation
import URLRequestFactory

/// A namespace.
enum RequestFactory {}

extension RequestFactory {
    
    enum APIConfig {
        
#if RELEASE
        static let processingServerURL = "https://dmz-api-gate.forabank.ru"
#else
        static let processingServerURL = "https://dmz-api-gate-test.forabank.ru"
#endif
    }
}

extension RequestFactory {
    
    static func factory(
        for endpoint: Services.Endpoint,
        with parameters: [(String, String)] = []
    ) throws -> URLRequestFactory {
        
        let url = try endpoint.url(
            withBase: APIConfig.processingServerURL,
            parameters: parameters
        )
        
        return .init(url: url)
    }
}
