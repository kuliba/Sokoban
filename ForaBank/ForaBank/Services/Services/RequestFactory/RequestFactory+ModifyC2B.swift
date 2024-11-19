//
//  RequestFactory+ModifyC2B.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.11.2024.
//

import Foundation
import RemoteServices
import ModifyC2BSubscriptionService

extension RequestFactory {
    
    static func modifyC2BDataRequest(
        payload: ModifyC2BSubscription
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint: Services.Endpoint = payload.productType == .card ? .modifyC2BSubCardData : .modifyC2BSubAccData
        let endpointURL = try! endpoint.url(withBase: base)
        
        var request = try RemoteServices.RequestFactory.modifyC2BDataRequest(url: endpointURL, payload)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
