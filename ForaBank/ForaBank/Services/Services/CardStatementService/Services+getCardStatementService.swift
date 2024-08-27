//
//  Services+getCardStatementService.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation
import GenericRemoteService
import CardStatementAPI

extension Services {
    
    typealias GetCardStatementPayload = CardStatementAPI.CardStatementForPeriodPayload
    typealias GetCardStatementResult = Swift.Result<CardStatementAPI.ProductStatementWithExtendedInfo, CardStatementAPI.MappingError>
    typealias GetCardStatementService = RemoteServiceOf<GetCardStatementPayload, GetCardStatementResult>
    
    static func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> GetCardStatementService {
        
        return .init(
            createRequest: RequestFactory.getCardStatementForPeriod,
            performRequest: httpClient.performRequest,
            mapResponse: CardStatementAPI.ResponseMapper.mapGetCardStatementResponse
        )
    }
}
