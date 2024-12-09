//
//  RequestFactory+createGetProductListByTypeRequest.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.03.2024.
//

import Foundation

extension RequestFactory {
    
    static func createGetProductListByTypeRequest(
        _ productType: ProductType,
        _ timeout: TimeInterval = 120.0
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("productType", productType.rawValue)
        ]
        let endpoint = Services.Endpoint.getProductListByType
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
