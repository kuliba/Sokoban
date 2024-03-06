//
//  GetProductDetailsFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation
import AccountInfoPanel
import Tagged

extension Services {
    
    static func makeGetProductDetails(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        payload: ProductDetailsPayload
    ) async throws -> ProductDetails {
        
        let networkLog = { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
     
        let data = try await getProductDetails(
            httpClient: httpClient,
            log: { networkLog(.info, $0, $1, $2) }
        ).process(payload)
        
        return data
    }
    
    private func getProductDetails(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> Services.GetProductDetailsService {
        
        Services.getProductDetails(
            httpClient: httpClient,
            log: log
        )
    }
}
