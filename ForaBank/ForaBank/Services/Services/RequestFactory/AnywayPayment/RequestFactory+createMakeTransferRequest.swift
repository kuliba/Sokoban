//
//  RequestFactory+createMakeTransferRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPayment
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createMakeTransferRequest(
        _ payload: RemoteServices.RequestFactory.VerificationCode
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.makeTransfer
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createMakeTransferRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
