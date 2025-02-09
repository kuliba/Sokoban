//
//  Form.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct Form<Confirmation> {
    
    public let requestID: String
    public let cardApplicationCardType: String
    public let cardProductExtID: String
    public let cardProductName: String
    
    public var confirmation: LoadConfirmationResult<Confirmation>?
    public var consent = true
    public var messages: Messages
    public var otp: String?
    public var orderCardResponse: OrderCardResponse?
    
    public init(
        requestID: String,
        cardApplicationCardType: String,
        cardProductExtID: String,
        cardProductName: String,
        confirmation: LoadConfirmationResult<Confirmation>? = nil,
        consent: Bool = true,
        messages: Form<Confirmation>.Messages,
        otp: String? = nil,
        orderCardResponse: OrderCardResponse? = nil
    ) {
        self.requestID = requestID
        self.cardApplicationCardType = cardApplicationCardType
        self.cardProductExtID = cardProductExtID
        self.cardProductName = cardProductName
        self.confirmation = confirmation
        self.consent = consent
        self.messages = messages
        self.otp = otp
        self.orderCardResponse = orderCardResponse
    }
    
    public struct Messages: Equatable {
        
        let description: String
        let icon: String
        let subtitle: String
        let title: String
        public var isOn: Bool
        
        public init(
            description: String,
            icon: String,
            subtitle: String,
            title: String,
            isOn: Bool
        ) {
            self.description = description
            self.icon = icon
            self.subtitle = subtitle
            self.title = title
            self.isOn = isOn
        }
    }
}

public extension Form {
    
    var isValid: Bool { otp?.count == 6 && consent } // rename to `canOrder`
}
