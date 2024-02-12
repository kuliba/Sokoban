//
//  RequestFactory+userVisibilityProductsSettingsRequest.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged

public extension RequestFactory {
        
    static func userVisibilityProductsSettingsRequest(
        url: URL,
        payload: Payload.ProductsVisibilityPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension Payload.ProductsVisibilityPayload {
    
    var httpBody: Data {
        
        get throws {
            
            let products: [[String: Any]] = products.map {
                [
                    "id": $0.productID.rawValue,
                    "visibility": $0.visibility.rawValue
                ]
            }
            return try JSONSerialization.data(withJSONObject: [
                "categoryType": category.rawValue,
                "products" : products
            ] as [String: Any])
        }
    }
}
