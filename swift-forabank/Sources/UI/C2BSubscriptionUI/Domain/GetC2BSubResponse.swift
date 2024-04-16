//
//  GetC2BSubResponse.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import Tagged
import UIPrimitives

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
        
        public let token: Token
        public let brandIcon: Icon
        public let brandName: String
        public let purpose: Purpose
        public let cancelAlert: String
        
        public init(
            token: Token,
            brandIcon: Icon,
            brandName: String,
            purpose: Purpose,
            cancelAlert: String
        ) {
            self.token = token
            self.brandIcon = brandIcon
            self.brandName = brandName
            self.purpose = purpose
            self.cancelAlert = cancelAlert
        }
        
        public typealias Token = Tagged<_Token, String>
        public enum _Token {}
        
        public typealias Purpose = Tagged<_Purpose, String>
        public enum _Purpose {}
    }
}
