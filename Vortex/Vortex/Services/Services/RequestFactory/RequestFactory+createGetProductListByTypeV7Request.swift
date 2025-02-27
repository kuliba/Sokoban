//
//  RequestFactory+createGetProductListByTypeV7Request.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation

extension RequestFactory {
    
    static func createGetProductListByTypeV7Request(
        _ productType: ProductType,
        _ timeout: TimeInterval = 120.0
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("productType", productType.rawValue)
        ]
        let endpoint = Services.Endpoint.getProductListByTypeV7
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = timeout
        request.httpMethod = RequestMethod.get.rawValue
        
        return request
    }
}
