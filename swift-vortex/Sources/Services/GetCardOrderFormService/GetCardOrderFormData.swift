//
//  GetCardOrderFormData.swift
//
//
//  Created by Дмитрий Савушкин on 11.12.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetCardOrderFormDataResponse = SerialStamped<String, GetCardOrderFormData>
}

extension ResponseMapper {
    
    public struct GetCardOrderFormData: Equatable {
        
        public let conditionsLink: String
        public let currency: Currency
        public let description: String
        public let design: String
        public let fee: Fee
        public let hint: String
        public let income: String
        public let productId: Int
        public let tariffLink: String
        public let title: String
        
        public init(
            conditionsLink: String,
            currency: Currency,
            description: String,
            design: String,
            fee: Fee,
            hint: String,
            income: String,
            productId: Int,
            tariffLink: String,
            title: String
        ) {
            self.conditionsLink = conditionsLink
            self.currency = currency
            self.description = description
            self.design = design
            self.fee = fee
            self.hint = hint
            self.income = income
            self.productId = productId
            self.tariffLink = tariffLink
            self.title = title
        }
        
        public struct Currency: Equatable {
            
            public let symbol: String
            public let code: Int
            
            public init(
                code: Int,
                symbol: String
            ) {
                self.code = code
                self.symbol = symbol
            }
        }
        
        public struct Fee: Equatable {
            
            public let maintenance: Maintenance
            public let open: Int
            
            public init(
                maintenance: Maintenance,
                open: Int
            ) {
                self.maintenance = maintenance
                self.open = open
            }
        }
        
        public struct Maintenance: Equatable {
            
            public let period: String
            public let value: Int
            
            public init(
                period: String,
                value: Int
            ) {
                self.period = period
                self.value = value
            }
        }
    }
}
