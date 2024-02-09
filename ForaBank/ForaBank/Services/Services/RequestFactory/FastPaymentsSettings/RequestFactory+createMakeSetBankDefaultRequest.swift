//
//  RequestFactory+createMakeSetBankDefaultRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Foundation

extension RequestFactory {
    
    static func createMakeSetBankDefaultRequest(
        payload: FastPaymentsSettings.RequestFactory.VerificationCode
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.makeSetBankDefault
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try FastPaymentsSettings.RequestFactory.createMakeSetBankDefaultRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
