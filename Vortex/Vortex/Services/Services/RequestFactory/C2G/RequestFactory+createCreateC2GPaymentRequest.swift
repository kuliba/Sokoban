//
//  RequestFactory+createCreateC2GPaymentRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GBackend
import Foundation
import RemoteServices

extension RequestFactory {
    
    @inlinable
    static func createCreateC2GPaymentRequest(
        payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createC2GPayment
        let endpointURL = try! endpoint.url(withBase: base)
        
        let request = try RemoteServices.RequestFactory.createCreateC2GPaymentRequest(
            url: endpointURL,
            payload: payload
        )
        
        return request
    }
}
