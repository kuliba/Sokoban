//
//  RequestFactory+userVisibilityProductsSettingsRequest.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged
import RemoteServices

public extension RequestFactory {
        
    static func userVisibilityProductsSettingsRequest(
        url: URL,
        payload: Payloads.ProductsVisibilityPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension Payloads.ProductsVisibilityPayload {
    
    var httpBody: Data {
        
        get throws {
            
            let products: [[String: Any]] = products.map {[
                "id": $0.productID.rawValue,
                "visibility": $0.visibility.rawValue
            ]}

            return try JSONSerialization.data(withJSONObject: [
                "categoryType": category.rawValue,
                "products" : products
            ] as [String: Any])
        }
    }
}

private extension Payloads.ProductsVisibilityPayload.Category {
    
    enum _Category: String {
        
        case card = "CARD"
        case account = "ACCOUNT"
        case deposit = "DEPOSIT"
        case loan = "LOAN"
    }

    var rawValue: String {
        
        let _category: _Category = {
            switch self {
            case .card:
                return .card
            case .account:
                return .account
            case .deposit:
                return .deposit
            case .loan:
                return .loan
            }
        }()
        return _category.rawValue
    }
}
