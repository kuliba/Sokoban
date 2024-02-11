//
//  C2BSubscriptionEvent.swift
//  
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldDomain

enum C2BSubscriptionEvent {
    
    case tap(Tap)
    case textField(TextFieldAction)
    
    struct Tap {
        
        let subscription: Subscription
        let event: TapEvent
        
        enum TapEvent {
            
            case detail
            case delete
        }
    }

    typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
}
