//
//  RequestFactory+createStickerRequest.swift
//  ForaBank
//
//  Created by Andrew Kurdin on 29.09.2023.
//

import Foundation

extension RequestFactory {
    
    static func createStickerRequest(
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
