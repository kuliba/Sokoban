//
//  RequestFactory+createGetVerificationCodeRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.06.2024.
//

import AnywayPaymentBackend
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createGetVerificationCodeRequest(
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getVerificationCode
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetVerificationCodeRequest(
            url: endpointURL
        )
    }
}
