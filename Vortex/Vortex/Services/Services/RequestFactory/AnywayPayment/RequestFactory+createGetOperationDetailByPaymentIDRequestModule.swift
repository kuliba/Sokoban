//
//  RequestFactory+createGetOperationDetailByPaymentIDRequestModule.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPaymentBackend
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createGetOperationDetailByPaymentIDRequestModule(
        _ payload: RemoteServices.RequestFactory.OperationDetailID
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.makeTransfer
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetOperationDetailByPaymentIDRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
