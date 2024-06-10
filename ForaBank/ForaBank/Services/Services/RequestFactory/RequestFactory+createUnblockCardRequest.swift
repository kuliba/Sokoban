//
//  RequestFactory+createUnblockCardRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 07.05.2024.
//

import Foundation
import ProductProfile
import RemoteServices

extension RequestFactory {
    
    static func createUnblockCardRequest(
        payload: Payloads.CardPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.unblockCard
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.unblockCardRequest(url: endpointURL, payload: payload)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
