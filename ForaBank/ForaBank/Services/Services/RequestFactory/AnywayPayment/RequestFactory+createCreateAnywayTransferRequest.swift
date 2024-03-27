//
//  RequestFactory+createCreateAnywayTransferRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.03.2024.
//

import AnywayPayment
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createCreateAnywayTransferRequest(
        _ payload: RemoteServices.RequestFactory.CreateAnywayTransferPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createAnywayTransfer
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createCreateAnywayTransferRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
