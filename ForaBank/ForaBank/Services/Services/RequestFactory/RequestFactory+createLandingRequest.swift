//
//  RequestFactory+createLandingRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2023.
//

import Foundation

extension RequestFactory {
    
    static func createLandingRequest(
        _ input: (
        serial: String,
        abroadType: AbroadType)
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", input.serial),
            ("type", input.abroadType.rawValue)
        ]
        let endpoint = Services.Endpoint.createLandingRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
}

private extension AbroadType {
    
    var rawValue: String {
        
        switch self {
        case .orderCard: return "abroadOrderCard"
        case .transfer:  return "abroadTransfer"
        }
    }
}
