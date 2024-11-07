//
//  Services+ModifyC2B.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.11.2024.
//

import Foundation
import GenericRemoteService

extension Services {
    
    typealias ModifyC2BResult = Swift.Result<C2BSubscriptionData, C2BSubscriptionData.MapperError>
    typealias ModifyC2BData = RemoteService<ModifyC2BSubscription, ModifyC2BResult, Error, Error, Error>
    
    static func modifyC2BData(
        _ modifyC2BSubscription: ModifyC2BSubscription,
        httpClient: HTTPClient
    ) -> ModifyC2BData {
        
        return .init(
            createRequest: RequestFactory.modifyC2BDataRequest(_:),
            performRequest: httpClient.performRequest,
            mapResponse: { ResponseMapper.mapModifyC2BSubscriptionResponse($0, $1) }
        )
    }
}

struct ModifyC2BSubscription {
    
    let productId: Int
    let productType: ProductType
    let subscriptionToken: String
    
    enum ProductType {
        
        case card
        case account
    }
}
