//
//  StickerPayment.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public struct StickerPayment {
    
    let currencyAmount: String
    let amount: Decimal
    let check: Bool
    let payer: Payer
    let productToOrderInfo: Order
    
    struct Payer {
        
        let cardId: String
    }
    
    struct Order {
        
        let type: String
        let deliverToOffice: Bool
        let officeId: String
    }
}
