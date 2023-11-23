//
//  StickerPayment.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public struct StickerPayment {
    
    public let currencyAmount: String
    public let amount: Decimal
    public let check: Bool
    public let payer: Payer
    public let productToOrderInfo: Order
    
    public struct Payer {
        
        public let cardId: String
    }
    
    public struct Order {
        
        public let type: String
        public let deliverToOffice: Bool
        public let officeId: String?
        public let cityId: Int?
    }
}
