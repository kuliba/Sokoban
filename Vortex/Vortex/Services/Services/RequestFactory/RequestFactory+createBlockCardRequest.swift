//
//  RequestFactory+createBlockCardRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import ProductProfile
import RemoteServices

extension RequestFactory {
    
    static func createBlockCardRequest(
        payload: Payloads.CardPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.blockCard
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.blockCardRequest(url: endpointURL, payload: payload)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
