//
//  RequestFactory+createGetSavingLanding.swift
//
//
//  Created by Andryusina Nataly on 06.12.2024.
//

import Foundation

extension RequestFactory {
        
    static func createGetSavingLandingRequest(
        _ name: String
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("name", name)
        ]
        let endpoint = Services.Endpoint.getSavingLandingRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
}
