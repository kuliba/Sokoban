//
//  C2BSubscriptionEffect.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

public enum C2BSubscriptionEffect {
    
    case subscription(SubscriptionEffect)
}

public extension C2BSubscriptionEffect {
    
    enum SubscriptionEffect {
        
        case delete(Subscription)
        case getDetails(Subscription)
    }
    
    typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
}
