//
//  RequestFactory+createCreateSberQRPaymentRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.12.2023.
//

import Foundation
import SberQR

extension RequestFactory {
    
    static func createCreateSberQRPaymentRequest(
        payload: CreateSberQRPaymentPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createSberQRPayment
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.httpBody = try payload.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
