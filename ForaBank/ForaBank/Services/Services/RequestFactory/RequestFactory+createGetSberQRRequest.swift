//
//  RequestFactory+createGetSberQRRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

extension RequestFactory {
    
    static func createGetSberQRRequest(
        _ input: QRLink
    ) throws -> URLRequest {
        
        guard !input.link.isEmpty else {
            throw QRDataError.emptyLink
        }
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getSberQRDataRequest
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? input.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

private extension QRLink {
    
    var json: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "QRLink": link.rawValue
            ] as [String: String])
        }
    }
}
