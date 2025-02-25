//
//  RequestFactory+createGetSavingsAccountInfoRequest.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation
import RemoteServices
import SavingsServices

extension RequestFactory {

    static func createGetSavingsAccountInfoRequest(
        payload: GetSavingsAccountInfoPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getSavingsAccountInfoRequest
        let url = try! endpoint.url(withBase: Config.serverAgentEnvironment.baseURL)

        return try RemoteServices.RequestFactory.createGetSavingsAccountInfoRequest(
            payload: payload,
            url: url)
    }
}
