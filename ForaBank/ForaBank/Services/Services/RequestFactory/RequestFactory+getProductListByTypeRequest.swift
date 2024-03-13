//
//  RequestFactory+getProductListByTypeRequest.swift
//  ForaBank
//
//  Created by Disman Dmitry on 10.03.2024.
//

import Foundation

extension RequestFactory {
    
    static func makeGetProductListByTypeRequest(
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
        request.httpMethod = "GET"

        return request
    }
}
