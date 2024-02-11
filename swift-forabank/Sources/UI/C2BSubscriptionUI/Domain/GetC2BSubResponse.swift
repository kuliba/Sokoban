//
//  GetC2BSubResponse.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

#warning("improve: replace primitive types")
public struct GetC2BSubResponse: Equatable {
    
    public let title: String
    public let explanation: [String]
    public let details: Details
    
    public init(
        title: String,
        explanation: [String],
        details: Details
    ) {
        self.title = title
        self.explanation = explanation
        self.details = details
    }
}

public extension GetC2BSubResponse {
    
    enum Details: Equatable {
        
        case empty
        case list([ProductSubscription])
    }
}

public extension GetC2BSubResponse.Details {
    
    struct ProductSubscription: Equatable {
        
        public let product: Product
        public let subscriptions: [Subscription]
        
        public init(
            product: Product,
            subscriptions: [Subscription]
        ) {
            self.product = product
            self.subscriptions = subscriptions
        }
    }
}

public extension GetC2BSubResponse.Details.ProductSubscription {
    
    enum ProductType {
        
        case account, card
    }
    
    struct Subscription: Equatable {
        
        #warning("rename `subscriptionToken` to `token")
        public let subscriptionToken: String
        public let brandIcon: String
        public let brandName: String
        #warning("rename `subscriptionPurpose` to `purpose`")
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
