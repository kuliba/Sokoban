//
//  RequestFactory+ModifyC2B.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.11.2024.
//

import Foundation

extension RequestFactory {
    
    static func modifyC2BDataRequest(
        _ modifyC2BSubscription: ModifyC2BSubscription
    ) throws -> URLRequest {

        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.modifyC2BSubAccData
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = modifyC2BSubscription.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
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
