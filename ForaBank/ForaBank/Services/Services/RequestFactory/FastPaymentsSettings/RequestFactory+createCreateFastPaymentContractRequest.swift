//
//  RequestFactory+createCreateFastPaymentContractRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createCreateFastPaymentContractRequest(
        _ payload: RemoteServices.RequestFactory.CreateFastPaymentContractPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createFastPaymentContract
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createCreateFastPaymentContractRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
