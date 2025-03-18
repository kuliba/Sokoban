//
//  Form.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import Foundation
import SelectorComponent

public struct Form<Confirmation> {
    
    public let type: CardType
    
    public let conditions: URL
    public let tariffs: URL
    
    public let requestID: String
    public let cardApplicationCardType: String
    public let cardProductExtID: String
    public let cardProductName: String
    
    public var confirmation: Loadable<Confirmation>
    public var consent = true
    public var messages: Messages
    public var orderCardResponse: OrderCardResponse?
    public var otp: String?
    public var selector: SelectorComponent.Selector<Product>
    
    public init(
        type: CardType,
        conditions: URL,
        tariffs: URL,
        requestID: String,
        cardApplicationCardType: String,
        cardProductExtID: String,
        cardProductName: String,
        confirmation: Loadable<Confirmation> = .loaded(nil),
        consent: Bool = true,
        messages: Messages,
        otp: String? = nil,
        orderCardResponse: OrderCardResponse? = nil,
        selector: SelectorComponent.Selector<Product>
    ) {
        self.type = type
        self.conditions = conditions
        self.tariffs = tariffs
        self.requestID = requestID
        self.cardApplicationCardType = cardApplicationCardType
        self.cardProductExtID = cardProductExtID
        self.cardProductName = cardProductName
        self.confirmation = confirmation
        self.consent = consent
        self.messages = messages
        self.otp = otp
        self.orderCardResponse = orderCardResponse
        self.selector = selector
    }
}

extension Form {
    
    var product: Product {
        
        selector.selected
    }
}
