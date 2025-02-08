//
//  OrderProcessCard.swift
//  
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation
import SwiftUI

public struct OrderProcessCard: Equatable {
    
    let currency: Currency
    let designMd5hash: String
    let fee: Fee
    let header: Header
    let hint: String
    let income: String
    
    public init(
        currency: Currency,
        designMd5hash: String,
        fee: Fee,
        header: Header,
        hint: String,
        income: String
    ) {
        self.currency = currency
        self.designMd5hash = designMd5hash
        self.fee = fee
        self.header = header
        self.hint = hint
        self.income = income
    }
    
    public struct Fee: Equatable {
        
        let open: Int
        let subscription: Subscription
        
        public init(
            open: Int,
            subscription: Subscription
        ) {
            self.open = open
            self.subscription = subscription
        }
    }
    
    public struct Subscription: Equatable {
        
        let period: String
        let value: Int
        
        public init(
            period: String,
            value: Int
        ) {
            self.period = period
            self.value = value
        }
    }
    
    public struct Currency: Equatable {
        
        let code: Int
        let symbol: String
        
        public init(
            code: Int,
            symbol: String
        ) {
            self.code = code
            self.symbol = symbol
        }
    }
    
    public struct Header: Equatable {
        
        let title: String
        let subtitle: String
        
        public init(
            title: String,
            subtitle: String
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
