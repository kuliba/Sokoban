//
//  RequestFactory+getProductDetailsRequest.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation
import AccountInfoPanel

extension RequestFactory {
    
    static func createGetProductDetailsRequest(
        payload: ProductDetailsPayload
    ) throws -> URLRequest{
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getProductDetails
        let endpointURL = try! endpoint.url(withBase: base)

        return try GetProductDetailsRequestFactory.getProductDetailsRequest(
            url: endpointURL,
            payload: payload
        )
    }
}
