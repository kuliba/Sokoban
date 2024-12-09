//
//  RequestFactory+createMakeDeleteBankDefaultRequest.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 04.10.2024.
//

import FastPaymentsSettings
import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createMakeDeleteBankDefaultRequest(
        payload: RemoteServices.RequestFactory.VerificationCode
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.makeDeleteBankDefault
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createMakeDeleteBankDefaultRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
