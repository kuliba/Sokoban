//
//  C2BSubscriptionEffect.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

public enum C2BSubscriptionEffect {
    
    case delete(Subscription)
    case getDetails(Subscription)
}

public extension C2BSubscriptionEffect {
    
    typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
}
