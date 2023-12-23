//
//  Parameters+Subscriber.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct Subscriber: Equatable {
        
        public typealias ID = CreateSberQRPaymentIDs.SubscriberID
        
        public let id: ID
        public let value: String
        public let style: Style
        public let icon: String
        public let subscriptionPurpose: SubscriptionPurpose?
        
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
    }
}

public extension Parameters.Subscriber {
    
    struct SubscriptionPurpose: Equatable {}
}
