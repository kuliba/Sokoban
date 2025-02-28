//
//  Services+getCardStatementService.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import CardStatementAPI
import Foundation
import GenericRemoteService
import RemoteServices

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
            mapResponse: RemoteServices.ResponseMapper.mapGetCardStatementResponse
        )
    }
}
