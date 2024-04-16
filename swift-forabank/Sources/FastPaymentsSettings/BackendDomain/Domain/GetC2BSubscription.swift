//
//  GetC2BSubscription.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

/// - Warning: this data type resembles deficiencies of the backend data type. Could be improved: no need in `subscriptionType`, no need in optional arrays.
public struct GetC2BSubscription: Equatable {
    
    public let title: String
    public let subscriptionType: SubscriptionType
    public let emptyList: [String]?
    public let emptySearch: String?
    public let list: [ProductSubscription]?
    
    public init(
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
    
    public enum SubscriptionType: Equatable {
        
        case control, empty
    }
    
    public struct ProductSubscription: Equatable {
        
        public let productId: String
        public let productType: ProductType
        public let productTitle: String
        public let subscription: [Subscription]
        
        public init(
            productId: String,
            productType: ProductType,
            productTitle: String,
            subscription: [Subscription]
        ) {
            self.productId = productId
            self.productType = productType
            self.productTitle = productTitle
            self.subscription = subscription
        }
        
        public enum ProductType: Equatable {
            
            case account, card
        }
        
        public struct Subscription: Equatable {
            
            public let subscriptionToken: String
            public let brandIcon: String
            public let brandName: String
            public let subscriptionPurpose: String
            public let cancelAlert: String
            
            public init(
                subscriptionToken: String,
                brandIcon: String,
                brandName: String,
                subscriptionPurpose: String,
                cancelAlert: String
            ) {
                self.subscriptionToken = subscriptionToken
                self.brandIcon = brandIcon
                self.brandName = brandName
                self.subscriptionPurpose = subscriptionPurpose
                self.cancelAlert = cancelAlert
            }
        }
    }
}
