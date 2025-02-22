//
//  Services+getProductDynamicParamsList.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.01.2024.
//

import CardStatementAPI
import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    typealias GetProductDynamicParamsListPayload = CardStatementAPI.ProductDynamicParamsListPayload
    typealias GetProductDynamicParamsListService = MappingRemoteService<GetProductDynamicParamsListPayload, CardStatementAPI.DynamicParamsList, CardStatementAPI.MappingError>
    
    static func getProductDynamicParamsList(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetProductDynamicParamsListService {
        
        LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.getProductDynamicParamsList,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetProductDynamicParamsList,
            log: log
        ).remoteService
    }
}
