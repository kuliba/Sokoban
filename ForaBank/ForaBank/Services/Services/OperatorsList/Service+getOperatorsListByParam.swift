//
//  Service+getOperatorsListByParam.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.02.2024.
//

import Foundation
import GenericRemoteService
import OperatorsListComponents
import RemoteServices

extension Services {
    
    typealias GetOperatorListResult = Swift.Result<[OperatorsListComponents.SberOperator], RemoteServices.ResponseMapper.MappingError>
    typealias GetOperatorListService = RemoteServiceOf<(String?, String), GetOperatorListResult>
    
    static func getOperatorsListByParam(
        httpClient: HTTPClient
    ) -> GetOperatorListService {
        
        return .init(
            createRequest: RequestFactory.getOperatorsListByParam,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapAnywayOperatorsListResponse
        )
    }
}
