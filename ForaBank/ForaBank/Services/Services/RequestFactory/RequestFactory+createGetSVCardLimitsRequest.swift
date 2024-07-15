//
//  RequestFactory+createGetSVCardLimitsRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.07.2024.
//

import Foundation
import SVCardLimitAPI
import RemoteServices

extension RequestFactory {
    
    static func createGetSVCardLimitsRequest(
        payload: GetSVCardLimitsPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getSVCardLimits
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.createGetSVCardLimitsRequest(url: endpointURL, payload: payload)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
