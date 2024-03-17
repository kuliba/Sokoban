//
//  Services+makeGetProductListByTypeResult.swift
//  ForaBank
//
//  Created by Disman Dmitry on 14.03.2024.
//

import Foundation
import GetProductListByTypeService

extension Services {
        
    typealias ProductList = ServerCommands.ProductController.GetProductListByType.Response.List
    
    static func makeGetProductListByTypeResult(
        httpClient: HTTPClient,
        payload: GetProductListByTypePayload
    ) async throws -> ProductList {
        
        let data = try await Services.makeGetProductListByTypeService(
            httpClient: httpClient
        ).process(payload)
                
        return ProductListMapper.map(data)
    }
}
