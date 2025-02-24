//
//  RequestFactory+createPrepareOpenSavingsAccountRequest.swift
//  Vortex
//
//  Created by Andryusina Nataly on 19.02.2025.
//

import Foundation

extension RequestFactory {

    static func createPrepareOpenSavingsAccountRequest() throws -> URLRequest {
        
        let endpoint = Services.Endpoint.prepareOpenSavingsAccountRequest
        let url = try! endpoint.url(withBase: Config.serverAgentEnvironment.baseURL)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
