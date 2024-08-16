//
//  RequestFactory+createGetProductListByTypeV6Request.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 15.08.2024.
//

import Foundation

extension RequestFactory {
    
    static func createGetProductListByTypeV6Request(
        _ productType: ProductType,
        _ timeout: TimeInterval = 120.0
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("productType", productType.rawValue)
        ]
        let endpoint = Services.Endpoint.getProductListByTypeV6
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
