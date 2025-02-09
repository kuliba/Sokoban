//
//  Form.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct Form<Confirmation> {
    
    public let product: Product
    public let type: CardType
    
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
        product: Product,
        type: CardType,
        requestID: String,
        cardApplicationCardType: String,
        cardProductExtID: String,
        cardProductName: String,
        confirmation: LoadConfirmationResult<Confirmation>? = nil,
        consent: Bool = true,
        messages: Messages,
        otp: String? = nil,
        orderCardResponse: OrderCardResponse? = nil
    ) {
        self.product = product
        self.type = type
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
}

public extension Form {
    
    var isValid: Bool { otp?.count == 6 && consent } // rename to `canOrder`
}
