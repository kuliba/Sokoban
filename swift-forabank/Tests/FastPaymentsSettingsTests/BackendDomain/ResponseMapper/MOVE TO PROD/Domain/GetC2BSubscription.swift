//
//  GetC2BSubscription.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

/// - Warning: this data type resembles deficiencies of the backend data type. Could be improved: no need in `subscriptionType`, no need in optional arrays.
struct GetC2BSubscription: Equatable {
    
    let title: String
    let subscriptionType: SubscriptionType
    let emptyList: [String]?
    let emptySearch: String?
    let list: [ProductSubscription]?
    
    init(
        title: String,
        subscriptionType: SubscriptionType,
        emptyList: [String]? = nil,
        emptySearch: String? = nil,
        list: [ProductSubscription]? = nil
    ) {
        self.title = title
        self.subscriptionType = subscriptionType
        self.emptyList = emptyList
        self.emptySearch = emptySearch
        self.list = list
    }
    
    enum SubscriptionType: Equatable {
        
        case control, empty
    }
    
    struct ProductSubscription: Equatable {
        
        let productId: String
        let productType: ProductType
        let productTitle: String
        let subscription: [Subscription]
        
        enum ProductType: Equatable {
            
            case account, card
        }
        
        struct Subscription: Equatable {
            
            let subscriptionToken: String
            let brandIcon: String
            let brandName: String
            let subscriptionPurpose: String
            let cancelAlert: String
        }
    }
}
