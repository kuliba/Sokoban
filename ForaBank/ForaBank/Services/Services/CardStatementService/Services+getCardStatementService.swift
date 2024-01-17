//
//  Services+getCardStatementService.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation
import GenericRemoteService

extension Services {
    
    typealias GetCardStatement = (CardStatementForPeriodDomain.Payload)
    typealias GetCardStatementResult = Swift.Result<[ProductStatementData], ProductStatementMapper.MapperError>
    typealias GetCardStatementData = RemoteService<GetCardStatement, GetCardStatementResult, Error, Error, Error>
    
    static func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> GetCardStatementData {
        
        return .init(
            createRequest: RequestFactory.getCardStatementForPeriod,
            performRequest: httpClient.performRequest,
            mapResponse: { ProductStatementMapper.map($0, $1) }
        )
    }
}
