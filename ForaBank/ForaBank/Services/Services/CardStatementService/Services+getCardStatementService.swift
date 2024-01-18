//
//  Services+getCardStatementService.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation
import GenericRemoteService

extension Services {
    
    typealias GetCardStatement = CardStatementForPeriodDomain.Payload
    typealias GetCardStatementResult = Swift.Result<[ProductStatementData], ProductStatementMapper.MapperError>
    typealias GetCardStatementService = RemoteServiceOf<GetCardStatement, GetCardStatementResult>
    
    static func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> GetCardStatementService {
        
        return .init(
            createRequest: RequestFactory.getCardStatementForPeriod,
            performRequest: httpClient.performRequest,
            mapResponse: ProductStatementMapper.map
        )
    }
}
