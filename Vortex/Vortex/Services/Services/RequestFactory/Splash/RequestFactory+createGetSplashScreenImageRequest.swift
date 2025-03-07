//
//  RequestFactory+createGetSplashScreenImageRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.03.2025.
//

import Foundation
import RemoteServices

extension RequestFactory {
    
    static func createGetSplashScreenImageRequest(
        splash: String
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getSplashScreenImage
        let endpointURL = try! endpoint.url(withBase: base)
        let url = try endpointURL.appendingQueryItems(parameters: ["splash": splash])
        
        return RemoteServices.RequestFactory.createEmptyRequest(.get, with: url)
    }
}
