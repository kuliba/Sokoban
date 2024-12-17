//
//  RequestFactory+createCreateAnywayTransferRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.03.2024.
//

import AnywayPaymentBackend
import Foundation
import RemoteServices

extension ForaBank.RequestFactory {
    
    static func createCreateAnywayTransferRequest(
        _ payload: RemoteServices.RequestFactory.CreateAnywayTransferPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createAnywayTransfer(version: nil)
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createCreateAnywayTransferRequest(
            url: endpointURL,
            payload: payload
        )
    }
    
    static func createCreateAnywayTransferV2Request(
        _ payload: RemoteServices.RequestFactory.CreateAnywayTransferPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createAnywayTransfer(version: .v2)
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createCreateAnywayTransferRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
