//
//  Constants.swift
//
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Foundation

public struct Constants {
    
    public let currency: Currency
    public let designMd5hash: String
    public let header: Header
    public let hint: String
    public let income: String
    public let links: Links
    public let openValue: String
    public let orderServiceOption: String
    
    public struct Currency {
        
        public let code: Int
        public let symbol: String
        
        public init(code: Int, symbol: String) {
            self.code = code
            self.symbol = symbol
        }
    }
    
    public init(
        currency: Currency,
        designMd5hash: String,
        header: Header,
        hint: String,
        income: String,
        links: Links,
        openValue: String,
        orderServiceOption: String
    ) {
        self.currency = currency
        self.designMd5hash = designMd5hash
        self.header = header
        self.hint = hint
        self.income = income
        self.links = links
        self.openValue = openValue
        self.orderServiceOption = orderServiceOption
    }
}

public struct Links: Equatable {
    
    public let conditions: String
    public let tariff: String
    
    public init(conditions: String, tariff: String) {
        self.conditions = conditions
        self.tariff = tariff
    }
}

public struct Header: Equatable {
    
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

