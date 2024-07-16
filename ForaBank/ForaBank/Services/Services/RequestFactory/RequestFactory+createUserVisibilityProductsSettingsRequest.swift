//
//  RequestFactory+createUserVisibilityProductsSettingsRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.07.2024.
//

import Foundation
import ProductProfile
import RemoteServices

extension RequestFactory {
    
    static func createUserVisibilityProductsSettingsRequest(
        payload: Payloads.ProductsVisibilityPayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.userVisibilityProductsSettings
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.userVisibilityProductsSettingsRequest(url: endpointURL, payload: payload)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
