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
        public let tariffLink: String
        public let list: [Item]
        
        public init(
            conditionsLink: String,
            tariffLink: String,
            list: [Item]
        ) {
            self.conditionsLink = conditionsLink
            self.tariffLink = tariffLink
            self.list = list
        }
        
        public struct Item: Equatable {
            
            public let type: String
            public let typeText: String
            public let id: String
            public let title: String
            public let description: String
            public let design: String
            public let currency: Currency
            public let fee: Fee
            
            public init(
                type: String,
                typeText: String,
                id: String,
                title: String,
                description: String,
                design: String,
                currency: Currency,
                fee: Fee
            ) {
                self.type = type
                self.typeText = typeText
                self.id = id
                self.title = title
                self.description = description
                self.design = design
                self.currency = currency
                self.fee = fee
            }
            
            public struct Currency: Equatable {
                
                public let symbol: String
                public let code: String
                
                public init(
                    code: String,
                    symbol: String
                ) {
                    self.code = code
                    self.symbol = symbol
                }
            }
            
            public struct Fee: Equatable {
                
                public let maintenance: Maintenance
                public let open: String
                
                public init(
                    maintenance: Maintenance,
                    open: String
                ) {
                    self.maintenance = maintenance
                    self.open = open
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
    }
}
