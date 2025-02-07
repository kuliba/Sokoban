//
//  RequestFactory+createGetCardOrderFormRequest.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 07.02.2025.
//

import Foundation
import GetCardOrderFormService
import RemoteServices

extension RequestFactory {
    
    static func createGetCardOrderFormRequest() throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getCardOrderForm
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.createGetCardOrderFormRequest(url: endpointURL)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
