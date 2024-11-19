//
//  RequestFactory+modifyC2BDataRequest.swift
//
//
//  Created by Дмитрий Савушкин on 14.11.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func modifyC2BDataRequest(
        url: URL,
        _ payload: ModifyC2BSubscription
    ) throws -> URLRequest {

        var request = createEmptyRequest(.post, with: url)
        request.httpBody = payload.json
        return request
    }
}

public struct ModifyC2BSubscription {
    
    let productId: Int
    public let productType: ProductType
    let subscriptionToken: String
    
    public init(
        productId: Int,
        productType: ProductType,
        subscriptionToken: String
    ) {
        self.productId = productId
        self.productType = productType
        self.subscriptionToken = subscriptionToken
    }
    
    public enum ProductType {
        case card
        case account
    }
}

private extension ModifyC2BSubscription {
    
    var json: Data? {
        
        try? JSONSerialization.data(withJSONObject: [
            "subscriptionToken": self.subscriptionToken,
            "productId": self.productId
        ] as [String: Any])
    }
}
