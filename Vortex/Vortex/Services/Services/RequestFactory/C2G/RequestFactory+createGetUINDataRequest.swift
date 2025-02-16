//
//  RequestFactory+createGetUINDataRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GBackend
import Foundation
import RemoteServices

extension RequestFactory {
    
    @inlinable
    static func createGetUINDataRequest(
        uin: String
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getUINData
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetUINDataRequest(
            url: endpointURL,
            payload: .init(uin: uin)
        )
    }
}
