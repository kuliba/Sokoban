//
//  RequestFactory+createChangeSVCardLimitRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.07.2024.
//

import Foundation
import SVCardLimitAPI
import RemoteServices

extension RequestFactory {
    
    static func createChangeSVCardLimitRequest(
        payload: ChangeSVCardLimitPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.changeSVCardLimit
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.createChangeSVCardLimitRequest(url: endpointURL, payload: payload)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
