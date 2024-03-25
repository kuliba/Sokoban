//
//  RequestFactory+createUpdateFastPaymentContractRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createUpdateFastPaymentContractRequest(
        _ payload: RemoteServices.RequestFactory.UpdateFastPaymentContractPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.updateFastPaymentContract
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createUpdateFastPaymentContractRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
