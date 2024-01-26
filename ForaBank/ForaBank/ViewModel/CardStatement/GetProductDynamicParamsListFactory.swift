//
//  GetProductDynamicParamsListFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.01.2024.
//

import Foundation
import CardStatementAPI
import Tagged

extension Services {
    
    typealias ProductDynamicParamsListPayload = CardStatementAPI.ProductDynamicParamsListPayload
    
    static func makeGetProductDynamicParamsList(
        httpClient: HTTPClient,
        payload: ProductDynamicParamsListPayload
    ) async throws-> CardStatementAPI.DynamicParamsList {
        
        let data = try await getProductDynamicParamsList(httpClient: httpClient).process(payload).get()
        
        return data
    }
    
    private func getProductDynamicParamsList(
        httpClient: HTTPClient
    ) -> Services.GetProductDynamicParamsListService {
        
        Services.getProductDynamicParamsList(
            httpClient: httpClient
        )
    }
}

