//
//  Service+getOperatorsListByParam.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.02.2024.
//

import Foundation
import GenericRemoteService
import OperatorsListComponents

extension Services {
    
    typealias GetOperatorListResult = Swift.Result<[OperatorsListComponents.SberOperator], OperatorsListComponents.ResponseMapper.MappingError>
    typealias GetOperatorListService = RemoteServiceOf<String, GetOperatorListResult>
    
    static func getOperatorsListByParam(
        httpClient: HTTPClient
    ) -> GetOperatorListService {
        
        return .init(
            createRequest: RequestFactory.getOperatorsListByParam,
            performRequest: httpClient.performRequest,
            mapResponse: OperatorsListComponents.ResponseMapper.mapAnywayOperatorsListResponse
        )
    }
}
