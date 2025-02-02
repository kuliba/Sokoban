//
//  RequestFactory+createGetOpenAccountFormRequest.swift
//  Vortex
//
//  Created by Andryusina Nataly on 01.02.2025.
//

import Foundation

extension RequestFactory {
        
    static func createGetOpenAccountFormRequest(
        _ name: String
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getOpenAccountFormRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: [])

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
}
