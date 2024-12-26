//
//  GetProductDynamicParamsListFactory.swift
//  Vortex
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
        logger: LoggerAgentProtocol,
        payload: ProductDynamicParamsListPayload
    ) async throws -> CardStatementAPI.DynamicParamsList {
        
        let networkLog = { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
     
        let data = try await getProductDynamicParamsList(
            httpClient: httpClient,
            log: { networkLog(.info, $0, $1, $2) }
        ).process(payload)
        
        return data
    }
    
    private func getProductDynamicParamsList(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> Services.GetProductDynamicParamsListService {
        
        Services.getProductDynamicParamsList(
            httpClient: httpClient,
            log: log
        )
    }
}

