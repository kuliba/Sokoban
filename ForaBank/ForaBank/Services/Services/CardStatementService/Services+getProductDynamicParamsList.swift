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
    
    typealias ProductDynamicParamsListPayload = CardStatementAPI.ProductDynamicParamsListPayload
    typealias ProductDynamicParamsListResult = Swift.Result<CardStatementAPI.DynamicParamsList, CardStatementAPI.MappingError>
    typealias ProductDynamicParamsListService = RemoteServiceOf<ProductDynamicParamsListPayload, ProductDynamicParamsListResult>
    
    static func getProductDynamicParamsList(
        httpClient: HTTPClient
    ) -> ProductDynamicParamsListService {
        
        return .init(
            createRequest: RequestFactory.getProductDynamicParamsList,
            performRequest: httpClient.performRequest,
            mapResponse: CardStatementAPI.ResponseMapper.mapGetProductDynamicParamsList
        )
    }
}
