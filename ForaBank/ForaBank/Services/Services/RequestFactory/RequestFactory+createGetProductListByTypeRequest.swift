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
        
        request.httpMethod = RequestMethod.get.rawValue
        
        return request
    }
}
