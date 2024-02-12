//
//  RequestFactory+getProductDynamicParamsList.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.01.2024.
//

import Foundation
import Tagged
import CardStatementAPI

extension RequestFactory {
    
    static func getProductDynamicParamsList(
        payload: CardStatementAPI.ProductDynamicParamsListPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getProductDynamicParamsList
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try payload.httpBody
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
