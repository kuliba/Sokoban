//
//  C2BSubscriptionEvent.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldDomain

public enum C2BSubscriptionEvent {
    
    case alertTap(AlertEvent)
    case destination(DestinationEvent)
    case subscription(SubscriptionEvent)
    case subscriptionTap(SubscriptionTap)
    case textField(TextFieldAction)
}

public extension C2BSubscriptionEvent {
    
    enum AlertEvent: Equatable {
        
        case cancel
        case delete(Subscription)
    }
    
    enum DestinationEvent {
        
        case dismiss
    }
    
    enum SubscriptionEvent {
        
        case cancelled(CancelC2BSubscriptionConfirmation)
        case cancelFailure(ServiceFailure)
        case detailReceived(C2BSubscriptionDetail)
        case detailFailure(ServiceFailure)
    }
    
    struct SubscriptionTap {
        
        public let subscription: Subscription
        public let event: TapEvent
        
        public init(
            subscription: Subscription,
            event: TapEvent
        ) {
            self.subscription = subscription
            self.event = event
        }
        
        public enum TapEvent {
            
            case detail
            case delete
        }
    }
    
    typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
}
