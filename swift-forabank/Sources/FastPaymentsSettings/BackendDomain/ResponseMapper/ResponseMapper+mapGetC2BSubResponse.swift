//
//  ResponseMapper+mapGetC2BSubResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetC2BSubResponseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetC2BSubscription> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetC2BSubscription {
        
        data.getC2BSubscription
    }
}

// MARK: - Adapters

private extension ResponseMapper._Data {
    
    var getC2BSubscription: GetC2BSubscription {
        
        .init(
            title: title,
            subscriptionType: subscriptionType.dto,
            emptyList: emptyList,
            emptySearch: emptySearch,
            list: list?.map(\.dto)
        )
    }
}

private extension ResponseMapper._Data.SubscriptionType {
    
    var dto: GetC2BSubscription.SubscriptionType {
        
        switch self {
        case .control: return .control
        case .empty:   return .empty
        }
    }
}

private extension ResponseMapper._Data.ProductSubscription {
    
    var dto: GetC2BSubscription.ProductSubscription {
        
        .init(
            productId: productId,
            productType: productType.dto,
            productTitle: productTitle,
            subscription: subscription.map(\.dto)
        )
    }
}

private extension ResponseMapper._Data.ProductSubscription.ProductType {
    
    var dto: GetC2BSubscription.ProductSubscription.ProductType {
        
        switch self {
        case .account: return .account
        case .card:    return .card
        }
    }
}

private extension ResponseMapper._Data.ProductSubscription.Subscription {
    
    var dto: GetC2BSubscription.ProductSubscription.Subscription {
        
        .init(
            subscriptionToken: subscriptionToken,
            brandIcon: brandIcon,
            brandName: brandName,
            subscriptionPurpose: subscriptionPurpose,
            cancelAlert: cancelAlert
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let title: String
        let subscriptionType: SubscriptionType
        let emptyList: [String]?
        let emptySearch: String?
        let list: [ProductSubscription]?
        
        enum SubscriptionType: String, Decodable {
            
            case control = "SUBSCRIPTION_CONTROL"
            case empty = "SUBSCRIPTION_EMPTY"
        }
        
        struct ProductSubscription: Decodable {
            
            let productId: String
            let productType: ProductType
            let productTitle: String
            let subscription: [Subscription]
            
            enum ProductType: String, Decodable {
                
                case account = "ACCOUNT"
                case card = "CARD"
            }
            
            struct Subscription: Decodable {
                
                let subscriptionToken: String
                let brandIcon: String
                let brandName: String
                let subscriptionPurpose: String
                let cancelAlert: String
            }
        }
    }
}
