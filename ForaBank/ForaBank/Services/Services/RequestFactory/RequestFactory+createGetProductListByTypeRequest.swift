//
//  RequestFactory+createGetProductListByTypeRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.03.2024.
//

import Foundation

extension RequestFactory {
    
    static func createGetProductListByTypeRequest(
        _ productType: ProductType
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getProductListByType
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.httpBody = try? productType.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

private extension ProductType {
    
    var json: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "productType": self.rawValue
            ] as [String: String])
        }
    }
}
