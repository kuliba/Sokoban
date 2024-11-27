//
//  OrderSavingsAccountState.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import SwiftUI
import PaymentComponents

public struct OrderSavingsAccountState: Equatable {
    
    let currency: Currency
    let designMd5hash: String
    let fee: Fee
    let header: Header
    let hint: String
    let income: String
    let links: Links
    
    public init(currency: Currency, designMd5hash: String, fee: Fee, header: Header, hint: String, income: String, links: Links) {
        self.currency = currency
        self.designMd5hash = designMd5hash
        self.fee = fee
        self.header = header
        self.hint = hint
        self.income = income
        self.links = links
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
        
        let openAndMaintenance: Int
        let subscription: Subscription
        
        public init(openAndMaintenance: Int, subscription: Subscription) {
            self.openAndMaintenance = openAndMaintenance
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
}
