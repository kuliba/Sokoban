//
//  C2BSubscriptionEvent.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldDomain

public enum C2BSubscriptionEvent {
    
    case tap(Tap)
    case textField(TextFieldAction)
    
    public struct Tap {
        
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
    
    public typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
}
