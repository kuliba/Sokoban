//
//  RequestFactory+getScenarioQRData.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Foundation

extension RequestFactory {
    
    static func getScenarioQRDataRequest(
        _ input: (QRLink)
    ) throws -> URLRequest {
        
        guard !input.link.isEmpty else {
            throw QRDataError.emptyLink
        }

        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getScenarioQRData
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = input.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
    
    enum QRDataError: Error, Equatable {
        
        case emptyLink
    }
}

private extension QRLink {
    
    var json: Data? {
        
        try? JSONSerialization.data(withJSONObject: [
            "QRLink": link.rawValue
        ] as [String: Any])
    }
}
