//
//  RequestFactory+createCreateAnywayTransferNewRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.03.2024.
//

import AnywayPaymentBackend
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createCreateAnywayTransferNewRequest(
        _ payload: RemoteServices.RequestFactory.CreateAnywayTransferPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createAnywayTransfer
        let parameter = ("isNewPayment", "true")
        let endpointURL = try! endpoint.url(withBase: base, parameters: [parameter])
        
        return try RemoteServices.RequestFactory.createCreateAnywayTransferRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
