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
            
            return try JSONSerialization.data(withJSONObject: [
                "categoryType": category.rawValue,
                "products" : products.map {
                    [
                        "id": $0.productID,
                        "visibility": $0.visibility
                    ]
                }
            ] as [String: Any])
        }
    }
}
