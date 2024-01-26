//
//  Services+getProductDynamicParamsList.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.01.2024.
//

import Foundation
import GenericRemoteService
import CardStatementAPI

extension Services {
    
    typealias GetProductDynamicParamsListPayload = CardStatementAPI.ProductDynamicParamsListPayload
    typealias GetProductDynamicParamsListResult = Swift.Result<CardStatementAPI.DynamicParamsList, CardStatementAPI.MappingError>
    typealias GetProductDynamicParamsListService = RemoteServiceOf<GetProductDynamicParamsListPayload, GetProductDynamicParamsListResult>
    
    static func getProductDynamicParamsList(
        httpClient: HTTPClient
    ) -> GetProductDynamicParamsListService {
        
        return .init(
            createRequest: RequestFactory.getProductDynamicParamsList,
            performRequest: httpClient.performRequest,
            mapResponse: CardStatementAPI.ResponseMapper.mapGetProductDynamicParamsList
        )
    }
}
