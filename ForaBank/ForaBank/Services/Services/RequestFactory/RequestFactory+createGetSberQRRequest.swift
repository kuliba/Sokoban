//
//  RequestFactory+createGetSberQRRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

extension RequestFactory {
    
    static func createGetSberQRRequest(
        _ url: URL
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getSberQRData
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.httpBody = try? url.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

private extension URL {
    
    var json: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "QRLink": absoluteString
            ] as [String: String])
        }
    }
}
