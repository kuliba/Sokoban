//
//  RequestFactory+createGetBankDefaultRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Foundation

extension RequestFactory {
    
    static func createGetBankDefaultRequest(
        _ payload: FastPaymentsSettings.RequestFactory.PhoneNumber
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getBankDefault
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try FastPaymentsSettings.RequestFactory.createGetBankDefaultRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
