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
    
    static func factory(
        for endpoint: Services.Endpoint,
        with parameters: [(String, String)] = []
    ) throws -> URLRequestFactory {
        
        let url = try endpoint.url(
            withBase: endpoint.serviceName.baseURL,
            parameters: parameters
        )
        
        return .init(url: url)
    }
}

extension Services.Endpoint.ServiceName {
    
    var baseURL: String {
        
        switch self {
            
        case .getProcessingSessionCode:
#if RELEASE
            return "https://bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
#else
            return "https://pl.forabank.ru/dbo/api/v3"
#endif
            
        default:
#if RELEASE
            return "https://dmz-api-gate.forabank.ru"
#else
            return "https://dmz-api-gate-test.forabank.ru"
#endif
            
        }
    }
}
