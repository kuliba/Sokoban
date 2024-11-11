//
//  RequestFactory+ModifyC2B.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.11.2024.
//

import Foundation
import RemoteServices

extension RequestFactory {
    
    static func modifyC2BDataRequest(
        _ modifyC2BSubscription: ModifyC2BSubscription
    ) throws -> URLRequest {

        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = modifyC2BSubscription.productType == .card ? Services.Endpoint.modifyC2BSubCardData : Services.Endpoint.modifyC2BSubAccData
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = modifyC2BSubscription.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

public struct ModifyC2BSubscription {
    
    let productId: Int
    let productType: ProductType
    let subscriptionToken: String
    
    init(
        productId: Int,
        productType: ProductType,
        subscriptionToken: String
    ) {
        self.productId = productId
        self.productType = productType
        self.subscriptionToken = subscriptionToken
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
