//
//  Services+getProductListByTypeService.swift
//  ForaBank
//
//  Created by Disman Dmitry on 10.03.2024.
//

import Foundation
import GenericRemoteService
import GetProductListByTypeService

extension Services {
        
    typealias GetProductListByTypePayload = GetProductListByTypeService.ProductListData.ProductType
    typealias GetProductListByTypeRemoteService = MappingRemoteService<GetProductListByTypePayload, GetProductListByTypeService.ProductListData, GetProductListByTypeService.MappingError>
    
    static func makeGetProductListByTypeService(
        httpClient: HTTPClient
    ) -> GetProductListByTypeRemoteService {
        
        return .init(
            createRequest: RequestFactory.getProductListByTypeRequest,
            performRequest: httpClient.performRequest,
            mapResponse: GetProductListByTypeService.ResponseMapper.mapGetCardStatementResponse
        )
    }
}
