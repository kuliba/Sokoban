//
//  CreateSberQRPaymentResponse+Subscriber.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    struct Subscriber: Equatable {
        
        let id: ID
        let value: String
        let style: Style
        let icon: String
        let subscriptionPurpose: SubscriptionPurpose?
        
        public init(
            id: ID,
            value: String,
            style: Style,
            icon: String,
            subscriptionPurpose: SubscriptionPurpose?
        ) {
            self.id = id
            self.value = value
            self.style = style
            self.icon = icon
            self.subscriptionPurpose = subscriptionPurpose
        }
        
        public struct SubscriptionPurpose: Equatable {}
    }
}
