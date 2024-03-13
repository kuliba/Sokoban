//
//  Services+getProductListByTypeService.swift
//  ForaBank
//
//  Created by Disman Dmitry on 10.03.2024.
//

import Foundation
import GenericRemoteService

extension Services {
    
    typealias ProductList = ServerCommands.ProductController.GetProductListByType.Response.List
    
    typealias GetProductListByTypePayload = ProductType
    typealias GetProductListByTypeResult = Result<ProductList, GetProductListByTypeResultError>
    typealias GetProductListByTypeService = RemoteServiceOf<GetProductListByTypePayload, GetProductListByTypeResult>
    
    static func makeGetProductListByTypeService(
        httpClient: HTTPClient
    ) -> GetProductListByTypeService {
        
        return .init(
            createRequest: RequestFactory.makeGetProductListByTypeRequest,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapMakeProductListResponse
        )
    }
}
