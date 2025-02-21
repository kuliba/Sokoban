//
//  Form.swift
//  
//
//  Created by Andryusina Nataly on 27.11.2024.
//

import SwiftUI

public struct Form<Confirmation> {
    
    public let currency: Currency
    public let designMd5hash: String
    public let fee: Fee
    public let header: Header
    public let hint: String
    public let income: String
    public let links: Links
    
    public var confirmation: Loadable<Confirmation>
    public var consent = true
    public var messages: Messages
    public var otp: String?
    public var orderAccountResponse: OrderAccountResponse?
    
    public var amount: Double?
    public var sourceAccountId: Int?
    public var sourceCardId: Int?

    public init(
        currency: Currency,
        designMd5hash: String,
        fee: Fee,
        header: Header,
        hint: String,
        income: String,
        links: Links,
        confirmation: Loadable<Confirmation>,
        consent: Bool = true,
        messages: Messages,
        otp: String? = nil,
        orderAccountResponse: OrderAccountResponse? = nil,
        amount: Double? = nil,
        sourceAccountId: Int? = nil,
        sourceCardId: Int? = nil
    ) {
        self.currency = currency
        self.designMd5hash = designMd5hash
        self.fee = fee
        self.header = header
        self.hint = hint
        self.income = income
        self.links = links
        self.confirmation = confirmation
        self.consent = consent
        self.messages = messages
        self.otp = otp
        self.orderAccountResponse = orderAccountResponse
        self.amount = amount
        self.sourceAccountId = sourceAccountId
        self.sourceCardId = sourceCardId
    }
    
    public struct Links: Equatable {
        
        let conditions: String
        let tariff: String
        
        public init(conditions: String, tariff: String) {
            self.conditions = conditions
            self.tariff = tariff
        }
    }
    
    public struct Fee: Equatable {
        
        let open: Int
        let subscription: Subscription
        
        public init(open: Int, subscription: Subscription) {
            self.open = open
            self.subscription = subscription
        }
    }
    
    public struct Subscription: Equatable {
        
        let period: String
        let value: Int
        
        public init(period: String, value: Int) {
            self.period = period
            self.value = value
        }
    }
    
    public struct Currency: Equatable {
        
        let code: Int
        let symbol: String
        
        public init(code: Int, symbol: String) {
            self.code = code
            self.symbol = symbol
        }
    }
    
    public struct Header: Equatable {
        
        let title: String
        let subtitle: String
        
        public init(title: String, subtitle: String) {
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    var product: ProductData {
        
        .init(
            designMd5hash: designMd5hash,
            header: .init(title: header.title, subtitle: header.subtitle), openValue: fee.open == 0 ? "Бесплатно" : "\(fee.open) \(currency.code)", 
            orderServiceOption: orderServiceOption)
    }
    
    var orderServiceOption: String {
        
        return (fee.subscription.value == 0 || fee.subscription.period == "free")
        ? "Бесплатно"
        : "\(fee.subscription.value) \(currency.code) " + period
    }
    
    var period: String {
        
        switch fee.subscription.period {
        case "month": return "в месяц"
        case "year": return "в год"
        default: return ""
        }
    }
}
