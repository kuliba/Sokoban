//
//  RequestFactory+createGetCardShowCaseRequest.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createGetCardShowCaseRequest() throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getCardShowcase
        let endpointURL = try! endpoint.url(withBase: base)
        
        return RemoteServices.RequestFactory.createEmptyRequest(.get, with: endpointURL)
    }
}
