//
//  GetOpenAccountFormResponse.swift
//  
//
//  Created by Andryusina Nataly on 22.11.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public typealias GetOpenAccountFormResponse = SerialStamped<String, GetOpenAccountFormData>
}

extension ResponseMapper {
    
    public struct GetOpenAccountFormData: Equatable {
        
        public let conditionsLink: String
        public let currency: Currency
        public let description: String
        public let design: String
        public let fee: Fee
        public let hint: String
        public let productId: Int
        public let income: String
        public let tariffLink: String
        public let title: String
        
        public init(conditionsLink: String, currency: Currency, description: String, design: String, fee: Fee, hint: String, productId: Int, income: String, tariffLink: String, title: String) {
            self.conditionsLink = conditionsLink
            self.currency = currency
            self.description = description
            self.design = design
            self.fee = fee
            self.hint = hint
            self.productId = productId
            self.income = income
            self.tariffLink = tariffLink
            self.title = title
        }
        
        public struct Currency: Equatable {
            public let code: Int
            public let symbol: String
            
            public init(code: Int, symbol: String) {
                self.code = code
                self.symbol = symbol
            }
        }
        
        public struct Fee: Equatable {
            public let openAndMaintenance: Int
            public let subscription: Subscription
            
            public init(openAndMaintenance: Int, subscription: Subscription) {
                self.openAndMaintenance = openAndMaintenance
                self.subscription = subscription
            }
        }
        
        public struct Subscription: Equatable {
            public let period: String
            public let value: Int
            
            public init(period: String, value: Int) {
                self.period = period
                self.value = value
            }
        }
    }
}
