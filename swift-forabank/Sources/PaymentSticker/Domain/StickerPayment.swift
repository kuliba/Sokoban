//
//  StickerPayment.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public struct StickerPayment: Equatable {
    
    public let currencyAmount: String
    public let amount: Decimal
    public let check: Bool
    public let payer: Payer
    public let productToOrderInfo: Order
    
    public init(
        currencyAmount: String,
        amount: Decimal,
        check: Bool,
        payer: StickerPayment.Payer,
        productToOrderInfo: StickerPayment.Order
    ) {
        self.currencyAmount = currencyAmount
        self.amount = amount
        self.check = check
        self.payer = payer
        self.productToOrderInfo = productToOrderInfo
    }
    
    public struct Payer: Equatable {
        
        public let cardId: String
        
        public init(cardId: String) {
            self.cardId = cardId
        }
    }
    
    public struct Order: Equatable {
        
        public let type: String
        public let deliverToOffice: Bool
        public let officeId: String?
        public let cityId: Int?
        
        public init(
            type: String,
            deliverToOffice: Bool,
            officeId: String? = nil,
            cityId: Int? = nil
        ) {
            self.type = type
            self.deliverToOffice = deliverToOffice
            self.officeId = officeId
            self.cityId = cityId
        }
    }
}
